from api.newsfeed import Newsfeed
import datetime

BASE_URL = "http://example.com"
AUTH_TOKEN = "token"

def test_list_returns_response_from_newsfeed_api():
    was_called = False
    def stub_http_request(url, headers):
        nonlocal was_called
        was_called = True

        assert url == BASE_URL + "/api/feeds"
        
        return """[{
            "title": "An article"
        }]"""
    
    service = Newsfeed(BASE_URL, AUTH_TOKEN, stub_http_request)
    feed = service.list()
    
    assert was_called
    assert len(feed) == 1
    assert feed[0]["title"] == "An article"

def test_list_sends_auth_token_to_api():
    was_called = False
    def stub_http_request(url, headers):
        nonlocal was_called
        was_called = True

        assert headers["X-Auth-Token"] == AUTH_TOKEN
        
        return "[]"
    
    service = Newsfeed(BASE_URL, AUTH_TOKEN, stub_http_request)
    service.list()
    
    assert was_called

def test_list_parses_dates_from_the_response():
    was_called = False
    def stub_http_request(url, headers):
        nonlocal was_called
        was_called = True

        return """[{
            "title": "An article",
            "date": "2022-04-05T00:25:43Z"
        }]"""
    
    service = Newsfeed(BASE_URL, AUTH_TOKEN, stub_http_request)
    feed = service.list()
    
    assert was_called
    assert len(feed) == 1
    assert feed[0]["date"] == datetime.datetime(2022, 4, 5, 0, 25, 43, tzinfo=datetime.timezone.utc)