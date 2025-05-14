import pytest
import iso8601
from api import create_app

@pytest.fixture
def newsfeed():
    class StubNewsfeed:
        def list(self):
            return [{
                "title": "Example one",
                "date": iso8601.parse_date("2022-04-03T15:32:00Z"),
                "authors": [{
                    "name": "First person"
                }, {
                    "name": "Second person"
                }],
                "link": "http://example.com/post-1",
                "source": {
                    "title": "My blog",
                    "link": "http://example.com",
                    "image": None
                }
            }, {
                "title": "Example two",
                "date": iso8601.parse_date("2022-04-03T14:09:00Z"),
                "authors": [{
                    "name": "First person"
                }],
                "link": "http://example.com/post-2",
                "source": {
                    "title": "Somewhere else",
                    "link": "http://example.com",
                    "image": None
                }
            }]

    return StubNewsfeed()

@pytest.fixture
def quotes():
    class StubQuotes:
        def get_quote(self):
            return {
                "quote": "The quote content",
                "author": "The quote author"
            }

    return StubQuotes()


@pytest.fixture
def app(newsfeed, quotes):
    return create_app(newsfeed, quotes)


@pytest.fixture()
def client(app):
    return app.test_client()
