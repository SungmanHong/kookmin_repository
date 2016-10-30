# rm(list = ls())
# install.packages("h2o")
#library(h2o)
rm(list = ls())

localH2O <- h2o.init(max_mem_size = '1g') ## using a max 1GB of RAM
h2o.removeAll() ## clean slate - just in case the cluster was already running


#'highage_26.csv', 'highage_36.csv', 'highage_46.csv', 'disabled_26,csv',
#'disabled_36.csv', 'disabled_46.csv', 'general_26.csv', 'general_36.csv', 'general_46.csv',
#'married_46.csv'

## data 불러오기
h2oData <- read.table('general_36.csv', header = TRUE)
head(h2oData)

h2oData <- h2oData[, - c(1:4, 8)]
head(h2oData)

## H2O DataFrame으로 변경
h2oData <- as.h2o(h2oData)

## data 분리(train/valid/test)
splits <- h2o.splitFrame(h2oData, c(0.6, 0.2), seed = 1111)
train <- h2o.assign(splits[[1]], "train.hex") # 60%
valid <- h2o.assign(splits[[2]], "valid.hex") # 60%
test <- h2o.assign(splits[[3]], "test.hex") # 60%
dim(train);dim(valid);dim(test);

#파생변수 제외 data: train,valid,test
train_ex <- train[, c(1:25)]
valid_ex <- valid[, c(1:25)]
test_ex <- test[, c(1:25)]
dim(train_ex);dim(valid_ex);dim(test_ex);


## 예측하고자 하는 변수지정
response = 'W_4' # 당첨/탈락 여부 필드
## predictors 지정
predictors <- setdiff(names(train), response)
predictors_ex <- setdiff(names(train_ex), response)
#predictors;predictors_ex;

