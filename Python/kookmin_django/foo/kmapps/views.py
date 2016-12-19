# -*- coding: utf-8 -*-
from django.shortcuts import render # page 그리기
from kmapps.forms import InputForm # form
import logging	# log
import json # json 만드는 모듈
import subprocess # R 실행위한 모듈
import os
import csv # csv file save
from django.core.serializers.json import DjangoJSONEncoder
import sys

# from chartit import DataPool, Chart

# from fusioncharts import FusionCharts
# Create your views here.

def index(request):
	''' main index page '''

	# if request.method == "POST":
	# else:
	form_class = InputForm()
	return render(request, 'kmapps/index.html', {'form': form_class})

def callRScript(commandstr, Rfilename):
	cmd = [commandstr, Rfilename,"-e", "--encoding", "utf-8"]
	# result = ''
	# x = subprocess.check_output(cmd, universal_newlines=True, shell=False, stdin=subprocess.PIPE)
	# reload(sys)
	# sys.setdefaultencoding('UTF8')
	proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
	out, err = proc.communicate()
	print(err)

	res = out.decode('utf8')
	ret = res.split('+')

	# print(result)
	return ret[1]

def makeTestFile(dic_data, filename):
	## test data 저장(csv)
	with open(filename, 'w', encoding='utf-8') as csv_file:
		writer = csv.writer(csv_file)
		writer.writerow(list(dic_data.keys()))
		row_lst = []
		for k in dic_data.keys():
			row_lst.append(dic_data[k])
		writer.writerow(row_lst)

def makeOutput(model, length):

	command = 'C:/Program Files/R/R-3.3.2/bin/Rscript.exe'
	path2script = os.getcwd()+'\\kmapps\\R\\TEST.R'	## 경로 지정 확인...

	x_lst = []
	sr_lst = []

	if (os.path.exists('C:/apps/foo/model_lst.txt')):
		try:
			os.remove('C:/apps/foo/model_lst.txt')	## 삭제 후
			with open('model_lst.txt', 'w', encoding='utf-8') as f:
				f.write(",".join(map(lambda x: str(x), model)))

		except OSError:
			pass
	else:
		with open('model_lst.txt', 'w', encoding='utf-8') as f:
				f.write(",".join(map(lambda x: str(x), model)))

	res = callRScript(command, path2script)

	if (res == "success"):
		if (os.path.exists(os.getcwd()+'\\kmapps\\R\\x_data.json') and os.path.exists(os.getcwd()+'\\kmapps\\R\\series_data.json')) :
			with open(os.getcwd()+'\\kmapps\\R\\x_data.json', 'r', encoding='utf-8') as x_data_file:
				x_lst = json.load(x_data_file)

			with open(os.getcwd()+'\\kmapps\\R\\series_data.json', 'r', encoding='utf-8') as series_file:
				sr_lst = json.load(series_file)

	else:
		x_lst.insert(0,"error")
		sr_lst.insert(0, {'data' : 0 , 'name' : 'error'})

	return x_lst, sr_lst

