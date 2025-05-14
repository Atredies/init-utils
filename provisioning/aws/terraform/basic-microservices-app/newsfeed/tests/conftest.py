import pytest
from api import create_app


@pytest.fixture
def tokens():
    return ["valid"]


@pytest.fixture
def newsfeed():
    class StubNewsfeed:
        def list(self):
            return [{
                "author": "/u/AutoModerator",
                "content": "Hello, World!",
                "id": "t3_vghwqp",
                "link": "https://www.reddit.com/r/sysadmin/comments/vghwqp/moronic_monday_june_20_2022/",
                "updated": "2022-06-20T10:00:11+00:00",
                "published": "2022-06-20T10:00:11+00:00",
                "title": "Moronic Monday - June 20, 2022"
            }]

    return StubNewsfeed()


@pytest.fixture
def app(tokens, newsfeed):
    return create_app(tokens, newsfeed)


@pytest.fixture()
def client(app):
    return app.test_client()
