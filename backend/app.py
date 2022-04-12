import requests
import xml.etree.ElementTree as ET
from datetime import datetime, timedelta
from flask import Flask
from flask_cors import CORS
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
# from dotenv import load_dotenv
#from prometheus_flask_exporter import PrometheusMetrics
import os

app = Flask(__name__)
# load_dotenv('../.env')
# metrics = PrometheusMetrics(app)

app.config['SQLALCHEMY_DATABASE_URI'] = "mysql://" \
    +os.getenv('DB_USER') \
    +":"+os.getenv('DB_USER_PASS') \
    +'@'+os.getenv('DB_HOST') \
    +'/'+os.getenv('DB_NAME')
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)
migrate = Migrate(app, db)

class itunes_data(db.Model):
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    kind = db.Column(db.String(50), nullable=False)
    collectionName = db.Column(db.String(50), nullable=False)
    trackName = db.Column(db.String(50), nullable=False)
    collectionPrice = db.Column(db.Float)
    trackPrice = db.Column(db.Float)
    primaryGenreName = db.Column(db.String(50), nullable=False)
    trackCount = db.Column(db.Integer)
    trackNumber = db.Column(db.Integer)
    releaseDate = db.Column(db.Date)

    # date = db.Column(db.Date)
    # ValuteID = db.Column(db.String(16))
    # NumCode = db.Column(db.Numeric(8))
    # CharCode = db.Column(db.String(8))
    # Nominal = db.Column(db.Integer())
    # Name = db.Column(db.String(300))
    # Value = db.Column(db.Float(12,4))
    # db.UniqueConstraint(date, ValuteID)

cors = CORS(app, resources={r"/api/*": {"origins": "*"}})


def update_db():
    import os
    import mysql.connector
    url = 'https://itunes.apple.com/search?term=The+Beatles' 
    response = requests.get(url)
    if response.status_code != 200:
        return response.status_code
    # connection = mysql.connector.connect(user=os.getenv('DB_USER'),
    # password = os.getenv('DB_USER_PASS'),
    # host=os.getenv('DB_HOST'),
    # database=os.getenv('DB_NAME'))
    # values = [list(x.values()) for x in parse(url)]
    # columns = [list(x.keys()) for x in parse(url)][0]
    # values_str = ""
    # for i, record in enumerate(values):
    #     val_list = []
    #     for v, val in enumerate(record):
    #         if type(val) == str:
    #             val = "'{}'".format(val.replace(",", "."))
    #         val_list += [ str(val) ]
    #     values_str += "(" + ', '.join( val_list ) + "),\n"
    # values_str = values_str[:-2] + ";"
    # table_name = "itunes_data"
    # sql_string = "INSERT IGNORE INTO %s (%s)\nVALUES\n%s" % (
    #     table_name,
    #     ', '.join(columns),
    #     values_str
    # )
    # with connection.cursor() as cursor:
    #     cursor.execute(sql_string)
    #     connection.commit()


@app.route('/api/update', methods=['GET'])
def update():
    # update_db()
    return "OK"

@app.route('/health')
def health():
    return "OK"

@app.route('/')
def hello_world():
    return "<p>Hello! It is backend of itunes grabber app.</p>"

