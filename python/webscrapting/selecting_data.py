import urllib
import urllib.request
from bs4 import BeautifulSoup

# Open URL:
main_url = 'https://URL.here'
url = main_url
url_open = (urllib.request.urlopen(url))

# Define BS4:
soup  = BeautifulSoup(url_open, 'html.parser')

# How to select things directly:
print(soup.body) 
print(soup.head)
print(soup.title)
# Usually you are not going to select things this way. 

# Usually it is better to use find:

# find()
sf = soup.find('div') # If you use .find - it only lists the first one it finds
print(sf)

# findAll() or find_all()
fa = soup.findAll('div') # This works just as an array so,
# if you want to get the second div use [1]. Example: fa = soup.findAll('div')[1]
print(fa)

# find ID if ID is = to something
fi = soup.find(id='section-1')
print(fi)

# find CLASS if CLASS is = to something
#fc = soup.find(class='items') - This will generate a syntax error as Class is reserved
fc = soup.find(class_='items') # To get around this error just place use class_
print(fc)

# To find by attribute: (Usually something like H3)
fatt = soup.find(attrs={"data-hello":"hi"})
print(fatt)

#SELECT - Always is returned in a list 
sel = soup.select('.item')[0] # It always requires an index
print(sel)

# Usually you do not care about the HTML and just want the data.
# For that: get_text()
get = soup.find('tr').get_text()
print(get)

# These can also be looped:
for item in soup.select('tr'):
    print(item.get_text())




