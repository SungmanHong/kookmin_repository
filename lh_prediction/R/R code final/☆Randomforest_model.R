# program name : randomForest
# 작성자 :


#■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
# <<load library>>
rm(list = ls())

library(h2o)
library(stringr)
library(dplyr)
library(data.table)
seed_num=2016

#h2o.shutdown()
gc(reset = T)

localH2O <- h2o.init() ## using a max 1GB of RAM
h2o.removeAll() 
#■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■


#■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
# <<data 불러오기>>

h2oData <- read.csv('./data/general_36.csv', header = TRUE)

# 컬럼제거(1: SEQ_NUM, 2:SEQ_ 4:REGNUM_BLOCK, 8:W_8) ,3:BLOCK_NM
h2oData <- h2oData[, - c(1:4, 8)]
# 파생변수제외 선택(33~: 파생변수)
#h2oData <- h2oData[, c(1:32)]

## H2O DataFrame으로 변경
h2oData <- as.h2o(h2oData)

## data 분리(train/valid/test)
splits <- h2o.splitFrame(h2oData, c(0.6, 0.2), seed = seed_num)
train <- h2o.assign(splits[[1]], "train.hex") # 60%
valid <- h2o.assign(splits[[2]], "valid.hex") # 60%
test <- h2o.assign(splits[[3]], "test.hex") # 60%

## 예측하고자 하는 변수지정
response = 'W_4' # 당첨/탈락 여부 필드

## predictors 지정
predictors <- setdiff(names(train), response)
#■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■


#■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
## 1 <<rf>>

checkpoint_rf <- h2o.randomForest(
                      training_frame = train, ## the H2O frame for training
                      validation_frame = valid, ## the H2O frame for validation (not required)
                      x = predictors, ## the predictor columns, by column index
                      y = response, ## the target index (what we are predicting)
                      score_each_iteration = T,
                      stopping_rounds = 2,
                      ntrees = 50, # max_after_balance_size=5, 
                      model_id = "rf_covType1", ## name the model in H2O
                      seed = seed_num) ## Set the random seed for reproducability

rf <- h2o.randomForest(
                      training_frame = train, ## the H2O frame for training
                      validation_frame = valid, ## the H2O frame for validation (not required)
                      x = predictors, ## the predictor columns, by column index
                      y = response, ## the target index (what we are predicting)
                      score_each_iteration = T,
                      stopping_rounds = 2,
                      checkpoint = checkpoint_rf@model_id,
                      ntrees = 50, # max_after_balance_size=5, 
                      model_id = "rf_covType1", ## name the model in H2O
                      seed = seed_num) ## Set the random seed for reproducability
summary(rf)

# summary
rf_pred = h2o.predict(object = rf, newdata = test)
thred = h2o.find_threshold_by_max_metric(h2o.performance(rf, newdata = test), "f1")
rf_cm = h2o.confusionMatrix(h2o.performance(rf, newdata = test), thresholds = thred)
rf_Accuracy = h2o.accuracy(h2o.performance(rf, newdata = test), thresholds = thred)
rf_recall = h2o.recall(h2o.performance(rf, newdata = test), thresholds = thred)
rf_precision = h2o.precision(h2o.performance(rf, newdata = test), thresholds = thred)
rf_AUC = h2o.auc(h2o.performance(rf, newdata = test))
#■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■


#■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
# 2 <<random grid search>>

ntrees_opt = seq(50, 200, 1)
max_depth_opt = seq(20, 50, 1)
nbins_opt = seq(20, 50, 1)
mtries_opt = seq(round(sqrt(ncol(train))), ncol(train)/2, 1)

hyper_params = list(# ↓↓↓↓↓ set params
                            ntrees = ntrees_opt,
                            max_depth = max_depth_opt,
                            nbins     = nbins_opt,
                            mtries    = mtries_opt)

search_criteria = list(# ↓↓↓↓↓ set params
                            strategy = "RandomDiscrete",
                            max_models = 60,
                            stopping_rounds = 5,
                            stopping_metric = "logloss",
                            stopping_tolerance=1e-3,
                            seed = seed_num)

grid = h2o.grid(# ↓↓↓↓↓ set params
                            algorithm = "randomForest",
                            grid_id = "rf_grid",
                            training_frame = train,
                            validation_frame = valid,
                            score_each_iteration = T,
                            x = predictors,
                            y = response,
                            hyper_params = hyper_params,
                            search_criteria = search_criteria)

# best model
rf_grid = h2o.getGrid("rf_grid", sort_by = "logloss", decreasing = F)
best_model = h2o.getModel(rf_grid@model_ids[[1]])
best_ntrees = best_model@allparameters$ntrees
best_max_depth = best_model@allparameters$max_depth
best_nbins = best_model@allparameters$nbins
best_mtries = best_model@allparameters$mtries
print(rf_grid)

# run tunned model
rf <- h2o.randomForest( # ↓↓↓↓↓ set params
                            training_frame = train, ## the H2O frame for training
                            validation_frame = valid, ## the H2O frame for validation (not required)
                            x = predictors, ## the predictor columns, by column index
                            y = response, ## the target index (what we are predicting)
                            score_each_iteration = T,
                            # early stopping rule
                            stopping_rounds = 5,
                            stopping_metric = "logloss",
                            stopping_tolerance = 1e-3,
                            #  best params
                            ntrees = best_ntrees, # max_after_balance_size=5,
                            max_depth = best_max_depth,
                            mtries = best_mtries,
                            nbins = best_nbins,
                            seed = seed_num) ## Set the random seed for reproducability
summary(rf)

# summary
rf_pred = h2o.predict(object = rf, newdata = test)
thred = h2o.find_threshold_by_max_metric(h2o.performance(rf, newdata = test), "f1")
rf_cm = h2o.confusionMatrix(h2o.performance(rf, newdata = test), thresholds = thred)
tunned_rf_Accuracy = h2o.accuracy(h2o.performance(rf, newdata = test), thresholds = thred)
tunned_rf_recall = h2o.recall(h2o.performance(rf, newdata = test), thresholds = thred)
tunned_rf_precision = h2o.precision(h2o.performance(rf, newdata = test), thresholds = thred)
tunned_rf_AUC = h2o.auc(h2o.performance(rf, newdata = test))
print("general_46\n")
rf_cm
print(paste("ACCURACY   :", rf_Accuracy, sep = ""))
print(paste("AUC        :", rf_AUC, sep = ""))
print(paste("recall     :", rf_recall, sep = ""))
print(paste("precision  :", rf_precision, sep = ""))


print(paste("tunned_ACCURACY   : ", tunned_rf_Accuracy, sep = ""))
print(paste("tunned_AUC        : ", tunned_rf_AUC, sep = ""))
print(paste("tunned_recall     : ", tunned_rf_recall, sep = ""))
print(paste("tunned_precision  : ", tunned_rf_precision, sep = ""))

summary(rf)
h2o.saveModel(rf,path="C:/Users/mijin/Desktop/output",force = TRUE)
