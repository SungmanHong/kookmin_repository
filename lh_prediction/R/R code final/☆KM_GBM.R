


#■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
# <<load library>>

library(h2o)
library(stringr)
library(dplyr)
library(data.table)

rm(list = ls())

seed_num=2016
localH2O = h2o.init() 
h2o.removeAll() 
#■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■


#■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
# <<prepare data>>

h2oData <- read.csv('./data/disabled_26.csv', header = TRUE)

# 컬럼제거(1: SEQ_NUM, 2:SEQ_ 4:REGNUM_BLOCK, 8:W_8) ,3:BLOCK_NM
h2oData = h2oData[, - c(1:4, 8)]
# 파생변수제외 선택(33~: 파생변수)
#h2oData <- h2oData[, c(1:32)]
#■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■


#■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
# << eliminate useless variabels>>

# 데이터 이상값 처리1: eliminate the variable(s) with one factor level
h2oData              = h2oData[,-which(colnames(h2oData) %in% colnames(h2oData[,sapply(h2oData,nlevels)==1]))]

# 데이터 이상값 처리2: eliminate the variable(s) with more than 10% missing values 
h2oData[h2oData==""]  = NA
tmp_NA              = data.frame(NA_percentage=round(sapply(h2oData,function(x)sum(is.na(x)))/nrow(h2oData),2))
h2oData              = h2oData[,-which(colnames(h2oData) %in% rownames(tmp_NA)[which(tmp_NA$NA_percentage>0.1)])]

# 데이터 이상값 처리3: eliminate the variable(s) with a constant value 
tmp_uniquelen       = data.frame(unique_length=apply(h2oData,2,function(x) length(unique(x))))
h2oData              = h2oData[,-which(colnames(h2oData) %in% rownames(tmp_uniquelen)[which(tmp_uniquelen$unique_length==1)])]
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
# <<build gbm using checkpoint modeling>>

options(warn=-1)
checkpoint_gbm          = h2o.gbm(# ↓↓↓↓↓ set params
                          training_frame = train, 
                          validation_frame = valid, 
                          x = predictors, 
                          y = response, 
                          score_each_iteration = T,
                          # early stopping rules
                          stopping_rounds = 5,
                          stopping_metric = "logloss",
                          stopping_tolerance = 1e-3,
                          seed = seed_num) 
gbm                     = h2o.gbm(# ↓↓↓↓↓ set params
                          training_frame = train, 
                          validation_frame = valid, 
                          x = predictors, 
                          y = response, 
                          score_each_iteration = T,
                          checkpoint = checkpoint_gbm@model_id,
                          # early stopping rules
                          stopping_rounds = 5,
                          stopping_metric = "logloss",
                          stopping_tolerance = 1e-3,
                          ntrees = 100,
                          seed = seed_num) 
options(warn=0)

# summary
gbm_pred                = h2o.predict(object = gbm, newdata = test)
thred                   = h2o.find_threshold_by_max_metric(h2o.performance(gbm, newdata = test), "f1")
gbm_cm                  = h2o.confusionMatrix(h2o.performance(gbm, newdata = test), thresholds = thred)
gbm_Accuracy            = h2o.accuracy(h2o.performance(gbm, newdata = test), thresholds = thred)
gbm_recall              = h2o.recall(h2o.performance(gbm, newdata = test), thresholds = thred)
gbm_precision           = h2o.precision(h2o.performance(gbm, newdata = test), thresholds = thred)
gbm_AUC                 = h2o.auc(h2o.performance(gbm, newdata = test))
#■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■


#■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
# <<tunning gbm with random grid search>>

ntrees_opt          = seq(50, 200, 10)
max_depth_opt       = seq(20, 50, 2)
nbins_opt           = seq(20, 50, 2)

hyper_params        = list(# ↓↓↓↓↓ set params
                      ntrees = ntrees_opt,
                      max_depth = max_depth_opt,
                      nbins = nbins_opt)

search_criteria     = list(# ↓↓↓↓↓ set params
                      strategy = "RandomDiscrete",
                      max_models = 60,
                      stopping_rounds = 5,
                      stopping_metric = "logloss",
                      stopping_tolerance=1e-3,
                      seed = seed_num)

grid                = h2o.grid(# ↓↓↓↓↓ set params
                      algorithm = "gbm",
                      grid_id = "gbm_grid",
                      training_frame = train,
                      validation_frame = valid,
                      score_each_iteration = T,
                      x = predictors,
                      y = response,
                      hyper_params = hyper_params,
                      search_criteria = search_criteria)

# best model
gbm_grid       = h2o.getGrid("gbm_grid", sort_by = "logloss", decreasing = F)
best_model     = h2o.getModel(gbm_grid@model_ids[[1]])
best_ntrees    = best_model@allparameters$ntrees
best_max_depth = best_model@allparameters$max_depth
best_nbins     = best_model@allparameters$nbins
print(gbm_grid)

# run tunned model
options(warn=-1)
tunned_gbm        = h2o.gbm( # ↓↓↓↓↓ set params
                    training_frame = train, 
                    validation_frame = valid, 
                    x = predictors, 
                    y = response, 
                    score_each_iteration = T,
                    # early stopping rule
                    stopping_rounds = 5,
                    stopping_metric = "logloss",
                    stopping_tolerance = 1e-3,
                    #  best params
                    ntrees = best_ntrees, 
                    max_depth = best_max_depth,
                    nbins = best_nbins,
                    seed = seed_num) 
options(warn=0)

# summary
tunned_thred     = h2o.find_threshold_by_max_metric(h2o.performance(tunned_gbm, newdata = test), "f1")
tunned_cm        = h2o.confusionMatrix(h2o.performance(tunned_gbm, newdata = test), thresholds = tunned_thred)
tunned_Accuracy  = h2o.accuracy(h2o.performance(tunned_gbm, newdata = test), thresholds = tunned_thred)
tunned_recall    = h2o.recall(h2o.performance(tunned_gbm, newdata = test), thresholds = tunned_thred)
tunned_precision = h2o.precision(h2o.performance(tunned_gbm, newdata = test), thresholds = tunned_thred)
tunned_AUC = h2o.auc(h2o.performance(tunned_gbm, newdata = test))

print("disabled_26\n")
tunned_cm
print(paste("tunned_ACCURACY   : ", tunned_Accuracy, sep = ""))
print(paste("tunned_AUC        : ", tunned_AUC, sep = ""))
print(paste("tunned_recall     : ", tunned_recall, sep = ""))
print(paste("tunned_precision  : ", tunned_precision, sep = ""))

h2o.saveModel(tunned_gbm, path = "C:/Users/mijin/Desktop/output", force = TRUE)


#■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■