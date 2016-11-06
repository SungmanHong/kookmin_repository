# program name : randomForest
# 작성자 :


#■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
# <<load library>>

library(h2o)
library(stringr)
library(dplyr)
library(data.table)

# h2o.shutdown()
localH2O <- h2o.init(max_mem_size = '1g') ## using a max 1GB of RAM
h2o.removeAll() ## clean slate - just in case the cluster was already running
#■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■


#■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
# <<data 불러오기>>

h2oData <- read.table('married_46.csv', header = TRUE)
head(h2oData) # 719 row
str(h2oData)
# 컬럼제거(1: SEQ_NUM, 2:SEQ_, 4:REGNUM_BLOCK, 8:W_8)
h2oData <- h2oData[, - c(1, 2, 4, 8)]

## H2O DataFrame으로 변경
h2oData <- as.h2o(h2oData)

## data 분리(train/valid/test)
splits <- h2o.splitFrame(h2oData, c(0.6, 0.2), seed = 1111)
train <- h2o.assign(splits[[1]], "train.hex") # 60%
valid <- h2o.assign(splits[[2]], "valid.hex") # 60%
test <- h2o.assign(splits[[3]], "test.hex") # 60%
dim(train);
dim(valid);
dim(test);

## 예측하고자 하는 변수지정
response = 'W_4' # 당첨/탈락 여부 필드

## predictors 지정
predictors <- setdiff(names(train), response)
#■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■


#■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
## <<rf>>

checkpoint_rf <- h2o.randomForest(
  training_frame = train, ## the H2O frame for training
  validation_frame = valid, ## the H2O frame for validation (not required)
  x = predictors, ## the predictor columns, by column index
  y = response, ## the target index (what we are predicting)
  score_each_iteration = T,
  stopping_rounds = 2,
  ntrees = 10000, # max_after_balance_size=5, 
  model_id = "rf_covType1", ## name the model in H2O
  seed = 2000000) ## Set the random seed for reproducability

rf <- h2o.randomForest(
  training_frame = train, ## the H2O frame for training
  validation_frame = valid, ## the H2O frame for validation (not required)
  x = predictors, ## the predictor columns, by column index
  y = response, ## the target index (what we are predicting)
  score_each_iteration = T,
  stopping_rounds = 2,
  checkpoint = checkpoint_rf@model_id,
  ntrees = 10000, # max_after_balance_size=5, 
  model_id = "rf_covType1", ## name the model in H2O
  seed = 2000000) ## Set the random seed for reproducability
summary(rf)

# summary
rf_pred = h2o.predict(object = rf, newdata = test)
thred = h2o.find_threshold_by_max_metric(h2o.performance(rf, newdata = test), "f1")
rf_Accuracy = h2o.accuracy(h2o.performance(rf, newdata = test), thresholds = thred)
rf_hit = h2o.tpr(h2o.performance(rf, newdata = test), thresholds = thred)
rf_AUC = h2o.auc(h2o.performance(rf, newdata = test))
old = h2o.confusionMatrix(h2o.performance(rf, newdata = test), thresholds = thred)
rf_hit
rf_AUC
#■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■


#■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
# <<new data>>

# setwd("C:/kookmin_repository/R_h2o 1102/R_h2o/plus")
tmp <- read.table('married_46_plus.csv', header = TRUE)
head(tmp)
tmp = tmp[, - c(1, 2, 4, 8)]
# colnames(tmp) = colnames(train)
tmp = as.h2o(tmp)

thred_plus = h2o.find_threshold_by_max_metric(h2o.performance(rf, newdata = tmp), "f1")
rf_hit_plus = h2o.tpr(h2o.performance(rf, newdata = tmp), thresholds = thred_plus)
rf_AUC_plus = h2o.auc(h2o.performance(rf, newdata = tmp))
new = h2o.confusionMatrix(h2o.performance(rf, newdata = tmp), thresholds = thred_plus)
rf_hit_plus
rf_AUC_plus
#■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■