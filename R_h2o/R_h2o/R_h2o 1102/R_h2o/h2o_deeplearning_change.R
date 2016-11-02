# rm(list = ls())
# install.packages("h2o")
library(h2o)

localH2O <- h2o.init(max_mem_size = '1g') ## using a max 1GB of RAM
h2o.removeAll() ## clean slate - just in case the cluster was already running

## data 불러오기
general_36 <- read.table('general_36.csv', header = TRUE)
head(general_36)

general_36 <- general_36[,-c(1:4,8)]
head(general_36)

## H2O DataFrame으로 변경
general_36 <- as.h2o(general_36)
general_36

## data 분리(train/valid/test)
splits <- h2o.splitFrame(general_36, c(0.6, 0.2), seed = 1234)
train <- h2o.assign(splits[[1]], "train.hex") # 60%
valid <- h2o.assign(splits[[2]], "valid.hex") # 60%
test <- h2o.assign(splits[[3]], "test.hex") # 60%

## 예측하고자 하는 변수지정
response = 'W_4' # 당첨/탈락 여부 필드
## predictors 지정
predictors <- setdiff(names(general_36), response)
predictors

## 모델 생성(deeplearning) 및 예측 #############################################################################################
m1 <- h2o.deeplearning(
  model_id = "dl_model_first",
  training_frame = train,
  validation_frame = valid, ## validation dataset: used for scoring and early stopping
  x = predictors,
  y = response,
  #activation="Rectifier",  ## default
  #hidden=c(200,200),       ## default: 2 hidden layers with 200 neurons each
  epochs = 1,
  variable_importances = T ## not enabled by default
)

## 모델 확인
summary(m1)
## test 데이터를 통해 모델 정확도 예측
pred <- h2o.predict(m1, test)
pred
## 정확도
test$Accuracy <- pred$predict == test$W_4
## 에러
1 - mean(test$Accuracy)
#################################################################################################################################

## 모델 생성(randomforest) ######################################################################################################
rf1 <- h2o.randomForest(## h2o.randomForest function
  training_frame = train, ## the H2O frame for training
  validation_frame = valid, ## the H2O frame for validation (not required)
  x = predictors, ## the predictor columns, by column index
  y = response, ## the target index (what we are predicting)
  model_id = "rf_covType_v1", ## name the model in H2O
                                 ##   not required, but helps use Flow
  ntrees = 200, ## use a maximum of 200 trees to create the
                                 ##  random forest model. The default is 50.
                                 ##  I have increased it because I will let 
                                 ##  the early stopping criteria decide when
                                 ##  the random forest is sufficiently accurate
  stopping_rounds = 2, ## Stop fitting new trees when the 2-tree
                                 ##  average is within 0.001 (default) of 
                                 ##  the prior two 2-tree averages.
                                 ##  Can be thought of as a convergence setting
  score_each_iteration = T, ## Predict against training and validation for
                                 ##  each tree. Default will skip several.
  seed = 1000000) ## Set the random seed so that this can be
##  reproduce
summary(rf1)
#rf1@model$validation_metrics
# h2o.hit_ratio_table(rf1, valid = T)[1, 2]

finalRf_predictions <- h2o.predict(
  object = rf1
  , newdata = test)

finalRf_predictions
mean(finalRf_predictions$predict == test$W_4) ##1?? 왜 1인지 test set accuracy
test$Accuracy <- finalRf_predictions$predict == test$W_4
1 - mean(test$Accuracy)
################################################################################################################################

## 모델생성(gbm) ###############################################################################################################
gbm1 <- h2o.gbm(
  training_frame = train, ## the H2O frame for training
  validation_frame = valid, ## the H2O frame for validation (not required)
  x = predictors, ## the predictor columns, by column index
  y = response, ## the target index (what we are predicting)
  model_id = "gbm_covType1", ## name the model in H2O
  seed = 2000000) ## Set the random seed for reproducability

summary(gbm1)
# h2o.hit_ratio_table(gbm1, valid = T)[1, 2]

finalgbm_predictions <- h2o.predict(
  object = gbm1
  , newdata = test)

finalgbm_predictions
mean(finalgbm_predictions$predict == test$W_4) ##1?? 왜 1인지 test set accuracy
test$Accuracy <- finalRf_predictions$predict == test$W_4
1 - mean(test$Accuracy)
################################################################################################################################
