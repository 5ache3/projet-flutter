import os
import uuid
import base64
from flask import Flask, request, jsonify, render_template
from passlib.hash import bcrypt
import mysql.connector
from flask_jwt_extended import (
    JWTManager, create_access_token
)

app = Flask(__name__)

app.config['JWT_SECRET_KEY'] = 'super-secret-key'
jwt = JWTManager(app)

UPLOAD_FOLDER = 'api/static/uploads'
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif'}
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER


def get_db_connection():
    # Create a new DB connection per call
    return mysql.connector.connect(
        host="127.0.0.1",
        user="root",
        passwd="",
        database="cours_flask"
    )


def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS


def handle_image(file):
    unique = uuid.uuid4().hex
    filename = f"{unique}.jpg"

    os.makedirs(app.config['UPLOAD_FOLDER'], exist_ok=True)
    full_path = os.path.join(app.config['UPLOAD_FOLDER'], filename)

    with open(full_path, 'wb') as f:
        f.write(file)

    return f"{app.config['UPLOAD_FOLDER']}/{filename}"


def push_images(images, house_id):
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        for image in images:
            img_id = uuid.uuid4().hex
            img_type = 'main' if image['main'] else ''
            cursor.execute(
                "INSERT INTO images (id, house_id, type, url) VALUES (%s, %s, %s, %s)",
                (img_id, house_id, img_type, image['url'])
            )
        conn.commit()
    finally:
        cursor.close()
        conn.close()


def get_images(house_id):
    conn = get_db_connection()
    cursor = conn.cursor()
    images = []
    try:
        cursor.execute("SELECT * FROM images WHERE house_id=%s", (house_id,))
        result = cursor.fetchall()
        for item in result:
            images.append({'main': item[2] == 'main', 'url': item[3]})
    finally:
        cursor.close()
        conn.close()
    return images


def delete_image(url):
    if os.path.exists(url):
        os.remove(url)


@app.route('/register', methods=['POST'])
def register():
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        data = request.get_json()
        username = data.get('username')
        password = data.get('password')

        cursor.execute("SELECT * FROM users WHERE username=%s", (username,))
        exist = cursor.fetchall()
        if exist:
            return jsonify({"error": "User already exists"}), 400

        hashed_password = bcrypt.hash(password)
        user_id = uuid.uuid4().hex
        cursor.execute(
            "INSERT INTO users (id, username, password, role) VALUES (%s, %s, %s, 'user')",
            (user_id, username, hashed_password)
        )
        conn.commit()

        access_token = create_access_token(identity={
            'username': username,
            'user_id': user_id,
            'role': 'user'
        })
        return jsonify(access_token=access_token), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    finally:
        cursor.close()
        conn.close()


@app.route('/login', methods=['POST'])
def login():
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        data = request.get_json()
        username = data.get('username')
        password = data.get('password')

        cursor.execute("SELECT id, username, password, role FROM users WHERE username=%s", (username,))
        user = cursor.fetchone()

        if not user:
            return jsonify({"error": "username not found"}), 400

        if not bcrypt.verify(password, user[2]):
            return jsonify({"error": "wrong password"}), 403

        access_token = create_access_token(identity={
            'username': user[1],
            'user_id': user[0],
            'role': user[3]
        })

        return jsonify(access_token=access_token), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    finally:
        cursor.close()
        conn.close()


@app.route('/create', methods=['GET', 'POST'])
def create():
    admin_id = '1'
    if request.method == 'POST':
        conn = get_db_connection()
        cursor = conn.cursor()
        try:
            data = request.get_json()
            house_id = uuid.uuid4().hex
            description = data['description']
            price = data['price']
            surface = data['surface']
            nm_rooms = data['nb_rooms']
            type_ = data['type']
            location = data['location']
            ville = data['city']
            region = data['region']

            main_image_b64 = data['mainImage']
            interior_images_b64 = data['images']
            images = []

            main_image = handle_image(base64.b64decode(main_image_b64))
            if main_image:
                images.append({'main': True, 'url': main_image})

            for f in interior_images_b64:
                image = handle_image(base64.b64decode(f))
                images.append({'main': False, 'url': image})

            cursor.execute('''
                INSERT INTO houses (id, admin_id, description, price, surface, rooms, type, location, ville, region)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            ''', (house_id, admin_id, description, price, surface, nm_rooms, type_, location, ville, region))
            conn.commit()
        except Exception as e:
            return jsonify({'error': str(e)}), 500
        finally:
            cursor.close()
            conn.close()

        push_images(images, house_id)
        return jsonify({'success': 'created'}), 200

    return render_template('create.html')


