from selenium.webdriver import Firefox
from bs4 import BeautifulSoup
from urllib.parse import quote
import csv
from datetime import datetime
import pandas as pd
from matplotlib import pyplot
import requests
import lxml.html  # url 요청에 대한 html 형식 처리


def extract(url, path):
    '''xpath 추출 함수'''
    res = requests.get(url)
    res.encoding = 'euckr'
    root = lxml.html.fromstring(res.text)
    # print(root.xpath(path).text_content())
    return root.xpath(path)


article_url = []
for i in range(1,19):
    print(i)
    with open('all_data/a'+str(i)+'.csv', 'r', newline='\r\n', encoding='euckr') as f:
        reader = csv.reader(f)
        for row in reader:
            # print(row[1])
            article_url.append(row[1])

# with open('남양주전체.txt', 'r' ,encoding='utf8') as f:
#     article_url.append(f.readline())

print(article_url)

chrome = Firefox()
chrome.get('http://naver.com')
## login 위한 id/pwd/login button 정보 get
id_txt = chrome.find_element_by_xpath('.//input[@id="id"]')
pw_txt = chrome.find_element_by_xpath('.//input[@id="pw"]')
login_btn = chrome.find_element_by_xpath('.//span[@class="btn_login"]')

## id/pwd 정보 set 후 login
id_txt.send_keys('korea7030')
pw_txt.send_keys('akachiki10!')
login_btn.submit()

chrome.implicitly_wait(50)

for article in article_url:
    chrome.get(article)
    chrome.switch_to.frame('cafe_main')
    soup_body = BeautifulSoup(chrome.page_source, "lxml")
    try:
        with open('content.csv', 'a', encoding='utf8') as f:
            writer = csv.writer(f)
            article_body = soup_body.find('div', {"id": "tbody"})
            print(article_body.text)
            writer.writerow([article_body.text])

            reply_tag = soup_body.find_all('span', class_='comm_body')
            for reply in reply_tag:
                with open('reply.csv', 'a', encoding='utf8') as f:
                    writer_reply = csv.writer(f)
                    print("reply text : -----------" + reply.text)
                    writer_reply.writerow([reply.text])

    except AttributeError as e:
        print("Error row : " + article)

        # print(reply_tag)
chrome.close()

