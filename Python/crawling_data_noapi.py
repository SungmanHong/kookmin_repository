import requests
import lxml.html
from urllib.parse import quote
import math

def extract(url, path):
    res = requests.get(url)
    res.encoding = 'utf-8'
    # print ("res text : "+res.text)
    root = lxml.html.fromstring(res.text)
    try :
            xpath_str = root.xpath(path) # print("extract function result : "+root.xpath(path)[0].text_content())
    except Exception as e:
        print ("exception : "+e.args)
    return xpath_str

def get_last_page(url):
    ''' 마지막 페이지를 불러오는 함수'''
    res_num = requests.get(url)
    num_root = lxml.html.fromstring(res_num.text)
    count = num_root.xpath('.//span[@class="title_num"]/text()')
    print (count)
    tmp = count[0]
    # .replace("\r",'').replace("\n",'').replace("\t",'') # 전체 건수 뽑기
    return math.ceil(int((tmp.split(' / ')[1].split('건')[0]).replace(',','')) / 10)
    # return tmp
    # 10 : 페이지당 기사건수


start_date = input("시작 일자를 입력하세요(형식 : YYYY-MM-DD) : ")
end_date = input("끝 일자를 입력하세요(형식 : YYYY-MM-DD) : ")
query_string = input("검색어를 입력하세요 :")

# 검색어 날짜 처리
remove_slash_start = start_date.replace("-", "")
remove_slash_end = end_date.replace("-","")

url_1 = "https://search.naver.com/search.naver?where=post&query="
# encode_string =  quote(query_string,"euc-kr")
encode_string =  query_string
print(encode_string) # %EB%B3%84%EB%82%B4A11-1
url_2 = "&ie=utf8&st=sim&sm=tab_opt&"
url_3 = "date_from="+remove_slash_start+"&date_to="+remove_slash_end+"&date_option=8&srchby=all&dup_remove=1&post_blogurl=&post_blogurl_without=&nso=p%3Afrom"+remove_slash_start+"to"+remove_slash_end
article_xpath = ".//a[@class='sh_blog_title _sp_each_url _sp_each_title']"
page_str = "&ie=utf8&start={}"

url = url_1+encode_string+url_2+url_3
# print (url)
lastpage = get_last_page(url)
# print (lastpage)
content_list = []
for page in range(1, lastpage+1):
    page_url = url+page_str.format(page)
    print(page_url)
    for node in extract(page_url, article_xpath):
        title = node.text_content()
        content_url = node.attrib['href']
        # print (title, content_url)
        content_list.append(content_url)
        # print (content_list)

## content
print(len(content_list))
# for con_url in content_list:
#     if "tistory.com" in con_url:
#         # print (1)
#         try :
#             post_content = extract(con_url, './/div[@class="article"]')[0]
#             print("----------------------------------------------------------------------------------------------")
#             print(content_url)
#             print(post_content.text_content())
#             print("----------------------------------------------------------------------------------------------")
#         except Exception as e:
#             print (e)
#     elif "blog.naver.com" in con_url:
#         print(str(2) + "   :    " + con_url)
#         try :
#             post_content = extract(con_url, './/div[@id="postViewArea"]/text()')[0]
#         except Exception as e:
#             print (e)
#         # print(post_content.text_content())
#     elif "housenhows.blog.me" in con_url:
#         continue
#         # print(post_content.text_content())