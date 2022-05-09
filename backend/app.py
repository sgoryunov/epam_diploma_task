import requests
# import xml.etree.ElementTree as ET
from datetime import datetime, timedelta
from flask import Flask
from flask_cors import CORS
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
# from dotenv import load_dotenv
#from prometheus_flask_exporter import PrometheusMetrics
import os

app = Flask(__name__)
app.logger.debug('Update db')

# metrics = PrometheusMetrics(app)


app.config['SQLALCHEMY_DATABASE_URI'] = "mysql://myuser:mypassword@db/mydatabase"
# app.config['SQLALCHEMY_DATABASE_URI'] = "mysql://" \
#     +os.getenv('DB_USER') \
#     +":"+os.getenv('DB_USER_PASS') \
#     +'@'+os.getenv('DB_HOST') \
#     +'/'+os.getenv('DB_NAME')
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)
migrate = Migrate(app, db)

class itunes_data(db.Model):
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    kind = db.Column(db.String(255), nullable=False)
    collectionName = db.Column(db.String(255), nullable=False)
    trackName = db.Column(db.String(255),nullable=False)
    collectionPrice = db.Column(db.Float)
    trackPrice = db.Column(db.Float)
    primaryGenreName = db.Column(db.String(255), nullable=False)
    trackCount = db.Column(db.Integer)
    trackNumber = db.Column(db.Integer)
    # releaseDate = db.Column(db.DateTime)
    releaseDate = db.Column(db.String(255), nullable=False)
    def __repr__(self):
        return '<itines_data %r>' % self.trackName

cors = CORS(app, resources={r"/api/*": {"origins": "*"}})

@app.before_first_request
def init_db():
    app.logger.debug('A value for debugging')
    update_db()

def update_db():
    url = 'https://itunes.apple.com/search?term=The+Beatles'
    response = requests.get(url)
    if response.status_code != 200:
        app.logger.info('%s -- status code from itunes', response.status_code)
        return response.status_code
    # itunes_data.id.cl
    # itunes_data.query.delete()
    for x in response.json()['results']:
        if x['wrapperType']=='track':
            var = itunes_data(kind = x['kind'],
                            collectionName =  x['collectionName'],
                            trackName = x['trackName'],
                            collectionPrice = x['collectionPrice'],
                            trackPrice = x['trackPrice'],
                            primaryGenreName = x['primaryGenreName'],
                            trackCount = x['trackCount'],
                            trackNumber = x['trackNumber'],
                            # releaseDate = datetime.strptime(x['releaseDate'], '%y-%m-%d"T"%H:%M:%S"Z"'))
                            releaseDate = x['releaseDate'])
            req = itunes_data.query.filter_by(trackName = var.trackName, 
                                            collectionName = var.collectionName,
                                            primaryGenreName = var.primaryGenreName).first()
            if req == None:
                db.session.add(var)
            else:
                req = var 
    db.session.commit()



@app.route('/api/update', methods=['GET'])
def update():
    update_db()
    return "OK"

@app.route('/health')
def health():
    return "OK"

@app.route('/')
def hello_world():
    return "<p>Hello! It is backend of itunes grabber app.</p>"