@app.route('/get', methods=['GET'])
def get_list_houses():
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute("SELECT id, admin_id, description, price, surface, type, location, ville, region, rooms FROM houses")
        result = cursor.fetchall()
        houses = []
        for item in result:
            houses.append({
                "id": item[0],
                "admin_id": item[1],
                "description": item[2],
                "price": item[3],
                "surface": item[4],
                "type": item[5],
                "location": item[6],
                "ville": item[7],
                "region": item[8],
                "nb_rooms": item[9],
                "images": get_images(item[0])
            })
        return jsonify(houses)
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        cursor.close()
        conn.close()


@app.route('/', methods=['GET'])
def index():
    try:
        houses = get_list_houses().json
        items = []
        for house in houses:
            image = ''
            if house['images']:
                image = house['images'][0]['url'].replace('api/', '/')
                for img in house['images']:
                    if img['main']:
                        image = img['url'].replace('api/', '/')
            items.append([house['id'], house['description'], house['ville'], image])
        return render_template('index.html', items=items)
    except Exception as e:
        return f"Error: {str(e)}"


@app.route('/delete_house/<string:id>', methods=["DELETE", 'GET'])
def delete_house(id):
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        images = get_images(id)
        for image in images:
            delete_image(image['url'])

        cursor.execute("DELETE FROM images WHERE house_id=%s", (id,))
        cursor.execute("DELETE FROM favorite WHERE house_id=%s", (id,))
        cursor.execute("DELETE FROM houses WHERE id=%s", (id,))
        conn.commit()
        return index()
    except Exception as e:
        return {"error": str(e)}, 500
    finally:
        cursor.close()
        conn.close()


@app.route('/favorites/<string:u_id>', methods=['GET', 'POST'])
def get_favorites(u_id):
    conn = get_db_connection()
    cursor = conn.cursor(buffered=True)

    try:
        if request.method == 'POST':
            data = request.json
            user_id = data.get('user_id')
            house_id = data.get('house_id')

            if not user_id or not house_id:
                return {"error": "Missing user_id or house_id"}, 400

            cursor.execute("SELECT * FROM favorite WHERE user_id=%s AND house_id=%s", (user_id, house_id))
            exists = cursor.fetchone()

            if exists:
                cursor.execute("DELETE FROM favorite WHERE user_id=%s AND house_id=%s", (user_id, house_id))
            else:
                cursor.execute(
                    "INSERT INTO favorite (id, user_id, house_id) VALUES (%s, %s, %s)",
                    (uuid.uuid4().hex, user_id, house_id)
                )
            conn.commit()
            return {'success': ''}, 200

        else:
            cursor.execute("SELECT house_id FROM favorite WHERE user_id=%s", (u_id,))
            house_ids = [item[0] for item in cursor.fetchall()]

            if not house_ids:
                return jsonify([])

            placeholders = ','.join(['%s'] * len(house_ids))
            sql = f"SELECT id, admin_id, description, price, surface, type, location, ville, region, rooms FROM houses WHERE id IN ({placeholders})"
            cursor.execute(sql, house_ids)
            result = cursor.fetchall()

            houses = []
            for item in result:
                houses.append({
                    "id": item[0],
                    "admin_id": item[1],
                    "description": item[2],
                    "price": item[3],
                    "surface": item[4],
                    "type": item[5],
                    "location": item[6],
                    "ville": item[7],
                    "region": item[8],
                    "nb_rooms": item[9],
                    "images": get_images(item[0])
                })

            return jsonify(houses)

    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        cursor.close()
        conn.close()


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