def results(request):
	if request.method == "POST":
		form_data = InputForm(request.POST)
		if form_data.is_valid():
			############## 입력 데이터 ##############
			name = request.POST["Q_0_0"] ## 사용자 이름 입력
			block = request.POST['Q_0_1'] ## 단지명
			W_13 = request.POST["Q_1"]
			W_16 = request.POST["Q_2"]
			W_29 = request.POST["Q_3"]
			W_25 = request.POST["Q_4"]
			W_27 = request.POST["Q_5"]
			W_30 = request.POST["Q_6"]
			W_17 = request.POST["Q_7"]
			W_31 = request.POST["Q_8"]
			W_36 = request.POST["Q_9"]
			wa8_weakYN = request.POST["Q_10"]
			W_24 = request.POST["Q_11"]
			W_28 = request.POST["Q_12"]
			A_47 = request.POST["Q_13"]
			W_15 = request.POST["Q_14"]
			Q_15_0 = request.POST["Q_15_0"]	## 결혼여부
			W_38='';W_40='';W_41=0

			if (Q_15_0 == 'Y'):
				W_38 = request.POST["Q_15"]
				W_40 = request.POST["Q_16"]
				W_41= request.POST["Q_17"]
			else:
				W_38 = 'N'
				W_40 = 'N'
				W_41= 0
			# W_24 = int(W_24)

			## 파생변수 데이터
			add_data = {'Price.percent' : 0.512108243, 'num.Apt' : 31471, 'subway.km' : 1.6, 'walk.YN' : 'n', 'num.House' : 214763, 'facility_near' : 0.5, 'hospital_near_km' : 9.49, 'hospital_near_min' : 46, 'supply_tot' : 1058, 'news_3month' : 15, 'news_6month' : 16, 'supply.ratio' : 1.36677681, 'supply.counts' : 91}

			##########################################
			#
			## 추가 변수
			W_18=''
			wa1_age=0
			wa2_fam=''
			wa3_liveterm=0
			wa4_child=0
			wa5_direct=0
			wa6_fac=0
			wa7_construct=0
			wa9_weakscore=0
			wa10_application=0
			W_39=''

			## 총점 점수 관련 변수(W_20 : 장애인,고령자 / 신혼부부 , W_21 : 일반공급)
			W_20=0
			W_21=0

			#################### set model select variable ##################
			# elder_yn : 고령자여부(65세이상인경우)
			# km_yn : 국민임대대상여부
			# not40_yn : 40형이상제외여부
			# disabled_yn : 장애인여부
			# married_yn : 신혼부부여부
			#################################################################
			elder_yn="";km_yn="";not40_yn="";disabled_yn="";married_yn=""

			## 결과저장
			series_lst = []
			x_data_lst = []

			## 모델명 저장할 리스트
			model_lst = []

			## 신청순위
			if (W_13 == '1st'):
				W_18 = 'RESI'
			elif (W_13 == '2nd'):
				W_18 = 'N_RESI'
			else:
				W_18 = 'N_RESI'

			## 월소득평균(국민임대 자격여부 결정)
			if (W_16 == 'Y'):
				km_yn = 'Y'
			elif (W_16 == 'n'):
				km_yn = 'N'

			## 신청자 나이를 통한 파생변수 세팅(고령자여부 결정)
			if (int(W_29) >= 65) :
				wa1_age = 3
				elder_yn = 'Y'
			elif (int(W_29) in range(50,65)):
				wa1_age = 3
				elder_yn = 'N'
			elif (int(W_29) in range(40,50)):
				wa1_age = 2
				elder_yn = 'N'
			elif (int(W_29) in range(30,40)):
				wa1_age = 1
				elder_yn = 'N'

			## 부양가족수 관련(0:해당없음 이면 40형 이상제외)
			wa2_fam = W_25
			if (wa2_fam == '0'):
				not40_yn = "Y"
			else:
				not40_yn = "N"

			## 당해거주기간
			if (int(W_27) >= 5):
				wa3_liveterm = 3
			elif (int(W_27) in range(3,5)):
				wa3_liveterm = 2
			elif (int(W_27) in range(1,3)):
				wa3_liveterm = 1

			## 65세이상 직계존속 부양여부
			if (W_30 == 'Y'):
				wa5_direct = 3
			else:
				wa5_direct = 0

			## 미성년자녀수
			if (int(W_17) == '3'):
				wa4_child = 3
			elif (int(W_17) == '2'):
				wa4_child = 2
			elif (int(W_17) == '1'):
				wa4_child = 0
			elif (int(W_17) == '0'):
				wa4_child = 0

			## 중소기업중 제조업
			if (W_31 == 'Y'):
				wa6_fac = 3
			else:
				wa6_fac = 0

			## 건설근로자
			if (W_36 == 'Y'):
				wa7_construct = 3
			else:
				wa7_construct = 0

			## 사회취약계층
			if (wa8_weakYN == 'Y'):
				wa9_weakscore = 3
			elif (wa8_weakYN == ' '):
				wa8_weakYN = ''
				wa9_weakscore = 0

			## 주택청약 납입 인정횟수
			if (int(W_28)>= 60):
				wa10_application = 3
			elif (int(W_28) in range(48,60)):
				wa10_application = 2
			elif (int(W_28) in range(36,48)):
				wa10_application = 1

			## 장애여부 해당없음 시 장애인  모델 제외
			if (W_15 == 'N'):
				disabled_yn = 'N'
			else:
				disabled_yn = 'Y'

			## 혼인기간(기간 해당이 안될 경우 조건없음)
			if (W_38 == 'N'):
				married_yn = 'N'
			elif (int(W_38) in range(0,4)):
				W_39 = '1st'
				married_yn = 'Y'
			elif (int(W_38) in range(4,6)):
				W_39 = '2nd'
				married_yn = 'Y'

			########### 우선/일반 총점 계산 ##################################################
			# 우선인 경우는 우선점수와 탈락을 예상하여 일반 점수도 같이 부여
			# 일반인 경우 우선점수는 0점 처리
			# ################################################################################
			if (elder_yn == 'Y' or disabled_yn == 'Y'):
				W_20 = wa1_age+int(wa2_fam)+wa3_liveterm+wa4_child+wa7_construct+wa10_application+int(W_24)
				W_21 = wa1_age+int(wa2_fam)+wa3_liveterm+wa4_child+wa5_direct+wa6_fac+wa7_construct+wa9_weakscore+wa10_application+int(W_24)
			elif (married_yn == 'Y'):
				W_20 = wa1_age+int(wa2_fam)+wa3_liveterm+wa4_child+wa5_direct+wa6_fac+wa7_construct+wa9_weakscore+wa10_application+int(W_24)
				W_21 = wa1_age+int(wa2_fam)+wa3_liveterm+wa4_child+wa5_direct+wa6_fac+wa7_construct+wa9_weakscore+wa10_application+int(W_24)
			elif (elder_yn == 'N' and disabled_yn == 'N' and married_yn == 'N'):
				W_20 = 0
				W_21 = wa1_age+int(wa2_fam)+wa3_liveterm+wa4_child+wa5_direct+wa6_fac+wa7_construct+wa9_weakscore+wa10_application+int(W_24)
			##################################################################################

			print(W_38)
			dic_data = {
				'A_47' : A_47,
				'W_13' : W_13,
				'W_15' : W_15,
				'W_16' : W_16,
				'W_17' : W_17,
				'W_18' : W_18,
				'W_20' : W_20,
				'W_21' : W_21,
				'W_24' : W_24,
				'W_25' : W_25,
				'W_27' : W_27,
				'W_28' : W_28,
				'W_29' : W_29,
				'W_30' : W_30,
				'W_31' : W_31,
				'W_36' : W_36,
				'W_38' : W_38,
				'W_39' : W_39,
				'W_40' : W_40,
				'W_41' : W_41,
				'wa1_age' : wa1_age,
				'wa2_fam' : wa2_fam,
				'wa3_liveterm' : wa3_liveterm,
				'wa4_child' : wa4_child,
				'wa5_direct' : wa5_direct,
				'wa6_fac' : wa6_fac,
				'wa7_construct' : wa7_construct,
				'wa8_weakYN' : wa8_weakYN,
				'wa9_weakscore' : wa9_weakscore,
				'wa10_application' : wa10_application,
				## 파생 데이터 추가 필요
				#add_data = {'Price.percent' : 0.512108243, 'num.Apt' : 31471, 'subway.km' : 1.6, 'walk.YN' : 'n', 'num.House' : 214763, 'facility_near' : 0.5, 'hospital_near_km' : 9.49, 'hospital_near_min' : 46, 'supply_tot' : 1058, 'news_3month' : 15, 'news_6month' : 16, 'supply.ratio' : 1.36677681, 'supply.counts' : 91}
				'Price.percent' : add_data['Price.percent'],
				'num.Apt' : add_data['num.Apt'],
				'subway.km' : add_data['subway.km'],
				'walk.YN' : add_data['walk.YN'],
				'num.House' : add_data['num.House'],
				'facility_near' : add_data['facility_near'],
				'hospital_near_km' : add_data['hospital_near_km'],
				'hospital_near_min' : add_data['hospital_near_min'],
				'supply_tot' : add_data['supply_tot'],
				'news_3month' : add_data['news_3month'],
				'news_6month' : add_data['news_6month'],
				'supply.ratio' : add_data['supply.ratio'],
				'supply.counts' : add_data['supply.counts']
			}

			## form 형태로 받을 경우
			# dic_data = request.POST.dict()	# dictionary 형태로 변환
			# keys = set(dic_data.keys())
			# excludes_key = set(['csrfmiddlewaretoken','submit'])
			# sub_dic = {key : dic_data[key] for key in dic_data if key not in excludes_key}	 # 빼고자하는 key 뺸 후 저장

			## 기존 test파일이 있으면 삭제 후 생성
			if (os.path.exists('C:/apps/foo/test.csv')):
				try:
					os.remove('C:/apps/foo/test.csv')	## 삭제 후
					makeTestFile(dic_data, 'test.csv')	## 다시생성
				except OSError:
					pass
			else:
				makeTestFile(dic_data, 'test.csv')	## 새로 생성

			## 소득 70% 초과면 모델 실행 안하고 바로 0% 출력
			if (W_16 == 'Y'):
				x_data_lst.insert(0,'no_model')
				series_lst.insert(0, {'data' : 0 , 'name' : 'error'})
			else:
				# res = callRScript(command, path2script)
				if ((elder_yn == 'Y' and disabled_yn == 'Y') and not40_yn == 'N') :
					## 고령자 이면서 장애인이면서 40형 이하(미만) 모델만 실행(일반 포함)
					'''
						disabled_26_gbm, disabled_36_rf, highage_26_rf , highage_36_rf, general_26_rf, general_36_rf 모델변수 지정
					'''
					model_lst.append('disabled_26_gbm')
					model_lst.append('disabled_36_rf')
					model_lst.append('highage_26_rf')
					model_lst.append('highage_36_rf')
					model_lst.append('general_26_rf')
					model_lst.append('general_36_rf')

					x_data_lst = x_data_lst*len(model_lst)
					series_lst = series_lst*len(series_lst)

					x_data_lst, series_lst =  makeOutput(model_lst, len(model_lst))
				elif ((elder_yn == 'Y' and disabled_yn == 'Y') and not40_yn == 'Y'):
					## 고령자 이면서 장애인이면서 전체 평수 모델 실행(일반 포함)
					'''
						disabled_26_gbm, disabled_36_rf,disabled_46_rf, highage_26_rf ,highage_36_rf, highage_46_gbm, general_26_rf, general_36_rf,general_46_rf 모델변수 지정
					'''
					model_lst.append('disabled_26_gbm')
					model_lst.append('disabled_36_rf')
					model_lst.append('disabled_46_rf')
					model_lst.append('highage_26_rf')
					model_lst.append('highage_36_rf')
					model_lst.append('highage_46_gbm')
					model_lst.append('general_26_rf')
					model_lst.append('general_36_rf')
					model_lst.append('general_46_rf')

					x_data_lst = x_data_lst*len(model_lst)
					series_lst = series_lst*len(series_lst)

					x_data_lst, series_lst =  makeOutput(model_lst, len(model_lst))
				elif ((elder_yn == 'Y' and disabled_yn == 'N') and not40_yn == 'N'):
					## 고령자 40형 이하(미만) 모델만 실행(일반 포함)
					'''
						highage_26_rf ,highage_36_rf, general_26_rf, general_36_rf 모델변수 지정
					'''
					model_lst.append('highage_26_rf')
					model_lst.append('highage_36_rf')
					model_lst.append('general_26_rf')
					model_lst.append('general_36_rf')

					x_data_lst = x_data_lst*len(model_lst)
					series_lst = series_lst*len(series_lst)

					x_data_lst, series_lst =  makeOutput(model_lst, len(model_lst))
				elif ((elder_yn == 'Y' and disabled_yn == 'N') and not40_yn == 'Y'):
					## 고령자 전페평수 모델 실행(일반 포함)
					'''
						highage_26_rf ,highage_36_rf,highage_46_gbm, general_26_rf, general_36_rf, general_46_rf 모델변수 지정
					'''
					model_lst.append('highage_26_rf')
					model_lst.append('highage_36_rf')
					model_lst.append('highage_46_gbm')
					model_lst.append('general_26_rf')
					model_lst.append('general_36_rf')
					model_lst.append('general_46_rf')

					x_data_lst = x_data_lst*len(model_lst)
					series_lst = series_lst*len(series_lst)

					x_data_lst, series_lst =  makeOutput(model_lst, len(model_lst))
				elif ((elder_yn == 'N' and disabled_yn == 'Y') and not40_yn == 'N'):
					## 장애인이면서 40형 이하(미만) 모델만 실행(일반 포함)
					'''
						disabled_26_gbm, disabled_36_rf, general_26_rf, general_36_rf 모델변수 지정
					'''
					model_lst.append('disabled_26_gbm')
					model_lst.append('disabled_36_rf')
					model_lst.append('general_26_rf')
					model_lst.append('general_36_rf')

					x_data_lst = x_data_lst*len(model_lst)
					series_lst = series_lst*len(series_lst)

					x_data_lst, series_lst =  makeOutput(model_lst, len(model_lst))
				elif ((elder_yn == 'N' and disabled_yn == 'Y') and not40_yn == 'N'):
					## 장애인 전체 평수 모델 실행(일반 포함)
					'''
						disabled_26_gbm, disabled_36_rf,disabled_46_rf, general_26_rf, general_36_rf,general_46_rf 모델변수 지정
					'''
					model_lst.append('disabled_26_gbm')
					model_lst.append('disabled_36_rf')
					model_lst.append('disabled_46_rf')
					model_lst.append('general_26_rf')
					model_lst.append('general_36_rf')
					model_lst.append('general_46_rf')

					x_data_lst = x_data_lst*len(model_lst)
					series_lst = series_lst*len(series_lst)

					x_data_lst, series_lst =  makeOutput(model_lst, len(model_lst))
				elif ((elder_yn == 'N' and disabled_yn == 'N') and not40_yn == 'Y' and married_yn == 'Y'):
					## 신혼부부 40형 이하(미만) 모델만 실행(일반 포함)
					## 신혼부부 40형 이하(미만) 모델 없음
					'''
					general_26_rf, general_36_rf 모델변수 지정
					'''
					model_lst.append('general_26_rf')
					model_lst.append('general_36_rf')

					x_data_lst = x_data_lst*len(model_lst)
					series_lst = series_lst*len(series_lst)

					x_data_lst, series_lst =  makeOutput(model_lst, len(model_lst))
				elif ((elder_yn == 'N' and disabled_yn == 'N') and not40_yn == 'N' and married_yn == 'Y'):
					## 신혼부부 전체 평수 모델 실행(일반 포함)
					'''
					married_46_rf, general_26_rf, general_36_rf, general_46_rf 모델변수 지정
					'''
					model_lst.append('married_46_rf')
					model_lst.append('general_26_rf')
					model_lst.append('general_36_rf')
					model_lst.append('general_46_rf')

					x_data_lst = x_data_lst*len(model_lst)
					series_lst = series_lst*len(series_lst)

					x_data_lst, series_lst =  makeOutput(model_lst, len(model_lst))
				elif (not40_yn == 'Y'):
					## 일반 40형 이하(미만) 모델만
					'''
					general_26_rf, general_36_rf 모델변수 지정
					'''
					model_lst.append('general_26_rf')
					model_lst.append('general_36_rf')

					x_data_lst = x_data_lst*len(model_lst)
					series_lst = series_lst*len(series_lst)

					x_data_lst, series_lst =  makeOutput(model_lst, len(model_lst))
				elif (not40_yn == 'N'):
					## 일반 전체
					'''
					general_26_rf, general_36_rf,general_46_rf 모델변수 지정
					'''
					model_lst.append('general_26_rf')
					model_lst.append('general_36_rf')
					model_lst.append('general_46_rf')

					x_data_lst = x_data_lst*len(model_lst)
					series_lst = series_lst*len(series_lst)

					x_data_lst, series_lst =  makeOutput(model_lst, len(model_lst))


			# data = {'Python': 52.9, 'Jython':1.6, 'Iron Python':27.7}
			# return render(request, 'kmapps/results.html' , {'y_data':float(y) * 100 })
			# sample data make
			# series_lst = [{'name': 'Jane','data': [1, 0, 4]}, {'name': 'John','data': [5, 7, 3]}]
			# x_data = ['general_26_rf', 'general_36_rf']

			# print(series_lst)
			return render(request, 'kmapps/results.html' , {'series_data' : json.dumps(series_lst, cls=DjangoJSONEncoder),  'x_data' : json.dumps(x_data_lst , cls=DjangoJSONEncoder) , 'name' : name, 'block_name' : block })
