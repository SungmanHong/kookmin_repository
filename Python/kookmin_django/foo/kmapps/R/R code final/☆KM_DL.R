


#■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
# <<load library>>

library(h2o)
library(stringr)
library(dplyr)
library(data.table)
seed_num=2016
localH2O = h2o.init(nthreads=-1) 
h2o.removeAll() 
#■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■


#■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
# <<prepare data>>

# data 불러오기
h2oData <- read.csv('./data/disabled_36.csv', header = TRUE)

# 컬럼제거(1: SEQ_NUM, 2:SEQ_ 4:REGNUM_BLOCK, 8:W_8) ,3:BLOCK_NM
h2oData = h2oData[, - c(1:4, 8)]
# 파생변수제외 선택(33~: 파생변수)
h2oData <- h2oData[, c(1:32)]

#■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■


#■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
# << eliminate useless variabels>>

# 데이터 이상값 처리1: eliminate the variable(s) with one factor level
#h2oData              = h2oData[,-which(colnames(h2oData) %in% colnames(h2oData[,sapply(h2oData,nlevels)==1]))]

# 데이터 이상값 처리2: eliminate the variable(s) with more than 10% missing values 
#h2oData[h2oData==""]  = NA
#tmp_NA              = data.frame(NA_percentage=round(sapply(h2oData,function(x)sum(is.na(x)))/nrow(h2oData),2))
#h2oData              = h2oData[,-which(colnames(h2oData) %in% rownames(tmp_NA)[which(tmp_NA$NA_percentage>0.1)])]

# 데이터 이상값 처리3: eliminate the variable(s) with a constant value 
#tmp_uniquelen       = data.frame(unique_length=apply(h2oData,2,function(x) length(unique(x))))
#h2oData              = h2oData[,-which(colnames(h2oData) %in% rownames(tmp_uniquelen)[which(tmp_uniquelen$unique_length==1)])]
#■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■


#■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
# <<covert to h2o.data.frame>>

# H2O DataFrame으로 변경
h2oData             = as.h2o(h2oData)

# data 분리(train/valid/test)
splits              = h2o.splitFrame(h2oData, c(0.6, 0.2), seed = seed_num)
train               = h2o.assign(splits[[1]], "train.hex") 
valid               = h2o.assign(splits[[2]], "valid.hex") 
test                = h2o.assign(splits[[3]], "test.hex")  

# 예측하고자 하는 변수지정
response            = 'W_4' # 당첨/탈락 여부 필드

# predictors 지정
predictors          = setdiff(names(train), response)
#■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■


#■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
# <<build dl using checkpoint modeling>>

options(warn=-1)
dl                      = h2o.deeplearning(# ↓↓↓↓↓ set params
                          training_frame = train, 
                          validation_frame = valid, 
                          x = predictors, 
                          y = response, 
                          # early stopping rules
                          stopping_rounds = 5,
                          stopping_metric = "logloss",
                          stopping_tolerance = 1e-3,
                          epochs = 1000,
                          reproducible = T,
                          seed = seed_num) 
options(warn=0)

# summary
dl_thred                = h2o.find_threshold_by_max_metric(h2o.performance(dl, newdata = test), "f1")
dl_cm                   = h2o.confusionMatrix(h2o.performance(dl, newdata = test), thresholds = dl_thred)
dl_Accuracy             = h2o.accuracy(h2o.performance(dl, newdata = test), thresholds = dl_thred)
dl_recall               = h2o.recall(h2o.performance(dl, newdata = test), thresholds = dl_thred)
dl_precision            = h2o.precision(h2o.performance(dl, newdata = test), thresholds = dl_thred)
dl_AUC                  = h2o.auc(h2o.performance(dl, newdata = test))
#■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■


#■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
# <<tunning gbm with random grid search>>

activation_opt          = c("Rectifier","RectifierWithDropout","Tanh","TanhWithDropout")
hidden_opt              = list(c(30),c(50),c(30,30),c(50,50),c(30,15),c(50,25))
input_dropout_ratio_opt = seq(0,0.2,0.01)
l1_opt                  = seq(0,1e-4,1e-06)

hyper_params            = list(# ↓↓↓↓↓ set params
                          activation = activation_opt,
                          hidden = hidden_opt,
                          input_dropout_ratio = input_dropout_ratio_opt,
                          l1 = l1_opt)
    
search_criteria         = list(# ↓↓↓↓↓ set params
                          strategy = "RandomDiscrete",
                          max_models = 60,
                          stopping_rounds = 5,
                          stopping_metric = "logloss",
                          stopping_tolerance=1e-3,
                          seed = seed_num)
    
grid                    = h2o.grid(# ↓↓↓↓↓ set params
                          algorithm = "deeplearning",
                          grid_id = "dl_grid",
                          training_frame = train,
                          validation_frame = valid,
                          x = predictors,
                          y = response,
                          epochs = 1000,
                          hyper_params = hyper_params,
                          search_criteria = search_criteria)

# best model
dl_grid                  = h2o.getGrid("dl_grid", sort_by = "logloss", decreasing = F)
best_model               = h2o.getModel(dl_grid@model_ids[[1]])
best_activation          = best_model@allparameters$activation
best_hidden              = best_model@allparameters$hidden
best_input_dropout_ratio = best_model@allparameters$input_dropout_ratio
best_l1                  = best_model@allparameters$l1
print(dl_grid)

# run tunned model
options(warn=-1)
tunned_dl         = h2o.deeplearning( # ↓↓↓↓↓ set params
                    training_frame = train, 
                    validation_frame = valid, 
                    x = predictors, 
                    y = response, 
                    # early stopping rule
                    stopping_rounds = 5,
                    stopping_metric = "logloss",
                    stopping_tolerance = 1e-3,
                    #  best params
                    activation = best_activation,
                    hidden = best_hidden,
                    input_dropout_ratio = best_input_dropout_ratio,
                    l1 = best_l1,
                    reproducible = T,
                    epochs = 1000,
                    seed = seed_num) 
options(warn=0)

# summary
tunned_thred     = h2o.find_threshold_by_max_metric(h2o.performance(tunned_dl, newdata = test), "f1")
tunned_cm        = h2o.confusionMatrix(h2o.performance(tunned_dl, newdata = test), thresholds = tunned_thred)
tunned_Accuracy  = h2o.accuracy(h2o.performance(tunned_dl, newdata = test), thresholds = tunned_thred)
tunned_recall    = h2o.recall(h2o.performance(tunned_dl, newdata = test), thresholds = tunned_thred)
tunned_precision = h2o.precision(h2o.performance(tunned_dl, newdata = test), thresholds = tunned_thred)
tunned_AUC = h2o.auc(h2o.performance(tunned_dl, newdata = test))

print("disabled_36\n")
tunned_cm
print(paste("tunned_ACCURACY   : ", tunned_Accuracy, sep = ""))
print(paste("tunned_AUC        : ", tunned_AUC, sep = ""))
print(paste("tunned_recall     : ", tunned_recall, sep = ""))
print(paste("tunned_precision  : ", tunned_precision, sep = ""))

h2o.saveModel(tunned_dl, path = "C:/Users/mijin/Desktop/output", force = TRUE)


#■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■