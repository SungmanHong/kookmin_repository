import requests
import lxml.html
from selenium.webdriver import Chrome
from selenium.webdriver import Firefox
from bs4 import BeautifulSoup
from urllib.parse import quote
import csv
from datetime import datetime
'''
1) naver 접속
2) login id(id = id) / pwd(id = pw) 후 로그인 버튼(class = btn_login submit)
3) cafe 아이콘 클릭 (class : tab_cafe)
4) 카페 리스트(class : svc_list/unread) 에서 http://cafe.naver.com/kookminlease 카페 접속
5) 접속 후 검색어(name = query) 에 각 단지 입력 후 검색(class : btn-search-green)
'''
base_url = 'http://cafe.naver.com/kookminlease.cafe?iframe_url='

## chrome 실행
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

cafe_url = "http://cafe.naver.com/kookminlease"
page_url = "http://cafe.naver.com"

chrome.implicitly_wait(50)
chrome.get(cafe_url)

search_input = chrome.find_element_by_xpath('.//input[@id="topLayerQueryInput"]')
search_text = '별내A22'
search_input.send_keys(search_text) # 검색어
encode_str = quote(search_text.encode('euckr'))

chrome.implicitly_wait(30)
chrome.execute_script('searchBoard();return false;')

chrome.implicitly_wait(30)
# print (chrome.page_source)
chrome.switch_to.frame('cafe_main')
# print(chrome.find_elements_by_xpath('.//a[@class="m-tcol-c"]'))
# //*[@id="main-area"]/div[7]/form/table/tbody/tr[10]/td[2]/span/span/a[1]


# print(soup.find(tag_=re.compile("dynamicParamLink")))
# id : tbody
soup_page = BeautifulSoup(chrome.page_source, "lxml")
page_navigation = soup_page.find('table', class_='Nnavi')
page_list= page_navigation.find_all('a')
date = soup_page.find_all('td', class_='view-count m-tcol-c')

start_date = datetime.strptime('20160330','%Y%m%d').date()
end_date = datetime.strptime('20160719','%Y%m%d').date()

with open(search_text+"_검색결과url.csv", 'w', encoding='euckr') as f:
    writer = csv.writer(f)
    for i in range(0,len(page_list)):
        if i==0:
            soup_body = BeautifulSoup(chrome.page_source, "lxml")
            span_list = soup_body.find_all("span", class_="aaa")
            reg_date = soup_body.find_all('td', class_='view-count m-tcol-c')

            for j in range(0,len(reg_date)):
                if "." in reg_date[j].text:
                    print(datetime.strptime(reg_date[j].text.replace('\n','').replace(' ',''),'%Y.%m.%d.').date())
                    if start_date <= datetime.strptime(reg_date[j].text.replace('\n','').replace(' ',''),'%Y.%m.%d.').date() <= end_date:
                        if j==0:
                            title_ = span_list[j].find('a').text
                            a_href = span_list[j].find('a')['href']
                            a_href = a_href.replace('?', quote('?'.encode('euckr')))
                            a_href = a_href.replace('&', quote('&'.encode('euckr')))
                            # print(a_href)
                            article_url = base_url+a_href

                            print(title_, article_url)
                            writer.writerow([title_, article_url])
                        else:
                            idx = round(j/2)
                            print(idx)
                            title_ = span_list[idx].find('a').text
                            a_href = span_list[idx].find('a')['href']
                            a_href = a_href.replace('?', quote('?'.encode('euckr')))
                            a_href = a_href.replace('&', quote('&'.encode('euckr')))
                            # print(a_href)
                            article_url = base_url + a_href

                            print(title_, article_url)
                            writer.writerow([title_, article_url])

        else:
            # print(page_list[i]['href'])
            chrome.get(page_url+page_list[i]['href'])
            chrome.switch_to.frame('cafe_main')
            soup_body = BeautifulSoup(chrome.page_source, "lxml")
            span_list = soup_body.find_all("span", class_="aaa")
            reg_date = soup_body.find_all('td', class_='view-count m-tcol-c')
            # print(reg_date)
            for j in range(0, len(reg_date)):
                if "." in reg_date[j].text:
                    print(datetime.strptime(reg_date[j].text.replace('\n','').replace(' ',''),'%Y.%m.%d.').date())
                    if start_date <= datetime.strptime(reg_date[j].text.replace('\n','').replace(' ',''),'%Y.%m.%d.').date() <= end_date:
                        if j==0:
                            title_ = span_list[j].find('a').text
                            a_href = span_list[j].find('a')['href']
                            a_href = a_href.replace('?', quote('?'.encode('euckr')))
                            a_href = a_href.replace('&', quote('&'.encode('euckr')))
                            # print(a_href)
                            article_url = base_url+a_href

                            print(title_, article_url)
                            writer.writerow([title_, article_url])
                        else:
                            idx = round(j/2)
                            title_ = span_list[idx].find('a').text
                            a_href = span_list[idx].find('a')['href']
                            a_href = a_href.replace('?', quote('?'.encode('euckr')))
                            a_href = a_href.replace('&', quote('&'.encode('euckr')))
                            # print(a_href)
                            article_url = base_url + a_href

                            print(title_, article_url)
                            writer.writerow([title_, article_url])

chrome.close()
## body 부분
# with open(search_text+"_검색결과url.csv", 'r', newline='\r\n', encoding='euckr') as f:
#     reader = csv.reader(f)
#     for row in reader:
#         # print(row[0])
#         chrome.get(row[0])
#         # print(BeautifulSoup(chrome.page_source))
#         chrome.switch_to.frame('cafe_main')
#         soup_body = BeautifulSoup(chrome.page_source, "lxml")
#         try :
#             article_body = soup_body.find('div',  {"id": "tbody"})
#             print(article_body.text)
#         except AttributeError as e:
#             print("Error row : "+row[0])
#         reply_tag = soup_body.find_all('span', class_='comm_body')
#         # print(reply_tag)
#         for reply in reply_tag:
#             print(reply.text)
