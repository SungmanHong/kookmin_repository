# rm(list = ls())
# install.packages("h2o")
#library(h2o)
#library(stringr);library(dplyr)
rm(list = ls())

localH2O <- h2o.init(max_mem_size = '1g') ## using a max 1GB of RAM
h2o.removeAll() ## clean slate - just in case the cluster was already running

#'highage_26.csv', 'highage_36.csv', 'highage_46.csv', 'disabled_26.csv',
#'disabled_36.csv', 'disabled_46.csv', 'general_26.csv', 'general_36.csv', 'married_46.csv',
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
dim(train);
dim(valid);
dim(test);

#파생변수 제외 data: train,valid,test
train_ex <- train[, c(1:22)]
valid_ex <- valid[, c(1:22)]
test_ex <- test[, c(1:22)]
dim(train_ex);
dim(valid_ex);
dim(test_ex);


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

h2o.table(test$W_4)
thred = h2o.find_threshold_by_max_metric(h2o.performance(m, newdata = test), "f1")
h2o.confusionMatrix(h2o.performance(m, newdata = test), thresholds = thred)
m_Accuracy <- h2o.accuracy(h2o.performance(m, newdata = test), thresholds = thred)
m_hit <- h2o.tpr(h2o.performance(m, newdata = test), thresholds = thred)
m_AUC <- h2o.auc(h2o.performance(m, newdata = test))


h2o.table(test_ex$W_4)
thred = h2o.find_threshold_by_max_metric(h2o.performance(m_ex, newdata = test_ex), "f1")
h2o.confusionMatrix(h2o.performance(m_ex, newdata = test_ex), thresholds = thred)
m_Accuracy_ex <- h2o.accuracy(h2o.performance(m_ex, newdata = test_ex), thresholds = thred)
m_hit_ex <- h2o.tpr(h2o.performance(m_ex, newdata = test_ex), thresholds = thred)
m_AUC_ex <- h2o.auc(h2o.performance(m_ex, newdata = test_ex))

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

rf_pred <- h2o.predict(object = rf, newdata = test)
rf_pred_ex <- h2o.predict(object = rf_ex, newdata = test_ex)


h2o.table(test$W_4)
thred = h2o.find_threshold_by_max_metric(h2o.performance(rf, newdata = test), "f1")
h2o.confusionMatrix(h2o.performance(rf, newdata = test), thresholds = thred)
rf_Accuracy <- h2o.accuracy(h2o.performance(rf, newdata = test), thresholds = thred)
rf_hit <- h2o.tpr(h2o.performance(rf, newdata = test), thresholds = thred)
rf_AUC <- h2o.auc(h2o.performance(rf, newdata = test))

h2o.table(test_ex$W_4)
thred = h2o.find_threshold_by_max_metric(h2o.performance(rf_ex, newdata = test_ex), "f1")
h2o.confusionMatrix(h2o.performance(rf_ex, newdata = test_ex), thresholds = thred)
rf_Accuracy_ex <- h2o.accuracy(h2o.performance(rf_ex, newdata = test_ex), thresholds = thred)
rf_hit_ex <- h2o.tpr(h2o.performance(rf_ex, newdata = test_ex), thresholds = thred)
rf_AUC_ex <- h2o.auc(h2o.performance(rf_ex, newdata = test_ex))
################################################################################################################################
## 모델생성(gbm) ###############################################################################################################
checkpoint <- h2o.gbm(
  training_frame = train, ## the H2O frame for training
  validation_frame = valid, ## the H2O frame for validation (not required)
  x = predictors, ## the predictor columns, by column index
  y = response, ## the target index (what we are predicting)
  balance_classes = T,
  ntrees = 10000, # max_after_balance_size=5, 
  model_id = "gbm_covType1", ## name the model in H2O
  seed = 2000000) ## Set the random seed for reproducability


gbm <- h2o.gbm(
  training_frame = train, ## the H2O frame for training
  validation_frame = valid, ## the H2O frame for validation (not required)
  x = predictors, ## the predictor columns, by column index
  y = response, ## the target index (what we are predicting)
  balance_classes = T,
  ntrees = 20000, # max_after_balance_size=5, 
  checkpoint = checkpoint@model_id,
  model_id = "gbm_covType1", ## name the model in H2O ## not enabled by default
  seed = 2000000) ## Set the random seed for reproducability
summary(gbm)

