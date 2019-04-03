import csv
import logging
import os
import subprocess  # R 실행위한 모듈
import json

logger = logging.getLogger(__name__)


def call_script(cmdstr, r_filename):
    result_dict = {'success': 'no'}
    x_data_path = '/lh_prediction/R/x_data.json'
    cmd = [cmdstr, r_filename, "-e", "--encoding", "utf-8"]

    try:
        process = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        out, err = process.communicate()

        result = out.decode('utf8')

        if os.path.exists(x_data_path):
            result_dict['success'] = 'success'
        else:
            return result_dict

        logger.info('-------- {} -------'.format(result_dict))
    except Exception as e:
        logger.warning('----- call_script error : {} ------'.format(e))

    return result_dict


def make_test_file(dic_data, filename):
    try:
        with open(filename, 'w', encoding='utf-8') as csv_file:
            logger.info('open')
            writer = csv.writer(csv_file)
            writer.writerow(list(dic_data.keys()))
            row_lst = []

            for k in dic_data.keys():
                row_lst.append(dic_data[k])
            logger.info('-------- {} ---------'.format(row_lst))
            writer.writerow(row_lst)
    except Exception as e:
        logger.info(e)



def make_output(model, length):
    command = 'Rscript'
    path2script = '/lh_prediction/R/TEST.R'
    modellst2path = '/lh_prediction/R/model_lst.txt'
    x_data_path = '/lh_prediction/R/x_data.json'
    series_data_path = '/lh_prediction/R/series_data.json'

    x_lst = []
    sr_lst = []

    if os.path.exists(modellst2path):
        logger.info('------ exist file : {} ------'.format(modellst2path))
        try:
            os.remove(modellst2path)
            with open(modellst2path, 'w', encoding='utf-8') as f:
                f.write(','.join(map(lambda x: str(x), model)))
                f.write('\n')
        except OSError as e:
            logger.info(e)
    else:
        logger.info('------ not exist file : {} ------'.format(modellst2path))
        with open(modellst2path, 'w', encoding='utf-8') as f:
            f.write(','.join(map(lambda x: str(x), model)))
            f.write('\n')

    success_dict = call_script(command, path2script)

    if success_dict['success'] == 'success':
        if os.path.exists(x_data_path) and os.path.exists(series_data_path):
            with open(x_data_path, 'r', encoding='utf-8') as x_data_f:
                x_lst = json.load(x_data_f)

            with open(series_data_path, 'r', encoding='utf-8') as series_f:
                sr_lst = json.load(series_f)

    else:
        x_lst.insert(0, 'error')
        sr_lst.insert(0, {'data': 0, 'name': 'error'})

    return x_lst, sr_lst
