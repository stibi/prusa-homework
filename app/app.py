import time
from datetime import datetime, timedelta
from os import getenv
from random import uniform

import redis
from flask import Flask
from flask_sqlalchemy import SQLAlchemy

app = Flask(__name__)
context = {'start_time': datetime.now()}

app_host = getenv('APP_HOST', '0.0.0.0')
app_port = int(getenv('APP_PORT', 5000))
redis_host = getenv('REDIS_HOST', 'redis')
redis_port = int(getenv('REDIS_PORT', 6379))
# app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:////tmp/test.db'
# app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql+pymysql://user:password@host:3306/db_name'
# app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql+psycopg2://user:password@host:5432/db_name'
connection_string = getenv('DATABASE_URI', 'sqlite:////tmp/test.db')
print('Conecting to DB', connection_string)

app.config['SQLALCHEMY_DATABASE_URI'] = connection_string
db = SQLAlchemy(app)


class Palindrom(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    text = db.Column(db.String(200), nullable=False)


def is_ready():
    return datetime.now() > context['start_time'] + timedelta(seconds=10)


@app.route('/')
def hello_world():
    if not is_ready():
        return 'Not ready', 404
    return 'Hello, World!'


@app.route('/status')
def status():
    if not is_ready():
        return 'Not ready', 404
    return 'OK'


@app.route('/palindrom/<text>')
def palindrom(text):
    if not is_ready():
        return 'Not ready', 404
    text = text[:200]
    if text == text[::-1]:
        palindrom = Palindrom(text=text)
        db.session.add(palindrom)
        db.session.commit()
        return 'Text is palindrom'
    return 'Text is not palindrom'


@app.route('/admin')
def admin():
    if not is_ready():
        return 'Not ready', 404
    return 'admin area'


@app.route('/prepare-for-deploy')
def prapare_for_deploy():
    if not is_ready():
        return 'Not ready', 404
    if 'end_time' not in context:
        delta = timedelta(seconds=uniform(5, 15))
        context['end_time'] = datetime.now() + delta
    return 'preparing'


@app.route('/ready-for-deploy')
def ready_for_deploy():
    if not is_ready():
        return 'Not ready', 404
    if 'end_time' in context and context['end_time'] < datetime.now():
        return 'Ready'
    return 'Not ready'


@app.route('/redis-hits')
def redis_hits():
    if not is_ready():
        return 'Not ready', 404
    if 'redis' not in context:
        context['redis'] = redis.Redis(host=redis_host, port=redis_port, socket_connect_timeout=5)
    cache = context['redis']
    retries = 5
    while True:
        try:
            return 'Redis hits ' + str(cache.incr('hits'))
        except redis.exceptions.ConnectionError as exc:
            if retries == 0:
                return 'No response from redis'
            retries -= 1
            time.sleep(0.5)

if __name__ == '__main__':
    app.run(host=app_host, port=app_port)
