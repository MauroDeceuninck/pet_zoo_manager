from flask import Flask, request, Response
import json
import uuid
import os

app = Flask(__name__)

def read_db(filename):
    try:
        with open(filename, 'rt', encoding='utf-8') as f:
            return json.load(f)
    except FileNotFoundError:
        return []

def write_db(filename, data):
    tmpfile = filename.replace('.json', '_tmp.json')
    with open(tmpfile, 'wt', encoding='utf-8') as f:
        json.dump(data, f, indent=2)
    if os.path.exists(filename):
        os.remove(filename)
    os.rename(tmpfile, filename)

@app.route('/animals', methods=['GET'])
def get_animals():
    return Response(json.dumps(read_db('animals.json')), status=200, mimetype='application/json')

@app.route('/animals', methods=['POST'])
def add_animal():
    data = request.get_json()
    animal = {
        "id": str(uuid.uuid4()),
        "name": data.get('name'),
        "species": data.get('species')
    }
    db = read_db('animals.json')
    db.append(animal)
    write_db('animals.json', db)
    return Response(json.dumps(animal), status=200, mimetype='application/json')

@app.route('/animals/<string:animal_id>', methods=['DELETE'])
def delete_animal(animal_id):
    db = read_db('animals.json')
    db = [a for a in db if a['id'] != animal_id]
    write_db('animals.json', db)

    tasks = read_db('tasks.json')
    tasks = [t for t in tasks if t['animal_id'] != animal_id]
    write_db('tasks.json', tasks)
    return Response(status=200)

@app.route('/tasks/<string:animal_id>', methods=['GET'])
def get_tasks(animal_id):
    tasks = read_db('tasks.json')
    filtered = [t for t in tasks if t['animal_id'] == animal_id]
    return Response(json.dumps(filtered), status=200, mimetype='application/json')

@app.route('/tasks', methods=['POST'])
def add_task():
    data = request.get_json()
    task = {
        "id": str(uuid.uuid4()),
        "animal_id": data.get('animal_id'),
        "description": data.get('description'),
        "done": 0
    }
    db = read_db('tasks.json')
    db.append(task)
    write_db('tasks.json', db)
    return Response(json.dumps(task), status=200, mimetype='application/json')

@app.route('/tasks/<string:task_id>', methods=['PUT'])
def update_task(task_id):
    data = request.get_json()
    db = read_db('tasks.json')
    for t in db:
        if t['id'] == task_id:
            t['description'] = data.get('description', t['description'])
            t['done'] = data.get('done', t['done'])
            write_db('tasks.json', db)
            return Response(json.dumps(t), status=200, mimetype='application/json')
    return Response(status=404)

@app.route('/tasks/<string:task_id>', methods=['DELETE'])
def delete_task(task_id):
    db = read_db('tasks.json')
    db = [t for t in db if t['id'] != task_id]
    write_db('tasks.json', db)
    return Response(status=200)

if __name__ == '__main__':
    app.run(debug=True, host="0.0.0.0", port=8080)
