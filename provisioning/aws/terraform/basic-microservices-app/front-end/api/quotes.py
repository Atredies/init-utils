from api.http import http_request
import json

class Quotes:
    def __init__(self, quotes_api_url, http_request=http_request):
        self.quotes_api_url = quotes_api_url
        self.http_request = http_request

    def get_quote(self):
        response = self.http_request(self.quotes_api_url + "/api/quote")
        return json.loads(response)