import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._constructor();
  static Database? _db;
  DatabaseService._constructor();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _openDatabase();
    return _db!;
  }

  Future<Database> _openDatabase() async {
    final path   = await getDatabasesPath();
    final dbPath = join(path, 'local.db');

    final database = openDatabase(dbPath, version: 1, onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE houses (
            id          TEXT PRIMARY KEY,
            admin_id    TEXT,
            description TEXT,
            price       TEXT,
            rooms       INTEGER,
            surface     TEXT,
            type        TEXT,
            location    TEXT,
            ville       TEXT,
            region      TEXT
          );
        ''');
        await db.execute('''
          CREATE TABLE images (
            id       TEXT PRIMARY KEY,
            house_id TEXT,
            url      TEXT
          );
        ''');
      },
    );
    return database;
  }

  Future<List<Map<String, dynamic>>> getHouses() async {
    final db = await database;

    const sql = '''
      SELECT h.id,
             h.surface,
             h.admin_id,
             h.region,
             h.ville,
             h.type,
             h.location,
             h.price,
             GROUP_CONCAT(i.url) AS images
      FROM houses h
      LEFT JOIN images i ON i.house_id = h.id
      GROUP BY h.id
      ORDER BY h.id;
    ''';

    final rows = await db.rawQuery(sql);

    return rows.map((row) {
      final images = (row['images'] as String?)
          ?.split(',')
          .where((e) => e.isNotEmpty)
          .toList(growable: false) //
          ?? const <String>[];

      return {
        'id'       : row['id'],
        'surface'  : row['surface'],
        'admin_id' : row['admin_id'],
        'region'   : row['region'],
        'ville'    : row['ville'],
        'type'     : row['type'],
        'location' : row['location'],
        'price'    : row['price'],
        'images'   : images,
      };
    }).toList(growable: false);
  }

  Future<void> deleteAll() async {
    final db = await database;
    await db.delete('images');
    await db.delete('houses');
  }

  Future<void> addHouse(Map<String, dynamic> house, {List<String>? imageUrls,}) async {
    final db = await database;
    final uuid = Uuid();

    await db.insert(
      'houses',
      house,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    if (imageUrls != null) {
      for (final url in imageUrls) {
        await db.insert(
          'images',
          {
            'id': uuid.v4(),
            'house_id': house['id'],
            'url': url,
          }
        );
      }
    }
  }
}
