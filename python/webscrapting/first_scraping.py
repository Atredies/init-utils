import urllib
import urllib.request
from bs4 import BeautifulSoup
from csv import writer

# Open URL:
main_url = 'https://URL.here'
url = main_url
url_open = (urllib.request.urlopen(url))

# Define BS4:
soup  = BeautifulSoup(url_open, 'html.parser')

tickers = soup.findAll('tbody')

for ticker in tickers:
    ticker_name = ticker.find('td').get_text().replace('\n', '')
    lenght = len(ticker_name)
    print(ticker_name)
