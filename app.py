from flask import Flask

app = Flask(__name__)

# demonstrate db infofmation
@app.route("/")
def hello_world():
    return "<p>Hello, World!</p>"

# button press processor