checkpoint <- h2o.gbm(
  training_frame = train_ex, ## the H2O frame for training
  validation_frame = valid_ex, ## the H2O frame for validation (not required)
  x = predictors_ex, ## the predictor columns, by column index
  y = response, ## the target index (what we are predicting)
  balance_classes = T,
  ntrees = 10000, # max_after_balance_size=5, 
  model_id = "gbm_covType2", ## name the model in H2O
  seed = 2000000) ## Set the random seed for reproducability

gbm_ex <- h2o.gbm(
      training_frame = train_ex, ## the H2O frame for training
      validation_frame = valid_ex, ## the H2O frame for validation (not required)
  x = predictors_ex, ## the predictor columns, by column index
  y = response, ## the target index (what we are predicting)
  balance_classes = T,
  ntrees = 20000, # max_after_balance_size=5, 
  checkpoint = checkpoint@model_id,
  model_id = "gbm_covType2", ## name the model in H2O
  seed = 2000000) ## Set the random seed for reproducability
#summary(gbm_ex)

gbm_pred <- h2o.predict(object = gbm, newdata = test)
gbm_pred_ex <- h2o.predict(object = gbm_ex, newdata = test_ex)
#finalgbm_predictions;finalgbm_predictions_ex


h2o.table(test$W_4)
thred = h2o.find_threshold_by_max_metric(h2o.performance(gbm, newdata = test), "f1")
h2o.confusionMatrix(h2o.performance(gbm, newdata = test), thresholds = thred)
gbm_Accuracy <- h2o.accuracy(h2o.performance(gbm, newdata = test), thresholds = thred)
gbm_hit <- h2o.tpr(h2o.performance(gbm, newdata = test), thresholds = thred)
gbm_AUC <- h2o.auc(h2o.performance(gbm, newdata = test))

h2o.table(test_ex$W_4)
thred = h2o.find_threshold_by_max_metric(h2o.performance(gbm_ex, newdata = test_ex), "f1")
h2o.confusionMatrix(h2o.performance(gbm_ex, newdata = test_ex), thresholds = thred)
gbm_Accuracy_ex <- h2o.accuracy(h2o.performance(gbm_ex, newdata = test_ex), thresholds = thred)
gbm_hit_ex <- h2o.tpr(h2o.performance(gbm_ex, newdata = test_ex), thresholds = thred)
gbm_AUC_ex <- h2o.auc(h2o.performance(gbm_ex, newdata = test_ex))


perf_sum <- data.frame(
    EX.Accuracy = c(m_Accuracy_ex[[1]], rf_Accuracy_ex[[1]], gbm_Accuracy_ex[[1]]),
    TEST.Accuracy = c(m_Accuracy[[1]], rf_Accuracy[[1]], gbm_Accuracy[[1]]),
    EX.HIT = c(m_hit_ex[[1]], rf_hit_ex[[1]], gbm_hit_ex[[1]]),
    TEST.HIT = c(m_hit[[1]], rf_hit[[1]], gbm_hit[[1]]),
    EX.AUC = c(m_AUC_ex[[1]], rf_AUC_ex[[1]], gbm_AUC_ex[[1]]),
    TEST.AUC = c(m_AUC[[1]], rf_AUC[[1]], gbm_AUC[[1]]))
rownames(perf_sum) <- c("deep", "rf", "gbm")
print("general_36");
print(dim(h2oData)[1]);
print(perf_sum);


#variable importance 확인
#("deep");head(m@model$variable_importances,10);
#("rf");head(rf@model$variable_importances,10);
#("gbm");head(gbm@model$variable_importances,10);



#########################plus data로 검증#########################
##################################################################
plusData <- read.table('./plus/general_36_plus.csv', header = TRUE)
head(plusData)

plusData <- plusData[, - c(1:4, 8)]
head(plusData)

## H2O DataFrame으로 변경, 파생변수 제외
plusData <- as.h2o(plusData)
plusData_ex <- plusData[, c(1:22)]

str(plusData)
####################

pluspred <- h2o.predict(m, plusData)
pluspred_ex <- h2o.predict(m_ex, plusData_ex)

h2o.table(plusData$W_4)
thred = h2o.find_threshold_by_max_metric(h2o.performance(m, newdata = plusData), "f1")
h2o.confusionMatrix(h2o.performance(m, newdata = plusData), thresholds = thred)
#h2o.confusionMatrix(h2o.performance(m, newdata = plusData))
plusm_Accuracy <- h2o.accuracy(h2o.performance(m, newdata = plusData), thresholds = thred)
plusm_hit <- h2o.tpr(h2o.performance(m, newdata = plusData), thresholds = thred)
plusm_AUC <- h2o.auc(h2o.performance(m, newdata = plusData))

