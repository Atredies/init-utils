from api import create_app
from api.newsfeed import Newsfeed
from api.quotes import Quotes
from os import environ

NEWSFEED_SERVICE_URL = environ.get(
    "NEWSFEED_SERVICE_URL",
    "http://localhost:8081"
)
QUOTE_SERVICE_URL = environ.get(
    "QUOTE_SERVICE_URL",
    "http://localhost:8082"
)

NEWSFEED_SERVICE_TOKEN = environ.get("NEWSFEED_SERVICE_TOKEN")

app = create_app(
    Newsfeed(NEWSFEED_SERVICE_URL, NEWSFEED_SERVICE_TOKEN),
    Quotes(QUOTE_SERVICE_URL),
    static_url=environ.get("STATIC_URL", "")
)
