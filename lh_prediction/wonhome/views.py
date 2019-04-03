import os
import json
import csv
import logging

from django.core.serializers.json import DjangoJSONEncoder
from django.shortcuts import redirect, render
from django.views.generic.edit import FormView
from django.views import generic
from django.urls import reverse_lazy

from .forms import InputForm
from . import utils

logger = logging.getLogger(__name__)
class IndexView(FormView):
    """
    main index page
    """
    template_name = 'wonhome/index.html'
    form_class = InputForm
    success_url = reverse_lazy('won_result')


class WonResultView(generic.View):
    template_name = 'wonhome/results.html'

    def get(self, request, *args, **kwargs):
        return redirect('wonhome:won_index')

    def post(self, request):
        '''
        model operation result
        :param form:
        :rtype: list
        '''
        logger.info('!!!!!!')
        ## 파생변수 데이터
        add_data = {'Price.percent': 0.512108243, 'num.Apt': 31471, 'subway.km': 1.6, 'walk.YN': 'n',
                    'num.House': 214763, 'facility_near': 0.5, 'hospital_near_km': 9.49, 'hospital_near_min': 46,
                    'supply_tot': 1058, 'news_3month': 15, 'news_6month': 16, 'supply.ratio': 1.36677681,
                    'supply.counts': 91}

        ## 추가 변수
        W_18 = ''
        wa1_age = 0
        wa2_fam = ''
        wa3_liveterm = 0
        wa4_child = 0
        wa5_direct = 0
        wa6_fac = 0
        wa7_construct = 0
        wa9_weakscore = 0
        wa10_application = 0
        W_39 = ''

        ## 총점 점수 관련 변수(W_20 : 장애인,고령자 / 신혼부부 , W_21 : 일반공급)
        W_20 = 0
        W_21 = 0

        elder_yn = ''
        km_yn = ''
        not40_yn = ''
        disabled_yn = ''
        married_yn = ''

        W_38 = ''
        W_40 = ''
        W_41 = 0

        # result variable
        series_lst = []
        x_data_lst = []

        # model name variable list
        model_lst = []

        name = request.POST.get('Q_0_0', '')  # 사용자 입력 이름
        block = request.POST.get('Q_0_1')  # 단지명
        Q_15_0 = request.POST.get('Q_15_0')
        W_13 = request.POST.get("Q_1")
        W_16 = request.POST.get('Q_2')
        W_29 = request.POST.get('Q_3')
        W_25 = request.POST.get('Q_4')
        W_27 = request.POST.get('Q_5')
        W_30 = request.POST.get('Q_6')
        W_17 = request.POST.get('Q_7')
        W_31 = request.POST.get('Q_8')
        W_36 = request.POST.get('Q_9')
        wa8_weakYN = request.POST.get('Q_10')
        W_24 = request.POST.get('Q_11')
        W_28 = request.POST.get('Q_12')
        A_47 = request.POST.get('Q_13')
        W_15 = request.POST.get('Q_14')
        W_38 = ''
        W_40 = ''
        W_41 = 0

        if Q_15_0 == 'Y':
            logger.info('1')
            W_38 = request.POST.get('Q_15')
            W_40 = request.POST.get('Q_16')
            W_41 = request.POST.get('Q_17')
        else:
            logger.info('2')
            W_38 = 'N'
            W_40 = 'N'
            W_41 = 0

        # 신청순위
        if W_13 == '1st':
            logger.info('3')
            W_18 = 'RESI'
        else:
            logger.info('4')
            W_18 = 'N_RESI'

        # 월소득평균(국민임대 자격여부 결정)
        # 소득 70% 초과면 모델 실행안함
        if W_16 == 'Y':
            logger.info('5')
            km_yn = 'Y'
            x_data_lst.insert(0, 'no_model')
            series_lst.insert(0, {'data': 0, 'name': 'error'})

            return render(request, template_name=self.template_name, context=
                      {'series_data': json.dumps(series_lst, cls=DjangoJSONEncoder),
                       'x_data': json.dumps(x_data_lst, cls=DjangoJSONEncoder),
                       'name': name, 'block_name': block})

        # 신청자 나이를 통한 파생변수 세팅(고령자여부 결정)
        applicant_age = int(W_29)
        if applicant_age >= 65:
            logger.info('6')
            wa1_age = 3
            elder_yn = 'Y'
        elif applicant_age in range(50, 65):
            logger.info('7')
            wa1_age = 3
            elder_yn = 'N'
        elif applicant_age in range(40, 50):
            logger.info('8')
            wa1_age = 2
            elder_yn = 'N'
        elif applicant_age in range(30, 40):
            logger.info('9')
            wa1_age = 1
            elder_yn = 'N'

        # 부양가족 관련
        wa2_fam = W_25
        if wa2_fam == '0':
            logger.info('10')
            not40_yn = 'Y'
        else:
            logger.info('11')
            not40_yn = 'N'

        logger.info('12')
        residence_date = int(W_27)
        if residence_date >= 5:
            wa3_liveterm = 3
        elif residence_date in range(3, 5):
            wa3_liveterm = 2
        elif residence_date in range(1, 3):
            wa3_liveterm = 1

        # 65세 이상 직계존속 부양 여부
        logger.info('13')
        if W_30 == 'Y':
            wa5_direct = 3
        else:
            wa5_direct = 0

        # 미성년자녀수
        logger.info('14')
        minor_amount = int(W_17)
        if minor_amount == 3:
            wa4_child = 3
        elif minor_amount == 2:
            wa4_child = 2
        else:
            wa4_child = 0

        # 중소기업중 제조업
        logger.info('15')
        if W_31 == 'Y':
            wa6_fac = 3
        else:
            wa6_fac = 0

        # 건설근로자
        logger.info('16')
        if W_36 == 'Y':
            wa7_construct = 3
        else:
            wa7_construct = 0

        # 사회취약계층
        logger.info('17')
        if wa8_weakYN == 'Y':
            wa9_weakscore = 3
        else:
            wa8_weakYN = ''
            wa9_weakscore = 0

        # 주택청약 납입 인정횟수
        logger.info('18')
        if A_47 != '':
            house_subscription_count = int(A_47)
            if house_subscription_count >= 60:
                wa10_application = 3
            elif house_subscription_count in range(48, 60):
                wa10_application = 2
            elif house_subscription_count in range(36, 48):
                wa10_application = 1


        # 장애여부(해당없으면 장애인 모델 제외)
        logger.info('19')
        if W_15 == 'N':
            disabled_yn = 'N'
        else:
            disabled_yn = 'Y'

        # 혼인기간(해당이 안될경우 조건 없음)
        logger.info('20')
        if W_38 == 'N':
            married_yn = 'N'
        elif int(W_38) in range(0, 4):
            W_39 = '1st'
            married_yn = 'Y'
        elif int(W_38) in range(4, 6):
            W_39 = '2nd'
            married_yn = 'Y'

        # 우선/일반 총점 계산 ###################
        # 우선인 경우 우선점수와 탈락을 예상하여 일반 점수도 같이 부여
        # 일반인 경우 우선점수는 0점
        # ###################################
        logger.info('21')
        if elder_yn == 'Y' or disabled_yn == 'Y':
            W_20 = wa1_age + int(wa2_fam) + wa3_liveterm + wa4_child + \
                   wa7_construct + wa10_application + int(W_24)
            W_21 = wa1_age + int(wa2_fam) + wa3_liveterm + wa4_child + \
                   wa5_direct + wa6_fac + wa7_construct + wa9_weakscore + wa10_application + int(W_24)
        elif (married_yn == 'Y'):
            W_20 = wa1_age + int(
                wa2_fam) + wa3_liveterm + wa4_child + wa5_direct + \
                   wa6_fac + wa7_construct + wa9_weakscore + wa10_application + int(W_24)
            W_21 = wa1_age + int(wa2_fam) + wa3_liveterm + \
                   wa4_child + wa5_direct + wa6_fac + wa7_construct + wa9_weakscore + wa10_application + int(W_24)
        elif (elder_yn == 'N' and disabled_yn == 'N' and married_yn == 'N'):
            W_20 = 0
            W_21 = wa1_age + int(wa2_fam) + wa3_liveterm + wa4_child + \
                   wa5_direct + wa6_fac + wa7_construct + wa9_weakscore + wa10_application + int(W_24)

        dict_data = {
            'A_47': A_47,
            'W_13': W_13,
            'W_15': W_15,
            'W_16': W_16,
            'W_17': W_17,
            'W_18': W_18,
            'W_20': W_20,
            'W_21': W_21,
            'W_24': W_24,
            'W_25': W_25,
            'W_27': W_27,
            'W_28': W_28,
            'W_29': W_29,
            'W_30': W_30,
            'W_31': W_31,
            'W_36': W_36,
            'W_38': W_38,
            'W_39': W_39,
            'W_40': W_40,
            'W_41': W_41,
            'wa1_age': wa1_age,
            'wa2_fam': wa2_fam,
            'wa3_liveterm': wa3_liveterm,
            'wa4_child': wa4_child,
            'wa5_direct': wa5_direct,
            'wa6_fac': wa6_fac,
            'wa7_construct': wa7_construct,
            'wa8_weakYN': wa8_weakYN,
            'wa9_weakscore': wa9_weakscore,
            'wa10_application': wa10_application,
            ## 파생 데이터 추가 필요
            # add_data = {'Price.percent' : 0.512108243, 'num.Apt' : 31471, 'subway.km' : 1.6, 'walk.YN' : 'n', 'num.House' : 214763, 'facility_near' : 0.5, 'hospital_near_km' : 9.49, 'hospital_near_min' : 46, 'supply_tot' : 1058, 'news_3month' : 15, 'news_6month' : 16, 'supply.ratio' : 1.36677681, 'supply.counts' : 91}
            'Price.percent': add_data['Price.percent'],
            'num.Apt': add_data['num.Apt'],
            'subway.km': add_data['subway.km'],
            'walk.YN': add_data['walk.YN'],
            'num.House': add_data['num.House'],
            'facility_near': add_data['facility_near'],
            'hospital_near_km': add_data['hospital_near_km'],
            'hospital_near_min': add_data['hospital_near_min'],
            'supply_tot': add_data['supply_tot'],
            'news_3month': add_data['news_3month'],
            'news_6month': add_data['news_6month'],
            'supply.ratio': add_data['supply.ratio'],
            'supply.counts': add_data['supply.counts']
        }

        if os.path.exists('/lh_prediction/R/test.csv'):
            logger.info('22')
            try:
                os.remove('/lh_prediction/R/test.csv')
                utils.make_test_file(dict_data, '/lh_prediction/R/test.csv')
            except OSError as e:
                logger.info(e)
        else:
            logger.info('23')
            utils.make_test_file(dict_data, '/lh_prediction/R/test.csv')

        logger.info('elder_yn : {}, disbled_yn : {} not40_yn : {}'.format(elder_yn, disabled_yn, not40_yn))
        if (elder_yn == 'Y' and disabled_yn == 'Y') and not40_yn == 'N':
            '''
                disabled_26_gbm, 
                disabled_36_rf, 
                highage_26_rf , 
                highage_36_rf, 
                general_26_rf, 
                general_36_rf 모델변수 지정
            '''
            model_lst.append('disabled_26_gbm')
            model_lst.append('disabled_36_rf')
            model_lst.append('highage_26_rf')
            model_lst.append('highage_36_rf')
            model_lst.append('general_26_rf')
            model_lst.append('general_36_rf')

            logger.info('------ elder_ynY, disabled_ynY, not40_ynN : {} ------'.format(model_lst))

            x_data_lst, series_lst = utils.make_output(model_lst, len(model_lst))
            logger.info('------ x_data_lst : {} ------'.format(x_data_lst))
            logger.info('------ series_lst : {} ------'.format(series_lst))
        elif (elder_yn == 'Y' and disabled_yn == 'Y') and not40_yn == 'Y':
            logger.info('25')
            '''
                disabled_26_gbm, 
                disabled_36_rf,
                disabled_46_rf, 
                highage_26_rf,
                highage_36_rf, 
                highage_46_gbm, 
                general_26_rf, 
                general_36_rf,
                general_46_rf 모델변수 지정
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

            logger.info('------ elder_ynY, disabled_ynY, not40_ynY : {} ------'.format(model_lst))

            x_data_lst, series_lst = utils.make_output(model_lst, len(model_lst))
            logger.info('------ x_data_lst : {} ------'.format(x_data_lst))
            logger.info('------ series_lst : {} ------'.format(series_lst))
        elif (elder_yn == 'Y' and disabled_yn == 'N') and not40_yn == 'N':
            logger.info('27')
            '''
                highage_26_rf,
                highage_36_rf,
                general_26_rf,
                general_36_rf 모델변수 지정
            '''
            model_lst.append('highage_26_rf')
            model_lst.append('highage_36_rf')
            model_lst.append('general_26_rf')
            model_lst.append('general_36_rf')

            logger.info('------ elder_ynY, disabled_ynN, not40_ynN : {} ------'.format(model_lst))

            x_data_lst, series_lst = utils.make_output(model_lst, len(model_lst))
            logger.info('------ x_data_lst : {} ------'.format(x_data_lst))
            logger.info('------ series_lst : {} ------'.format(series_lst))
        elif (elder_yn == 'Y' and disabled_yn == 'N') and not40_yn == 'Y':
            logger.info('26')
            '''
                highage_26_rf,
                highage_36_rf,
                highage_46_gbm,
                general_26_rf,
                general_36_rf,
                general_46_rf 모델변수 지정
            '''
            model_lst.append('highage_26_rf')
            model_lst.append('highage_36_rf')
            model_lst.append('highage_46_gbm')
            model_lst.append('general_26_rf')
            model_lst.append('general_36_rf')
            model_lst.append('general_46_rf')

            logger.info('------ elder_ynY, disabled_ynN, not40_ynY : {} ------'.format(model_lst))

            x_data_lst, series_lst = utils.make_output(model_lst, len(model_lst))
            logger.info('------ x_data_lst : {} ------'.format(x_data_lst))
            logger.info('------ series_lst : {} ------'.format(series_lst))

        elif (elder_yn == 'N' and disabled_yn == 'Y') and not40_yn == 'N':
            logger.info('29')
            '''
                disabled_26_gbm, 
                disabled_36_rf, 
                general_26_rf, 
                general_36_rf 모델변수 지정
            '''
            model_lst.append('disabled_26_gbm')
            model_lst.append('disabled_36_rf')
            model_lst.append('general_26_rf')
            model_lst.append('general_36_rf')

            logger.info('------ elder_ynN, disabled_ynY, not40_ynN : {} ------'.format(model_lst))

            x_data_lst, series_lst = utils.make_output(model_lst, len(model_lst))
            logger.info('------ x_data_lst : {} ------'.format(x_data_lst))
            logger.info('------ series_lst : {} ------'.format(series_lst))
        elif (elder_yn == 'N' and disabled_yn == 'Y') and not40_yn == 'Y':
            logger.info('28')
            '''
                disabled_26_gbm, 
                disabled_36_rf,
                disabled_46_rf, 
                general_26_rf, 
                general_36_rf,
                general_46_rf 모델변수 지정
            '''
            model_lst.append('disabled_26_gbm')
            model_lst.append('disabled_36_rf')
            model_lst.append('disabled_46_rf')
            model_lst.append('general_26_rf')
            model_lst.append('general_36_rf')
            model_lst.append('general_46_rf')

            logger.info('------ elder_ynN, disabled_ynY, not40_ynY : {} ------'.format(model_lst))

            x_data_lst, series_lst = utils.make_output(model_lst, len(model_lst))
            logger.info('------ x_data_lst : {} ------'.format(x_data_lst))
            logger.info('------ series_lst : {} ------'.format(series_lst))


        elif (elder_yn == 'N' and disabled_yn == 'N') and not40_yn == 'Y' and married_yn == 'Y':
            logger.info('30')
            '''
                general_26_rf, general_36_rf 모델변수 지정
            '''
            model_lst.append('general_26_rf')
            model_lst.append('general_36_rf')

            logger.info('------ elder_ynN, disabled_ynN, not40_ynY, married_ynY : {} ------'.format(model_lst))

            x_data_lst, series_lst = utils.make_output(model_lst, len(model_lst))
            logger.info('------ x_data_lst : {} ------'.format(x_data_lst))
            logger.info('------ series_lst : {} ------'.format(series_lst))
        elif (elder_yn == 'N' and disabled_yn == 'N') and not40_yn == 'N' and married_yn == 'Y':
            logger.info('31')
            '''
                married_46_rf, 
                general_26_rf, 
                general_36_rf, 
                general_46_rf 모델변수 지정
            '''
            model_lst.append('married_46_rf')
            model_lst.append('general_26_rf')
            model_lst.append('general_36_rf')
            model_lst.append('general_46_rf')

            logger.info('------ elder_ynN, disabled_ynN, not40_ynN, married_ynY : {} ------'.format(model_lst))

            x_data_lst, series_lst = utils.make_output(model_lst, len(model_lst))
            logger.info('------ x_data_lst : {} ------'.format(x_data_lst))
            logger.info('------ series_lst : {} ------'.format(series_lst))
        elif not40_yn == 'Y':
            logger.info('32')
            '''
                general_26_rf, 
                general_36_rf 모델변수 지정
            '''
            model_lst.append('general_26_rf')
            model_lst.append('general_36_rf')

            logger.info('------ not40_ynY : {} ------'.format(model_lst))

            x_data_lst, series_lst = utils.make_output(model_lst, len(model_lst))
            logger.info('------ x_data_lst : {} ------'.format(x_data_lst))
            logger.info('------ series_lst : {} ------'.format(series_lst))
        elif not40_yn == 'N':
            logger.info('33')
            '''
                general_26_rf, 
                general_36_rf,
                general_46_rf 모델변수 지정
            '''
            model_lst.append('general_26_rf')
            model_lst.append('general_36_rf')
            model_lst.append('general_46_rf')

            logger.info('------ not40_ynN : {} ------'.format(model_lst))

            x_data_lst, series_lst = utils.make_output(model_lst, len(model_lst))
            logger.info('------ x_data_lst : {} ------'.format(x_data_lst))
            logger.info('------ series_lst : {} ------'.format(series_lst))

        return render(request, template_name=self.template_name, context=
                      {'series_data': json.dumps(series_lst, cls=DjangoJSONEncoder),
                       'x_data': json.dumps(x_data_lst, cls=DjangoJSONEncoder),
                       'name': name, 'block_name': block})
