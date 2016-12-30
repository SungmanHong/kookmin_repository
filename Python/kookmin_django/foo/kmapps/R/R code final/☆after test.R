rm(list = ls())

library(h2o)
library(stringr)
library(dplyr)
library(ggplot2)

gc(reset = T)
seed_num = 2016

localH2O <- h2o.init() ## using a max 1GB of RAM
h2o.removeAll()

model <- h2o.loadModel("C:/Users/mijin/Desktop/output/disabled_46_rf")
data <- read.csv("C:/Users/mijin/Desktop/output/disabled_46.csv")


varImp <- head(data.frame(h2o.varimp(model)), 15)
varImp <- varImp[, c(1, 4)]

i <- 0
accP <- 0
for (i in 1:15) {
    accP <- accP + varImp[i, 2]
    if (accP >= 0.8) break;
    }
varImp <- varImp[1:i,]
varImp <- varImp[with(varImp, order(percentage)),]

windows()
bar <- barplot(varImp$percentage, 1,
    xlim = c(0, round(varImp$percentage[i] * 10) / 10),
    horiz = TRUE,
    names.arg = varImp$variable,
    cex.names = 0.6,
    las = 1,
    density = 30,
    main = "Most important Variables in general 46")
text(y = bar, x = varImp$percentage - 0.01, labels = paste0(round(varImp$percentage * 100, 1), "%"), srt = 45, cex = 0.7, xpd = TRUE)
text(y = 0.5, x = varImp[i, 2] - 0.04, labels = paste0("누적% = ", round(accP * 100, 2)))
#■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
#■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
#■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
#■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■

dev.off()

# 컬럼제거(1: SEQ_NUM, 2:SEQ_ 4:REGNUM_BLOCK, 8:W_8) ,3:BLOCK_NM
data <- data[, - c(1:4, 8)]
## H2O DataFrame으로 변경
data <- as.h2o(data)

## data 분리(train/valid/test)
splits <- h2o.splitFrame(data, c(0.6, 0.2), seed = seed_num)
train <- h2o.assign(splits[[1]], "train.hex") # 60%
valid <- h2o.assign(splits[[2]], "valid.hex") # 60%
test <- h2o.assign(splits[[3]], "test.hex") # 60%

pred <- h2o.predict(model, test)


h2o.cor(pred$W, test$W_38) #혼인기간
h2o.cor(pred$W, test$num.House) #남양주시 가구수
h2o.cor(pred$W, test$W_29) #세대주 나이
h2o.cor(pred$W, test$subway.km) #지하철로부터의 거리
h2o.cor(pred$W, test$wa3_liveterm) #거주기간 점수
h2o.cor(pred$W, test$hospital_near_km) #병원까지의 거리(km)
h2o.cor(pred$W, test$W_20) #우선분양 점수
h2o.cor(pred$W, test$W_28) #불입횟수



h2o.cor(pred$W, test$W_15) #장애등급
h2o.cor(pred$W, test$W_29) #세대주 나이
h2o.cor(pred$W, test$W_21) #일반분양 점수
h2o.cor(pred$W, test$supply.count) #해당 형 공급호수
h2o.cor(pred$W, test$W_20) #우선분양 점수
h2o.cor(pred$W, test$supply.ratio) #해당 형 공급비율
h2o.cor(pred$W, test$W_25) #부양가족수
h2o.cor(pred$W, test$wa1_age) #신청자 나이
h2o.cor(pred$W, test$W_28) #불입횟수
h2o.cor(pred$W, test$news_6month) #최근 6개월간 뉴스 노출 빈도(관심도)
h2o.cor(pred$W, test$Price.percent) #주변 시세 대비 공급가격비





h2o.cor(pred$W, test$W_20) #우선분양 점수
h2o.cor(pred$W, test$hospital_near_km) #병원까지의 거리(km)


