from flask import Flask
import os

application_id=2
app = Flask(__name__)

@app.route('/')
def my_app():
    return f'Application {application_id}'

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.environ.get("PORT", 80)))