## 모델 생성(deeplearning) 및 예측 #############################################################################################
m <- h2o.deeplearning(
    model_id = "dl_model",
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
summary(m)

m_ex <- h2o.deeplearning(
      model_id = "dl_model_ex",
      training_frame = train_ex,
      validation_frame = valid_ex, ## validation dataset: used for scoring and early stopping
      x = predictors_ex,
      y = response,
      #activation="Rectifier",  ## default
      #hidden=c(200,200),       ## default: 2 hidden layers with 200 neurons each
      epochs = 1,
      variable_importances = T ## not enabled by default
    )
## 모델 확인
summary(m_ex)

## test 데이터를 통해 모델 정확도 예측
pred <- h2o.predict(m, test)
pred_ex <- h2o.predict(m_ex, test_ex)
#pred

#정확도=true/tot
m_cm <- h2o.confusionMatrix(m, test)
m_Accuracy <- (m_cm[1, 1] + m_cm[2, 2]) / sum(m_cm[1:2, 1:2])

m_cm_ex <- h2o.confusionMatrix(m_ex, test_ex)
m_Accuracy_ex <- (m_cm_ex[1, 1] + m_cm_ex[2, 2]) / sum(m_cm_ex[1:2, 1:2])

m_Accuracy;m_Accuracy_ex

#hit raio=TruePositive=true pos/tot pos
m_hit <- m_cm[2, 2] / sum(m_cm[1:2, 2])
m_hit_ex <- m_cm_ex[2, 2] / sum(m_cm_ex[1:2, 2])
    
m_hit;m_hit_ex;
#m_cm;m_cm_ex;
#summary(pred_ex$pred)

#AUC
m_perf <- h2o.performance(m, newdata = test)
m_AUC <- m_perf@metrics$AUC

m_perf_ex <- h2o.performance(m_ex, newdata = test_ex)
m_AUC_ex <- m_perf_ex@metrics$AUC
m_AUC;m_AUC_ex

#################################################################################################################################
## 모델 생성(randomforest) ######################################################################################################
rf <- h2o.randomForest(## h2o.randomForest function
  training_frame = train, ## the H2O frame for training
  validation_frame = valid, ## the H2O frame for validation (not required)
  x = predictors, ## the predictor columns, by column index
  y = response, ## the target index (what we are predicting)
  model_id = "rf_covType", ## name the model in H2O
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
summary(rf)

rf_ex <- h2o.randomForest(## h2o.randomForest function
      training_frame = train_ex, ## the H2O frame for training
      validation_frame = valid_ex, ## the H2O frame for validation (not required)
      x = predictors_ex, ## the predictor columns, by column index
      y = response, ## the target index (what we are predicting)
      model_id = "rf_covType_ex",
      ntrees = 200, 
      stopping_rounds = 2,
      score_each_iteration = T,
      seed = 1000000)
summary(rf_ex)
 
finalRf_predictions <- h2o.predict(
  object = rf, newdata = test)
finalRf_predictions_ex <- h2o.predict(
  object = rf_ex, newdata = test_ex)


#정확도
rf_cm <- h2o.confusionMatrix(rf, test)
rf_Accuracy <- (rf_cm[1, 1] + rf_cm[2, 2]) / sum(rf_cm[1:2, 1:2])

rf_cm_ex <- h2o.confusionMatrix(rf_ex, test_ex)
rf_Accuracy_ex <- (rf_cm_ex[1, 1] + rf_cm_ex[2, 2]) / sum(rf_cm_ex[1:2, 1:2])
rf_Accuracy;rf_Accuracy_ex

#hit raio=TruePositive=true pos/tot pos
rf_hit <- rf_cm[2, 2] / sum(rf_cm[1:2, 2])
rf_hit_ex <- rf_cm_ex[2, 2] / sum(rf_cm_ex[1:2, 2])
rf_hit;rf_hit_ex

#AUC
rf_perf <- h2o.performance(rf, newdata = test)
rf_AUC <- rf_perf@metrics$AUC

rf_perf_ex <- h2o.performance(rf_ex, newdata = test_ex)
rf_AUC_ex <- rf_perf_ex@metrics$AUC
rf_AUC;rf_AUC_ex

################################################################################################################################
## 모델생성(gbm) ###############################################################################################################
gbm <- h2o.gbm(
  training_frame = train, ## the H2O frame for training
  validation_frame = valid, ## the H2O frame for validation (not required)
  x = predictors, ## the predictor columns, by column index
  y = response, ## the target index (what we are predicting)
  model_id = "gbm_covType1", ## name the model in H2O
  seed = 2000000) ## Set the random seed for reproducability
summary(gbm)

gbm_ex <- h2o.gbm(
      training_frame = train_ex, ## the H2O frame for training
      validation_frame = valid_ex, ## the H2O frame for validation (not required)
      x = predictors_ex, ## the predictor columns, by column index
      y = response, ## the target index (what we are predicting)
      model_id = "gbm_covType_ex", ## name the model in H2O
      seed = 2000000) ## Set the random seed for reproducability
#summary(gbm_ex)

finalgbm_predictions <- h2o.predict(
      object = gbm, newdata = test)
finalgbm_predictions_ex <- h2o.predict(
      object = gbm_ex, newdata = test_ex)

#finalgbm_predictions;finalgbm_predictions_ex

#정확도
gbm_cm <- h2o.confusionMatrix(gbm, test)
gbm_Accuracy <- (gbm_cm[1, 1] + gbm_cm[2, 2]) / sum(gbm_cm[1:2, 1:2])

gbm_cm_ex <- h2o.confusionMatrix(gbm_ex, test_ex)
gbm_Accuracy_ex <- (gbm_cm_ex[1, 1] + gbm_cm_ex[2, 2]) / sum(gbm_cm_ex[1:2, 1:2])
gbm_Accuracy;gbm_Accuracy_ex

#hit raio, TruePositive
gbm_hit <- gbm_cm[2, 2] / sum(gbm_cm[1:2, 2])
gbm_hit_ex <- gbm_cm_ex[2, 2] / sum(gbm_cm_ex[1:2, 2])
gbm_hit;gbm_hit_ex

#AUC
gbm_perf <- h2o.performance(gbm, newdata = test)
gbm_AUC <- gbm_perf@metrics$AUC

gbm_perf_ex <- h2o.performance(gbm_ex, newdata = test_ex)
gbm_AUC_ex <- gbm_perf_ex@metrics$AUC
gbm_AUC;gbm_AUC_ex

perf_sum <- data.frame(
    EX.Accuracy = c(m_Accuracy_ex, rf_Accuracy_ex, gbm_Accuracy_ex),
    TEST.Accuracy = c(m_Accuracy, rf_Accuracy, gbm_Accuracy),
    EX.HIT = c(m_hit_ex, rf_hit_ex, gbm_hit_ex), 
    TEST.HIT = c(m_hit, rf_hit, gbm_hit),
    EX.AUC = c(m_AUC_ex, rf_AUC_ex, gbm_AUC_ex), 
    TEST.AUC = c(m_AUC, rf_AUC, gbm_AUC))
rownames(perf_sum) <- c("deep", "rf", "gbm")
print("general_36");print(dim(h2oData)[1]);
print(perf_sum);

#("deep");head(m@model$variable_importances,10);
#("rf");head(rf@model$variable_importances,10);
#("gbm");head(gbm@model$variable_importances,10);