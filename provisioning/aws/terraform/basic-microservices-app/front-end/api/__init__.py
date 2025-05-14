from flask import Flask, render_template


def create_app(newsfeed, quotes, static_url=""):
    app = Flask(__name__)
    app.config["STATIC_URL"] = static_url

    @app.route("/ping")
    def ping():
        return "OK"

    @app.route("/")
    def home():
        return render_template(
            "home.html",
            quote=quotes.get_quote(),
            news=newsfeed.list()
        )

    return app
