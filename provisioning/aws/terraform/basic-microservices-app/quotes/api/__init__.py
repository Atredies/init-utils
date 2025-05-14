from flask import Flask
import json
import random


def create_app():
    with open('./resources/quotes.json', 'r') as f:
        quotes_data = json.load(f)

    app = Flask(__name__)

    @app.route("/ping")
    def ping():
        return "OK"

    @app.route("/api/quote")
    def quote_get():
        return random.choice(quotes_data)

    return app
