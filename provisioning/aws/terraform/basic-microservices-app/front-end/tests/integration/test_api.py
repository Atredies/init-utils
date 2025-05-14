import json


def test_ping_returns_200_OK(client):
    response = client.get("/ping")
    assert response.status_code == 200
    assert b"OK" in response.data


def test_api_returns_404_when_invalid_route_requested(client):
    response = client.get("/404")
    assert response.status_code == 404
    

def test_home_renders_template_with_newsfeed(client):
    response = client.get("/")
    assert response.status_code == 200

    response_data = response.get_data(as_text=True)

    assert "<a href=\"http://example.com/post-1\">Example one</a>" in response_data
    assert "<a href=\"http://example.com/post-2\">Example two</a>" in response_data

def test_home_renders_template_with_quote(client):
    response = client.get("/")
    assert response.status_code == 200

    response_data = response.get_data(as_text=True)

    assert "<p>The quote content</p>" in response_data
    assert "<footer>The quote author</footer>" in response_data