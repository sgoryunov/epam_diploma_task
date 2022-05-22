from flask import Flask, render_template
import os
# from prometheus_flask_exporter import PrometheusMetrics
import requests
from flask_sqlalchemy import SQLAlchemy

app = Flask(__name__, static_url_path='/static')

# metrics = PrometheusMetrics(app)

app.config['SQLALCHEMY_DATABASE_URI'] = os.getenv('database_url')
# app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql://myuser:mypassword@db/mydatabase'
# app.config['SQLALCHEMY_DATABASE_URI'] = "mysql://" \
#     +os.getenv('DB_USER') \
#     +":"+os.getenv('DB_USER_PASS') \
#     +'@'+os.getenv('DB_HOST') \
#     +'/'+os.getenv('DB_NAME')
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)

class itunes_data(db.Model):
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    kind = db.Column(db.String(255), nullable=False)
    collectionName = db.Column(db.String(255), nullable=False)
    trackName = db.Column(db.String(255), nullable=False)
    collectionPrice = db.Column(db.Float)
    trackPrice = db.Column(db.Float)
    primaryGenreName = db.Column(db.String(255), nullable=False)
    trackCount = db.Column(db.Integer)
    trackNumber = db.Column(db.Integer)
    # releaseDate = db.Column(db.DateTime)
    releaseDate = db.Column(db.String(255), nullable=False)
    def __repr__(self):
        return '<itines_data %r>' % self.trackName

# @app.before_first_request
# def init_db():
#     requests.get('http://itunes-gr-backend:5000/api/update')

@app.route('/')
def index():
    try:
        data = itunes_data.query.order_by(itunes_data.collectionName).all()
        return render_template("index2.html", data=data)
        return data
    except Exception as e:
        return (str(e))

@app.route('/update', methods=['GET'])
def update():
    response = requests.get('http://itunes-gr-backend:5000/api/update')
    return "ok"

@app.route('/health')
def health():
    return "OK"