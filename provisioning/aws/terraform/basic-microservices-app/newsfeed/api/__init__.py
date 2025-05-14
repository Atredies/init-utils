from flask import Flask, request, jsonify
from functools import wraps


def token_required(valid_tokens):
    def _token_required(f):
        @wraps(f)
        def decorator(*args, **kwargs):
            token = None
            if "X-Auth-Token" in request.headers:
                token = request.headers["X-Auth-Token"]
            if not token or token not in valid_tokens:
                return {"error": "Invalid auth token"}, 403

            return f(*args, **kwargs)
        return decorator
    return _token_required


def create_app(valid_tokens, newsfeed):
    app = Flask(__name__)

    @app.route("/ping")
    def ping():
        return "OK"

    @app.route("/api/feeds")
    @token_required(valid_tokens)
    def feeds_get():
        return jsonify(newsfeed.list())

    return app