h2o.table(plusData_ex$W_4)
thred = h2o.find_threshold_by_max_metric(h2o.performance(m_ex, newdata = plusData_ex), "f1")
h2o.confusionMatrix(h2o.performance(m_ex, newdata = plusData_ex), thresholds = thred)
#h2o.confusionMatrix(h2o.performance(m_ex, newdata = plusData_ex))
plusm_Accuracy_ex <- h2o.accuracy(h2o.performance(m_ex, newdata = plusData_ex), thresholds = thred)
plusm_hit_ex <- h2o.tpr(h2o.performance(m_ex, newdata = plusData_ex), thresholds = thred)
plusm_AUC_ex <- h2o.auc(h2o.performance(m_ex, newdata = plusData_ex))

#####rf

pluspred <- h2o.predict(rf, plusData)
pluspred_ex <- h2o.predict(rf_ex, plusData_ex)

h2o.table(plusData$W_4)
thred = h2o.find_threshold_by_max_metric(h2o.performance(rf, newdata = plusData), "f1")
h2o.confusionMatrix(h2o.performance(rf, newdata = plusData), thresholds = thred)
#h2o.confusionMatrix(h2o.performance(rf, newdata = plusData))
plusrf_Accuracy <- h2o.accuracy(h2o.performance(rf, newdata = plusData), thresholds = thred)
plusrf_hit <- h2o.tpr(h2o.performance(rf, newdata = plusData), thresholds = thred)
plusrf_AUC <- h2o.auc(h2o.performance(rf, newdata = plusData))

h2o.table(plusData_ex$W_4)
thred = h2o.find_threshold_by_max_metric(h2o.performance(rf_ex, newdata = plusData_ex), "f1")
h2o.confusionMatrix(h2o.performance(rf_ex, newdata = plusData_ex), thresholds = thred)
#h2o.confusionMatrix(h2o.performance(rf_ex, newdata = plusData_ex))
plusrf_Accuracy_ex <- h2o.accuracy(h2o.performance(rf_ex, newdata = plusData_ex), thresholds = thred)
plusrf_hit_ex <- h2o.tpr(h2o.performance(rf_ex, newdata = plusData_ex), thresholds = thred)
plusrf_AUC_ex <- h2o.auc(h2o.performance(rf_ex, newdata = plusData_ex))


#####gbm
pluspred <- h2o.predict(gbm, plusData)
pluspred_ex <- h2o.predict(gbm_ex, plusData_ex)

h2o.table(plusData$W_4)
thred = h2o.find_threshold_by_max_metric(h2o.performance(gbm, newdata = plusData), "f1")
h2o.confusionMatrix(h2o.performance(gbm, newdata = plusData), thresholds = thred)
#h2o.confusionMatrix(h2o.performance(gbm, newdata = plusData))
plusgbm_Accuracy <- h2o.accuracy(h2o.performance(gbm, newdata = plusData), thresholds = thred)
plusgbm_hit <- h2o.tpr(h2o.performance(gbm, newdata = plusData), thresholds = thred)
plusgbm_AUC <- h2o.auc(h2o.performance(gbm, newdata = plusData))

h2o.table(plusData_ex$W_4)
thred = h2o.find_threshold_by_max_metric(h2o.performance(gbm_ex, newdata = plusData_ex), "f1")
h2o.confusionMatrix(h2o.performance(gbm_ex, newdata = plusData_ex), thresholds = thred)
#h2o.confusionMatrix(h2o.performance(gbm_ex, newdata = plusData_ex))
plusgbm_Accuracy_ex <- h2o.accuracy(h2o.performance(gbm_ex, newdata = plusData_ex), thresholds = thred)
plusgbm_hit_ex <- h2o.tpr(h2o.performance(gbm_ex, newdata = plusData_ex), thresholds = thred)
plusgbm_AUC_ex <- h2o.auc(h2o.performance(gbm_ex, newdata = plusData_ex))


