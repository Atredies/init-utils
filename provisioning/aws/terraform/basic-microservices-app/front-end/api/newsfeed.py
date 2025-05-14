import iso8601
import json
from api.http import http_request

def datetime_parser(dct):
    for k, v in dct.items():
        if k == "date":
            dct[k] = iso8601.parse_date(v)
    return dct

class Newsfeed:
    def __init__(self, newsfeed_api_url, token, http_request=http_request):
        self.newsfeed_api_url = newsfeed_api_url
        self.token = token
        self.http_request = http_request

    def list(self):
        response = self.http_request(self.newsfeed_api_url + "/api/feeds", headers={
            "X-Auth-Token": self.token
        })

        return json.loads(response, object_hook=datetime_parser)
