import MySQLdb as connector
from singleton import singleton

class MySQLConnect:
	'''
	MySQL Connection Class
	__init__ : Class 생성시 생성자를 의미
		paramaeter : host - server hosting 정보
					 user - mysql 접속 아이디
					 password - mysql 접속 비밀번호
					 db - mysql database 이름

	__del__ : 자원회수용
	__call__ : instance 호출 용(중복 호출을 막기위함?)
	getRecord : 조회용 함수
		parameter : column - 조회 컬럼(SELECT 제외)
					table - 조회 테이블(FROM 제외)
					where - where문 (WHERE 제외)
	'''
	__metaclass__ = singleton
	def __init__(self, host, user, password, db):
		self.dbConnection = ''
		try :
			self.dbConnection = connector.Connect(host = host, user = user, passwd = password, db = db, charset='utf8')
		except MySQLdb.OperationalError as e :
			print (e)
		self.dbCursor = self.dbConnection.cursor(cursorclass=connector.cursors.DictCursor)

	def __del__(self):
		print ("del")
		self.dbCursor.close()
		self.dbConnection.close()

	def __call__(self, *args, **kw):
		if self.instance is None:
			self.instance = super(singleton, self).__call__(*args, **kw)
		return self.instance

	def getRecord(self, column, table, where = None) :
		query = ""
		select_str = "select "
		from_str = "from "
		result = None

		query += select_str
		# 조회 컬럼 column
		if column:
			query += column
		query += from_str
		# table
		if table:
			query += table
		# where 조건이 들어올 경우
		if where:
			query += " WHERE %s" % where

		self.dbCursor.execute(query)
		result = self.dbCursor.fetchall()
		return result