plus_sum <- data.frame(
    EXPLUS.Accuracy = c(plusm_Accuracy_ex[[1]], plusrf_Accuracy_ex[[1]], plusgbm_Accuracy_ex[[1]]),
    PLUS.Accuracy = c(plusm_Accuracy[[1]], plusrf_Accuracy[[1]], plusgbm_Accuracy[[1]]),
    EXPLUS.HIT = c(plusm_hit_ex[[1]], plusrf_hit_ex[[1]], plusgbm_hit_ex[[1]]),
    PLUS.HIT = c(plusm_hit[[1]], plusrf_hit[[1]], plusgbm_hit[[1]]),
    EXPLUS.AUC = c(plusm_AUC_ex[[1]], plusrf_AUC_ex[[1]], plusgbm_AUC_ex[[1]]),
    PLUS.AUC = c(plusm_AUC[[1]], plusrf_AUC[[1]], plusgbm_AUC[[1]]))
rownames(plus_sum) <- c("deep", "rf", "gbm")
print("general_36");
print(dim(h2oData)[1]);
print(perf_sum);
print("general_36_plus");
print(dim(plusData)[1]);
print(plus_sum);



##################
##################
##################################################
##################사후검증########################
##################################################

# check the correlation between the winner's probablity and top N vairbale importance
tmp_varimp = head(data.frame(h2o.varimp(gbm)))
tmp_varimp
tmp_pred = h2o.predict(gbm, plusData)
tmp_pred

# correlation 
h2o.cor(tmp_pred$W, tmp_pred$A_47)
h2o.cor(tmp_pred$W, tmp_pred$W_28)
h2o.cor(tmp_pred$W, tmp_pred$W_29)
h2o.cor(tmp_pred$W, tmp_pred$W_20)
h2o.cor(tmp_pred$W, tmp_pred$W_38)

# train$W_4,train$A_47
tmp_train = as.data.frame(train)
setNames(aggregate(tmp_train$A_47, by = list(tmp_train$W_4), FUN = mean), c("Y", "X"))

# t-test











##########################################
#confusion Matrix
#h2o.table(plusData$W_4, pluspred$predict)
#matrix <- c(plusData$W_4, pluspred$predict)
#matrix$LL <- matrix[[1]] == "L" & matrix[[2]] == "L"
#matrix$LW <- matrix[[1]] == "L" & matrix[[2]] != "L"
#matrix$WL <- matrix[[1]] != "L" & matrix[[2]] == "L"
#matrix$WW <- matrix[[1]] != "L" & matrix[[2]] != "L"
#cross <- c(sum(matrix$LL), sum(matrix$LW), sum(matrix$WL), sum(matrix$WW))

#h2o.table(plusData_ex$W_4, pluspred_ex$predict)
#matrix_ex <- c(plusData_ex$W_4, pluspred_ex$predict)
#matrix_ex$LL <- matrix_ex[[1]] == "L" & matrix_ex[[2]] == "L"
#matrix_ex$LW <- matrix_ex[[1]] == "L" & matrix_ex[[2]] != "L"
#matrix_ex$WL <- matrix_ex[[1]] != "L" & matrix_ex[[2]] == "L"
#matrix_ex$WW <- matrix_ex[[1]] != "L" & matrix_ex[[2]] != "L"
#cross_ex <- c(sum(matrix_ex$LL), sum(matrix_ex$LW), sum(matrix_ex$WL), sum(matrix_ex$WW))


#정확도=true/tot
#plusgbm_Accuracy <- (cross[1] + cross[4]) / dim(pluspred$predict)[1]
#plusgbm_Accuracy_ex <- (cross_ex[1] + cross_ex[4]) / dim(pluspred_ex$predict)[1]
#plusgbm_Accuracy;
#plusgbm_Accuracy_ex

#hit raio=TruePositive=true pos/tot pos
#plusgbm_hit <- cross[4] / (cross[3] + cross[4])
#plusgbm_hit_ex <- cross_ex[4] / (cross_ex[3] + cross_ex[4])
#plusgbm_hit;
#plusgbm_hit_ex;

#AUC
#plusgbm_AUC <- h2o.auc(h2o.performance(gbm, newdata = plusData))
#plusgbm_AUC_ex <- h2o.auc(h2o.performance(gbm_ex, newdata = plusData_ex))
#plusgbm_AUC;
#plusgbm_AUC_ex


#################
#("deep");head(m@model$variable_importances,10);
#("rf");head(rf@model$variable_importances,10);
#("gbm");head(gbm@model$variable_importances,10);



#supplyNum <- read.csv('supply_num.csv', header = TRUE)
#h2oData <- left_join(h2oData,supplyNum,by = "BLOCK_NM")

#h2oData <- h2oData[, c(7,11,24:27,38:42,44)]
