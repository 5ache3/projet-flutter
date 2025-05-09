import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:projet/components/TextField.dart';
import 'package:projet/components/location_picker.dart';
import 'package:projet/constants.dart';
import 'package:projet/pages/home_page.dart';
import '../modals/property.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class PublishPage extends StatefulWidget {
  // final Function(Property) onAddProperty;
  final String user_id;
  final String user_role;
  const PublishPage({
    super.key,
    required this.user_id,
    required this.user_role,
  });

  @override
  State<PublishPage> createState() => _PublishPageState();
}

class _PublishPageState extends State<PublishPage> {
  @override
  void initState() {
    super.initState();
    initPage();
  }

  Future<void> initPage() async {
    await getTokenData();
  }

  File? _image;
  List<File> interiorImages = [];
  final titleController = TextEditingController();
  final priceController = TextEditingController();
  final surfaceController = TextEditingController();
  final cityController = TextEditingController();
  final regionController = TextEditingController();
  final typeController = TextEditingController();
  final roomsController = TextEditingController();
  String? location;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickInteriorImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        interiorImages = pickedFiles.map((e) => File(e.path)).toList();
      });
    }
  }

  void _openImageFullScreen(File imageFile) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder:
            (context, _, __) => Dismissible(
              key: const Key("imageViewer"),
              direction: DismissDirection.down,
              onDismissed: (_) => Navigator.pop(context),
              child: Container(
                color: Colors.black,
                alignment: Alignment.center,
                child: InteractiveViewer(child: Image.file(imageFile)),
              ),
            ),
      ),
    );
  }

  void _submit() async {
    if (_image != null &&
        titleController.text.isNotEmpty &&
        priceController.text.isNotEmpty) {
      final imageBytes = await _image?.readAsBytes();
      final imageBase64 = base64Encode(imageBytes!);

      final interiorImages64 = await Future.wait(
        interiorImages.map((img) async {
          final bytes = await img.readAsBytes();
          return base64Encode(bytes);
        }),
      );
      final data = {
        'description': titleController.text,
        'price': priceController.text,
        'surface': surfaceController.text,
        'nb_rooms': roomsController.text,
        'type': typeController.text,
        'region': regionController.text,
        'city': cityController.text,
        'location': location,
        'mainImage': imageBase64,
        'images': interiorImages64,
      };
      final url = Uri.parse('$apiUrl/create');
      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode(data),
        );
        if (response.statusCode == 200) {
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text("Succès"),
                  content: const Text("Logement ajouté avec succès."),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop();
                        Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => HomePage()));
                      },
                      child: const Text("OK"),
                    ),
                  ],
                ),
          );
        } else {
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: Text("Erreur"),
                  content: Text(
                    "Échec de l'ajout du logement. Code: ${response.statusCode}",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("OK"),
                    ),
                  ],
                ),
          );
        }
      } catch (error) {
        print(error);
      }
    } else {
      // Optionally show a validation error
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text("Erreur"),
              content: const Text(
                "Veuillez remplir tous les champs et sélectionner une image.",
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  child: const Text("OK"),
                ),
              ],
            ),
      );
    }
  }

  final storage = FlutterSecureStorage();
  String? user_id;
  String? user_role;

  Future<void> getTokenData() async {
    String? token = await storage.read(key: 'token');

    if (token != null) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token)['sub'];

      final userId = decodedToken['user_id'];
      final role = decodedToken['role'];
      setState(() {
        user_id = userId;
        user_role = role;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return user_role == 'admin'
        ? Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // main image
                GestureDetector(
                  onTap:
                      _image == null
                          ? _pickImage
                          : () => _openImageFullScreen(_image!),
                  child:
                      _image == null
                          // if no image was picked
                          ? Container(
                            height: 180,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.camera_alt,
                                size: 50,
                                color: Colors.grey,
                              ),
                            ),
                          )
                          // if there was an image
                          : ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(
                              _image!,
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                ),
                const SizedBox(height: 16),

                // secondairy images picker
                ElevatedButton.icon(
                  onPressed: _pickInteriorImages,
                  icon: const Icon(Icons.photo_library),
                  label: const Text("more images"),
                ),
                const SizedBox(height: 10),

                // list of picked images
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      interiorImages.map((file) {
                        return GestureDetector(
                          onTap: () => _openImageFullScreen(file),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              file,
                              height: 80,
                              width: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      }).toList(),
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: titleController,
                  label: "title",
                  icon: Icons.title,
                ),
                const SizedBox(height: 10),

                CustomTextField(
                  controller: priceController,
                  label: "price",
                  icon: Icons.attach_money,
                ),
                const SizedBox(height: 10),

                CustomTextField(
                  controller: surfaceController,
                  label: "Surface (m²)",
                  icon: Icons.landscape,
                ),
                const SizedBox(height: 10),

                CustomTextField(
                  controller: roomsController,
                  label: "number of rooms",
                  icon: Icons.bed,
                  isNumeric: true,
                ),
                const SizedBox(height: 10),

                CustomTextField(
                  controller: regionController,
                  label: "region",
                  icon: Icons.track_changes,
                ),
                const SizedBox(height: 10),

                CustomTextField(
                  controller: cityController,
                  label: "city",
                  icon: Icons.location_city,
                ),
                const SizedBox(height: 10),

                CustomTextField(
                  controller: typeController,
                  label: "type",
                  icon: Icons.house,
                ),
                const SizedBox(height: 20),

                PickLocationBox(
                  onLocationPicked:
                      (cords) => {
                        setState(() {
                          location = cords;
                        }),
                      },
                ),

                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _submit,
                    child: Text(
                      "Submit",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
        : Center(child: Text("you don't have permition"));
  }
}
