import json


def test_ping_returns_200_OK(client):
    response = client.get("/ping")
    assert response.status_code == 200
    assert b"OK" in response.data


def test_api_returns_404_when_valid_token_given_but_invalid_route(client):
    response = client.get(
        "/api/404",
        headers={"X-Auth-Token": "valid"}
    )
    assert response.status_code == 404


def test_feeds_returns_403_when_no_token_given(client):
    response = client.get("/api/feeds")
    assert response.status_code == 403


def test_feeds_returns_403_when_invalid_token_given(client):
    response = client.get(
        "/api/feeds",
        headers={"X-Auth-Token": "invalid"}
    )
    assert response.status_code == 403


def test_feeds_returns_404_when_valid_token_given_but_invalid_route(client):
    response = client.get(
        "/api/feeds",
        headers={"X-Auth-Token": "valid"}
    )
    assert response.status_code == 200

    response_data = json.loads(response.get_data(as_text=True))

    assert len(response_data) == 1
    assert response_data[0]["content"] == "Hello, World!"
