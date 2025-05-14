import json


def test_ping_returns_200_OK(client):
    response = client.get("/ping")
    assert response.status_code == 200
    assert b"OK" in response.data


def test_quote_returns_200_with_a_quote(client):
    response = client.get("/api/quote")
    assert response.status_code == 200

    response_data = json.loads(response.get_data(as_text=True))

    assert "quote" in response_data
    assert "author" in response_data
