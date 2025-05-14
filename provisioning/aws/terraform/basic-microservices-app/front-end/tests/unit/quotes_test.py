from api.quotes import Quotes

BASE_URL = "http://example.com"

def test_get_quote_returns_response_from_quotes_api():
    def stub_http_request(url):
        assert url == BASE_URL + "/api/quote"
        
        return """{
            "author": "Author name",
            "quote": "The Quote"
        }"""
    
    service = Quotes(BASE_URL, stub_http_request)
    quote = service.get_quote()
    
    assert quote["author"] == "Author name"
    assert quote["quote"] == "The Quote"