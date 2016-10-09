import urllib.request #
from lxml import etree	# xml 관련 package
import requests
import json

# api_key data
api_key = ''
with open('api.json', encoding="UTF-8") as f :
	api_key = json.load(f)

client_id = api_key['client_id'] # client id(NAVER Application id)
client_secret = api_key['client_secret'] # client secret(NAVER Secret key)

url = 'https://openapi.naver.com/v1/search/blog.xml?'

params = urllib.parse.urlencode({'query': '남양주별내A11-1',	## 검색어
									'display' : 100,				## 보여지는 개수
									'start' : 101,				## 시작위치
									'sort' : 'sim'})			## 기본 default 설정

# header 설정
headers = {
    "X-Naver-Client-Id": client_id,
    "X-Naver-Client-Secret": client_secret,
}

# xml 형식으로 받음
res = requests.get(url+params, headers = headers)

## xml을 element 형식으로 변환
xp = etree.fromstring(res.content)

# print (res.content)
# get link tag
links = xp.xpath("//link/text()")

for lst in links[1:len(links)]:	## link get
	print (lst)