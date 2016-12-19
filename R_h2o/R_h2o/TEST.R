myArgs <- commandArgs(trailingOnly = TRUE)

## setting excute env
rm(list = ls())
library(h2o)
library(stringr)
library(dplyr)
library(rjson)

localH2O <- h2o.init() ## using a max 1GB of RAM
h2o.removeAll()

setwd('C:/apps/foo/kmapps/R')
rf <- h2o.loadModel("general_46_rf")

tmp <- read.csv('C:/apps/foo/test.csv', header = TRUE)
#head(tmp)
tmp = tmp[, - c(1:4, 8)]

tmp <- tmp[, c(1:32)]  ## 에러나는 부분(요부분 주석처리 시 아래 thred_plus에서 에러남)

tmp$W_38 <- as.factor(x=tmp$W_38)
levels(tmp$W_38) = c("1","2","3","4","5")
tmp = as.h2o(tmp)
#dim(tmp)

thred_plus = h2o.find_threshold_by_max_metric(h2o.performance(rf, newdata = tmp), "f1") ## 에러나는 부분
#rf_hit_plus = h2o.tpr(h2o.performance(rf, newdata = tmp), thresholds = thred_plus)
#rf_AUC_plus = h2o.auc(h2o.performance(rf, newdata = tmp))
#new = h2o.confusionMatrix(h2o.performance(rf, newdata = tmp), thresholds = thred_plus)
rf_cm_plus = h2o.confusionMatrix(h2o.performance(rf, newdata = tmp), thresholds = thred_plus)
rf_Accuracy_plus = h2o.accuracy(h2o.performance(rf, newdata = tmp), thresholds = thred_plus)
rf_recall_plus = h2o.recall(h2o.performance(rf, newdata = tmp), thresholds = thred_plus)
rf_precision_plus = h2o.precision(h2o.performance(rf, newdata = tmp), thresholds = thred_plus)
rf_AUC_plus = h2o.auc(h2o.performance(rf, newdata = tmp))


#print("general_46_plus\n")
#rf_cm_plus
#print(paste("plus_ACCURACY   : ", rf_Accuracy_plus, sep = ""))
#print(paste("plus_AUC        : ", rf_AUC_plus, sep = ""))
#print(paste("plus_recall     : ", rf_recall_plus, sep = ""))
#print(paste("plus_precision  : ", rf_precision_plus, sep = ""))
#print(rf_AUC_plus)
#print(rf_recall_plus)
#print(rf_precision_plus)

pred <- h2o.predict(rf,tmp)
a = list(col_name=c("AUC","RECALL","PRECISION","PREDICT_VALUE"),value=c(rf_AUC_plus,rf_recall_plus,rf_precision_plus, pred$predict))
cat(paste("+",toJSON(a)))
