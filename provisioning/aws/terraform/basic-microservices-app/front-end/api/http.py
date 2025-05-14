from urllib.request import urlopen, Request

def http_request(url, headers={}):
    request = Request(url, headers=headers)
    
    with urlopen(request) as response:
        data = response.read().decode("utf-8")
    
    return data