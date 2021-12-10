import urllib
import urllib.request
from bs4 import BeautifulSoup

# Open URL:
main_url = 'https://URL.here'
url = main_url
url_open = (urllib.request.urlopen(url))

# Define BS4:
soup  = BeautifulSoup(url_open, 'html.parser')

# Finds the content of the body
el = soup.body.contents[1]
#print(el)

# You are able to string these together
# Next sibling - finds next element
# Previous sibling - finds previous element
fs = soup.body.contents[1].contents[1].find_next_sibling()
#print(fs)

ps = soup.find('div').find_previous_sibling()
#print(ps)

# This can be done also for paragraphs:
np = soup.find('div').find_next_sibling('p')
print(np)