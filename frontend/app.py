from flask import Flask, render_template
import os
import MySQLdb
from prometheus_flask_exporter import PrometheusMetrics
import requests

app = Flask(__name__, static_url_path='/static')

metrics = PrometheusMetrics(app)

def connection():
    conn = MySQLdb.connect(host=os.getenv('mysql_host'),
                           user=os.getenv('mysql_user'),
                           passwd=os.getenv('mysql_password'),
                           db = os.getenv('mysql_db'),
                           charset='utf8')
    c = conn.cursor()
    return c, conn

@app.route('/')
def index():
    try:
        c, conn = connection()
        query = "SELECT date, ValuteID, NumCode, CharCode, Nominal, Name, Value from cbr WHERE MONTH(date) = MONTH(CURRENT_DATE())AND YEAR(date) = YEAR(CURRENT_DATE()) ORDER BY name ASC, date ASC;"
        c.execute(query)
        data = c.fetchall()
        conn.close()
        return render_template("index.html", data=data)
        return data
    except Exception as e:
        return (str(e))

@app.route('/update', methods=['GET'])
def update_be():
    response = requests.get(os.getenv('be-url'))
    return "ok"
