import pandas as pd
from MySQLConnect import MySQLConnect # class import

if __name__ == '__main__':
	host = 'kookmindb.czypjmusens3.ap-northeast-2.rds.amazonaws.com'
	user = 'KMaster'
	password = 'kookmin1234'
	db = 'km_db'

	# DB 연결
	dc = MySQLConnect(host, user, password, db)

	# 데이터 조회(LEASE_DATA에 SEQ_=1 인 것만) test222
	result = dc.getRecord("*", "LEASE_DATA", "A_6 = '26형'")
	print (pd.DataFrame(list(result)))