h2o.cor(pred$W, test$W_21) #일반분양 점수
h2o.cor(pred$W, test$W_16) #소득 70%적용 유무
h2o.cor(pred$W, test$W_13) #당첨자 신청순위
h2o.cor(pred$W, test$news_6month) #최근 6개월간 뉴스 노출 빈도(관심도)
h2o.cor(pred$W, test$subway.km) #지하철로부터의 거리
h2o.cor(pred$W, test$supply.count) #해당 형 공급호수
h2o.cor(pred$W, test$facility_near) #편의시설 근접성
h2o.cor(pred$W, test$num.House) #남양주시 가구수
h2o.cor(pred$W, test$W_29) #세대주 나이


h2o.cor(pred$W, test$Price.percent) #주변 시세 대비 공급가격비








h2o.cor(pred$W, test$supply_tot) #블록별 총 공급호수

h2o.cor(pred$W, test$hospital_near_min) #병원까지의 거리(분)



#■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
tmp.test <- as.data.frame(test)

corr <- c((-1) * h2o.cor(pred$W, test$news_6month), (-1) * h2o.cor(pred$W, test$W_29),
        (-1) * h2o.cor(pred$W, test$W_20), (-1) * h2o.cor(pred$W, test$hospital_near_km),
        (-1) * h2o.cor(pred$W, test$Price.percent))
corr <- rbind(corr,c(h2o.cor(pred$W, test$news_6month), h2o.cor(pred$W, test$W_29),
         h2o.cor(pred$W, test$W_20), h2o.cor(pred$W, test$hospital_near_km), h2o.cor(pred$W, test$Price.percent)))

#dat <- matrix(runif(40, 1, 20), ncol = 4) # make data
windows()
matplot(dat, type = c("b"), pch = 1, col = 1:4)

windows()
matplot(corr, xlim = c(-2,2), type = c("l"), col = 1:5) #plot
legend("topleft", legend = 1:4, col = 1:5, pch = 1) # optional legend


windows()
ggplot(data = corr, aes(x = -1:1, y = corr:V2))
geom_line()

ggplot(data = corr, aes(x = Semana, y = Net_Sales_in_pesos, group = Agencia_ID, colour = as.factor(Agencia_ID)))

windows()
plot(x = c(-1,1), y = c((abs(corr[1])*(-1)),abs(corr[1])), type="l", col="blue")


corr

plot(as.numeric(test$news_6month),pred$W)


#■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
#■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
#■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
#■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
#■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
#■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
#■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■


tmp_test <- as.data.frame(test)
var.test(tmp_test$W_21 ~ tmp_test$W_4) # p-value = 0.4869
t.test(tmp_test$W_21 ~ tmp_test$W_4, val.equal = TRUE) # p-value = 1.146e-15

var.test(tmp_test$news_6month ~ tmp_test$W_4) # p-value = 0.4262
t.test(tmp_test$news_6month ~ tmp_test$W_4, val.equal = TRUE) #p-value = 0.8137

var.test(tmp_test$subway.km ~ tmp_test$W_4) # p-value = 0.1657
t.test(tmp_test$subway.km ~ tmp_test$W_4, val.equal = TRUE) #p-value =  0.3103

var.test(tmp_test$supply.count ~ tmp_test$W_4) # p-value = 0.003062
t.test(tmp_test$supply.count ~ tmp_test$W_4) #p-value =  2.574e-05

var.test(tmp_test$facility_near ~ tmp_test$W_4) # p-value < 2.2e-16
t.test(tmp_test$facility_near ~ tmp_test$W_4) #p-value =  6.504e-08

var.test(tmp_test$num.House ~ tmp_test$W_4) # p-value = 0.009335
t.test(tmp_test$num.House ~ tmp_test$W_4) #p-value = 0.9578

var.test(tmp_test$W_29 ~ tmp_test$W_4) # p-value = 0.5963
t.test(tmp_test$W_29 ~ tmp_test$W_4, val.equal = TRUE) #p-value = 0.004268

var.test(tmp_test$Price.percent ~ tmp_test$W_4) # p-value = 0.2699
t.test(tmp_test$Price.percent ~ tmp_test$W_4, val.equal = TRUE) #p-value = 0.3591

