# -*- coding: utf-8 -*-
from django import forms

# from uni_form.helper import FormHelper
from crispy_forms.helper import FormHelper
from crispy_forms.layout import Layout, Div, Submit, HTML, Button, Row, Field, Column, Fieldset
from crispy_forms.bootstrap import AppendedText, PrependedText, FormActions

class InputForm(forms.Form) :
	'''
	# Q_1 => 신청순위(W_13 : 실제 매핑 컬럼명 / W_18 : 1순위-남양주시, 2순위-인접지역, 3순위-타지역)
	# Q_2 => 월평균소득(W_16 : 실제 매핑 컬럼명)
	# Q_3 => 공급신청자 나이(W_29 : 실제 매핑 컬럼명 / wa1: 65>= W_29 -> 3(고령자 여부 조건) , 50<=W_29<65 -> 3, 40<=W_29<50 -> 2 , 30<=W_29<40 -> 1)
	# Q_4 => 부양가족수(W_25 : 실제 매핑 컬럼명 / wa2 : 3인이상 -> 3 , 2인 -> 2, 1인 -> 1 , 해당없음 -> 40형이상 모델링 제외 필터)
	# Q_5 => 당해주택건설지역 거주기간(W_27 : 실제 매핑 컬럼명 / wa3 : 5년이상 -> 3, 3년이상 5년미만 -> 2 , 1년이상 3년미만 -> 1)
	# Q_6 => 만65세이상 직계존족 1년이상 부양여부(W_30 : 실제 매핑 컬럼명 / wa5 : 부양 -> 3, 미부양 -> 0)
	# Q_7 => 미성년 자녀의수(W_17 : 실제 매핑 컬럼명 / wa4 : 3자녀이상 -> 3, 2자녀 -> 2, 1자녀/0자녀 -> 0)
	# Q_8 => 중소기업중 제조업(W_31 : 실제 매핑 컬럼명 / wa6 : 해당 -> 3 , 해당없음 -> 0)
	# Q_9 => 건설근로자(W_36 : 실제 매핑 컬럼명 / wa7 : 해당 -> 3 , 해당없음 -> 0)
	# Q_10 => 사회취약계층(wa8 : 실제 매핑 컬럼명 / wa9 : 해당 -> 3 , 해당없음 -> 0)
	# Q_11 => 공사 국민임대 과거 계약여부(W_24 : 실제 매핑 컬럼명 ** 매핑시 -붙여서 매핑)
	# Q_12 => 주택청약종합저축 납입 인정횟수(W_28 : 실제 매핑 컬럼명 / wa10 : 60회이상 -> 3, 48회이상 60회미만 -> 2 , 36회이상 48회미만 -> 1)
	# Q_13 => 주택청약종합저축 납입금액(A_47 : 실제 매핑 컬럼명)
	# Q_14 => 장애등급(W_15 : 실제 매핑 컬럼명 / 장애인 필터링)
	# Q_15 => 혼인기간(W_38 : 실제 매핑 컬럼명 / W_39 : 3년이내 -> 1순위, 3년초과 5년이내 -> 2순위, 해당없음 -> 0 매핑 후 신혼부부 조건 제외)
	# Q_16 => 신혼부부지역구분(W_40 : 실제 매핑 컬럼명)
	# Q_17 => 자녀수(W_41 : 실제 매핑 컬럼명)
	'''
	Q_0_0 = forms.CharField(label='신청자이름', max_length=25, required=False)
	Q_0_1 = forms.ChoiceField(
		choices = (
			('', '---선택---'),
			('A16-2', '남양주 별내 16-2단지'),
			('A16-3', '남양주 별내 16-3단지'),
			('A22', '남양주 별내 22단지')
		),
		widget = forms.Select,
		label = '단지',
		initial='A16-2',
		# required=False
	)

	Q_1 = forms.ChoiceField(
			choices = (
					('', '---선택---'),
					('1st', '1순위'),
					('2nd', '2순위'),
					('3rd' ,'3순위')
				),
			widget = forms.Select,
			label='신청순위',
			initial='1st',
			# required=False
	)
	Q_2 = forms.ChoiceField(
			choices = (
					('', '---선택---'),
					('n', '50%이하'),
					('n', '50%초과 70%이하'),
					('Y' , '70%초과')
				),
			widget = forms.Select,
			label = '월평균소득',
			initial='n',
			# required=False
	)
	Q_3 = forms.IntegerField(label='공급신청자 나이', required=False)
	Q_4 = forms.ChoiceField(
		choices = (
			('', '---선택---'),
			('0' , '없음'),
			('3', '3인이상'),
			('2', '2인'),
			('1', '1인'),
		),
		widget = forms.Select,
		label = '부양가족수',
		initial='0',
		# required=False
	)
	Q_5 = forms.IntegerField(label='당해 거주기간', required=False)
	Q_6 = forms.ChoiceField(
		choices = (
			('', '---선택---'),
			('n', '미부양'), # 0점
			('Y', '부양'), # 3점
		),
		widget = forms.Select,
		label='65세이상 부양여부',
		initial='n',
		# required=False
	)
	Q_7 = forms.ChoiceField(
		choices = (
			('', '---선택---'),
			('0', '없음'),
			('3', '3자녀이상'),
			('2', '2자녀'),
			('0', '1자녀'),
		),
		widget = forms.Select,
		label = '미성년 자녀수',
		initial='0',
		# required=False
	)
	Q_8 = forms.ChoiceField(
		choices = (
			('', '---선택---'),
			('n', '해당없음'), # score : 0
			('Y', '해당'), # score : 3
		),
		widget = forms.Select,
		label = '중소기업중 제조업',
		initial='n',
		# required=False
	)
	Q_9 = forms.ChoiceField(
		choices = (
			('', '---선택---'),
			('n', '해당없음'), # score : 0
			('Y', '해당'), # score : 3
		),
		widget = forms.Select,
		label = '건설근로자',
		initial='n',
		# required=False
	)
	Q_10 = forms.ChoiceField(
		choices = (
			('', '---선택---'),
			(' ', '해당없음'),
			('Y', '해당'),

		),
		widget = forms.Select,
		label = '사회취약계층',
		initial=' ',
		# required=False
	)
	Q_11 = forms.ChoiceField(
		choices = (
			('', '---선택---'),
			(0, '해당없음'),
			(-5, '1년이내'),
			(-3,'1년초과 3년이내')
		),
		widget = forms.Select,
		label = '국민임대 과거계약여부',
		initial=0,
		# required=False
	)
	Q_12 = forms.IntegerField(label = '청약저축 납입금액', required=False)
	Q_13 = forms.IntegerField(label = '청약저축 납입인정횟수', required=False)
	Q_14 = forms.ChoiceField(
		choices = (
			('', '---선택---'),
			('N','해당없음'),
			('1R','1급'),
			('2R','2급'),
			('3R','3급'),
			('4R','4급'),
			('5R','5급'),
			('6R','6급'),
		),
		widget = forms.Select,
		label = '장애등급',
		initial='N',
		# required=False
	)
	Q_15_0 = forms.ChoiceField(
		choices = (
			('', '---선택---'),
			('Y','기혼'),
			('N', '미혼'),
		),
		widget = forms.Select(attrs = {'onchange' : 'change_married();'}),
		label = '결혼여부',
		initial='N',
		# required=False
	)
	Q_15 = forms.IntegerField(label = '혼인기간', required=False, widget=forms.NumberInput(attrs={'disabled': 'disabled'}))
	Q_16 = forms.ChoiceField(
		choices = (
			('', '---선택---'),
			('N', '해당없음'),
			('RESI','당해지역'),
			('N_RESI', '타지역'),
		),
		widget = forms.Select(attrs={'disabled': 'disabled'}),
		label = '신혼부부지역구분',
		required=False,
		# attrs={'readonly':'readonly'}
	)
	Q_17 = forms.ChoiceField(
		choices = (
			('', '---선택---'),
			('0','없음'),
			('1','1명'),
			('2','2명'),
			('3','3명'),
		),
		widget = forms.Select(attrs={'disabled': 'disabled'}),
		label = '자녀수',
		required=False,
		# attrs={'readonly':'readonly'}
	)

	def __init__(self, *args, **kwargs):
		# Uni-form
	    super(InputForm, self).__init__(*args, **kwargs)
	    self.helper = FormHelper()
	    self.helper.form_id = 'input_data_form'
	    self.helper.form_method = 'POST'
	    # self.helper.form_class = 'form-horizontal'
	    self.helper.form_action = 'kmapps:results'
	    # self.helper.label_class ='col-md-2 col-lg-3'
	    # self.helper.field_class = 'col-md-10 col-lg-9'

	    # self.helper.add_input(Submit('submit', '확인', css_class='btn-success'))
	    # self.helper.add_input(Submit('button', '취소', css_class='btn-danger'))
	    # self.helper.field_template = ''
	    self.helper.layout = Layout(
	        # Field('Q_1', css_class='radio-inline'),
	        Div(
	        	# css_class="form-group",
	        	# Div(
		        	Div('Q_0_0', css_class='col-xs-3'),
		        	Div('Q_0_1', css_class='col-xs-3'),
		        	Div('Q_1', css_class='col-xs-3'),
		        	Div('Q_2', css_class='col-xs-3'),
		        	css_class='row-fluid'
	        	# )
	        ),
	        Div(
	        	# css_class="form-group",
	        	Div('Q_3', css_class='col-xs-3'),
	        	Div('Q_4', css_class='col-xs-3'),
	        	Div('Q_5', css_class='col-xs-3'),
	        	Div('Q_6', css_class='col-xs-3'),
	        	css_class='row-fluid'
	        ),

	        Div(
	        	# css_class="form-group",
	        	Div('Q_7', css_class='col-xs-3'),
	        	Div('Q_8', css_class='col-xs-3'),
	        	Div('Q_9', css_class='col-xs-3'),
	        	Div('Q_10', css_class='col-xs-3'),
	        	css_class='row-fluid'
	        ),
	        Div(
	        	# css_class="form-group",
	        	Div('Q_11', css_class='col-xs-3'),
	        	Div('Q_12', css_class='col-xs-3'),
	        	Div('Q_13', css_class='col-xs-3'),
	        	Div('Q_14', css_class='col-xs-3'),
	        	css_class='row-fluid'
	        ),

	        Div(
	        	# css_class="form-group",
	        	Div('Q_15_0', css_class='col-xs-3'),
	        	Div('Q_15', css_class='col-xs-3'),
	        	Div('Q_16', css_class='col-xs-3'),
	        	Div('Q_17', css_class='col-xs-3'),
	        	css_class='row-fluid'
	        	# Div('Q_6'),
	        ),

	        FormActions(
	            Submit('submit', '확인', css_class='btn-success'),
	            HTML('<a class="btn btn-warning" href="" style="width:100%;padding:15px;">취소</a>'),
	    	)
	    )