import os
import uuid
from flask import Flask, request, jsonify, render_template, redirect, url_for
from werkzeug.utils import secure_filename
from passlib.hash import bcrypt
import mysql.connector
import base64
from flask_jwt_extended import (
    JWTManager, create_access_token, jwt_required, get_jwt_identity
)

db=mysql.connector.connect(
    host="127.0.0.1",
    user="root",
    passwd="",
    database="cours_flask"
)
pool=db.cursor()

app = Flask(__name__)

app.config['JWT_SECRET_KEY'] = 'super-secret-key'
jwt = JWTManager(app)

UPLOAD_FOLDER = 'api/static/uploads'
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif'}
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

def handle_image(file):
    image_path = None
    unique=uuid.uuid4().hex
    filename = f"{unique}.jpg"

    with open(os.path.join(app.config['UPLOAD_FOLDER'], filename), 'wb') as f:
        f.write(file)

    image_path=os.path.join('api',app.config['UPLOAD_FOLDER'],filename)
    image_path = f"{app.config['UPLOAD_FOLDER']}/{filename}"
    return image_path

def push_images(images,house_id):
    for image in images:
        img_id=uuid.uuid4().hex
        if image['main']:
            pool.execute("INSERT INTO images(id,house_id,type,url) VALUES(%s,%s,%s,%s)",(img_id,house_id,'main',image['url']))
        else:
            pool.execute("INSERT INTO images(id,house_id,type,url) VALUES(%s,%s,%s,%s)",(img_id,house_id,'',image['url']))
        db.commit()

def get_images(house_id):
    pool.execute(f"SELECT * FROM images WHERE house_id='{house_id}'")
    result=pool.fetchall()
    images=[]
    for item in result:
        if item[2]=='main':
            images.append({'main':True,'url':item[3]})
        else:
            images.append({'main':False,'url':item[3]})
    return images

def delete_image(url):
    os.remove(url)



@app.route('/register',methods=['POST'])

def register():
    try:
        data = request.get_json()
        username = data.get('username')
        password = data.get('password')
        pool.execute("SELECT * FROM users WHERE username =%s",(username,))
        exist=pool.fetchall()
        if exist:
            return jsonify({"error": "User already exists"}), 400
        hashed_password=bcrypt.hash(password)
        user_id = uuid.uuid4().hex
        pool.execute("INSERT INTO users(id,username,password,role) VALUES(%s,%s,%s,'user')",(user_id,username,hashed_password))
        db.commit()

        access_token = create_access_token(identity={
            'username': username,
            'user_id': user_id,
            'role': 'user'
        })

        return jsonify(access_token=access_token), 200
    except Exception as e:
        return jsonify({'error':e}),500

@app.route('/login', methods=['POST'])
def login():
    try:
        data = request.get_json()
        username = data.get('username')
        password = data.get('password')
        pool.execute("SELECT id,username,password,role FROM users WHERE username =%s",(username,))
        user=pool.fetchone()

        if not user:
            return jsonify({"error": "username not found"}), 400
        
        if not bcrypt.verify(password, user[2]):
            return jsonify({"error": "wrong password"}), 403
    except Exception as e:
        return jsonify({'error':e}),500
    
    user_id=user[0]
    username=user[1]
    role=user[3]
    access_token = create_access_token(identity={
        'username': username,
        'user_id': user_id,
        'role': role
    })

    return jsonify(access_token=access_token), 200


@app.route('/create', methods=['GET', 'POST'])
def create():
    admin_id = '1'
    if request.method == 'POST':
        try:
            data = request.get_json()
            description = data['description']
            price = data['price']
            surface = data['surface']
            nm_rooms = data['nb_rooms']
            type = data['type']
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

            house_id = uuid.uuid4().hex
            
            pool.execute(f''' INSERT INTO houses(id, admin_id, description, price, surface, rooms, type, location, ville, region)
                       VALUES("{house_id}", "{admin_id}", "{description}", "{price}", "{surface}",
                         "{nm_rooms}", "{type}", "{location}", "{ville}", "{region}")''')
            db.commit()

            push_images(images, house_id)
            return jsonify({'success':'created'}),200

        except Exception as e:
            print("Error:", e)
            return jsonify({'error':str(e)}),500
    
    return render_template('create.html')


@app.route('/get',methods=['GET'])
def get_list_houses():
    pool.execute("SELECT id,admin_id,description,price,surface,type,location,ville,region,rooms FROM houses")
    result=pool.fetchall()
    houses=[]
    for item in result:
        houses.append({
            "id":item[0],
            "admin_id":item[1],
            "description":item[2],
            "price":item[3],
            "surface":item[4],
            "type":item[5],
            "location":item[6],
            "ville":item[7],
            "region":item[8],
            "nb_rooms":item[9],
            "images":get_images(item[0])
        })
    return houses


@app.route('/',methods=['GET'])
def index():
    list_houses=get_list_houses()
    items=[]
    for house in list_houses:
        image=''
        if house['images']:
            image=house['images'][0]['url'].replace('api/','/')
            for img in house['images']:
                if img['main']:
                    image=img['url'].replace('api/','/')
        items.append([house['id'],house['description'],house['ville'],image])
    return render_template('index.html',items=items)


@app.route('/delete_house/<string:id>', methods=["DELETE",'GET'])
def delete_house(id):
    try:
        images = get_images(id)
        for image in images:
            delete_image(image['url'])
        pool.execute("DELETE FROM images WHERE house_id = %s", (id,))
        db.commit()
        pool.execute("DELETE FROM favorite WHERE house_id = %s", (id,))
        db.commit()
        pool.execute("DELETE FROM houses WHERE id = %s", (id,))
        db.commit()

        return index()
    except Exception as e:  
        return {"error": str(e)}, 500

@app.route('/favorites/<string:u_id>',methods=['GET','POST'])
def get_favorites(u_id):
    if request.method == 'POST':
        try:
            data = request.json
            user_id = data.get('user_id')
            house_id = data.get('house_id')

            if not user_id or not house_id:
                return {"error": "Missing user_id or house_id"}, 400
            
            pool.execute("SELECT * FROM favorite WHERE user_id = %s AND house_id = %s", (user_id, house_id))
            exists = pool.fetchone()

            if exists:
                pool.execute("DELETE FROM favorite WHERE user_id = %s AND house_id = %s", (user_id, house_id))
            else:
                pool.execute("INSERT INTO favorite (id,user_id, house_id) VALUES (%s, %s,%s)", (uuid.uuid4().hex,user_id, house_id))

            db.commit()

            return {'sucsess':''},200
        except Exception as e:
            
            return {"error": str(e)}, 500
     
    else:
        try:
            pool.execute("SELECT house_id FROM favorite WHERE user_id=%s",(u_id,))
            house_ids = [item[0] for item in pool.fetchall()]
            if not house_ids:
                return []  

            placeholders = ','.join(['%s'] * len(house_ids))
            sql = f"SELECT  id,admin_id,description,price,surface,type,location,ville,region,rooms FROM houses WHERE id IN ({placeholders})"
            pool.execute(sql, house_ids)
            result=pool.fetchall()
            houses=[]
            for item in result:
                houses.append({
                    "id":item[0],
                    "admin_id":item[1],
                    "description":item[2],
                    "price":item[3],
                    "surface":item[4],
                    "type":item[5],
                    "location":item[6],
                    "ville":item[7],
                    "region":item[8],
                    "nb_rooms":item[9],
                    "images":get_images(item[0])
                })
            return houses
        
        except Exception as e:
            return {"error": str(e)}, 500


app.run(host='0.0.0.0', port=5000)

