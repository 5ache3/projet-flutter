import os
import uuid
from flask import Flask, request, jsonify, render_template, redirect, url_for
from werkzeug.utils import secure_filename
import mysql.connector

db=mysql.connector.connect(
    host="127.0.0.1",
    user="root",
    passwd="",
    database="cours_flask"
)
pool=db.cursor()

app = Flask(__name__)


UPLOAD_FOLDER = 'api/static/uploads'
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif'}
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

def handle_image(file):
    image_path = None
    if file and allowed_file(file.filename):
        unique=uuid.uuid4().hex
        filename = f"{unique}.{file.filename.split('.')[-1]}"
        
        file.save(os.path.join(app.config['UPLOAD_FOLDER'], filename))
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



@app.route('/create', methods=['GET', 'POST'])
def create():
    admin_id = '1'
    if request.method == 'POST':
        try:
            description = request.form['description']
            price = request.form['price']
            surface = request.form['surface']
            nm_rooms = request.form['nb_rooms']
            type = request.form['type']
            location = request.form['location']
            ville = request.form['city']
            region = request.form['region']
            file = request.files['mainImage']
            files = request.files.getlist('images[]')
            images = []
            main_image = handle_image(file)
            if main_image:
                images.append({'main': True, 'url': main_image})

            for f in files:
                image = handle_image(f)
                images.append({'main': False, 'url': image})

            house_id = uuid.uuid4().hex
            
            pool.execute(f''' INSERT INTO houses(id, admin_id, description, price, surface, rooms, type, location, ville, region)
                       VALUES("{house_id}", "{admin_id}", "{description}", "{price}", "{surface}",
                         "{nm_rooms}", "{type}", "{location}", "{ville}", "{region}")''')
            db.commit()

            push_images(images, house_id)
            return index()

        except Exception as e:
            return {'error':str(e)},500
            print("Error:", e)
    
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

