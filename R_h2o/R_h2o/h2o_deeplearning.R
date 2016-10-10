# rm(list = ls())
library(h2o)

localH2O <- h2o.init(max_mem_size = '1g') ## using a max 1GB of RAM
h2o.removeAll() ## clean slate - just in case the cluster was already running

## data 불러오기
highage_26 <- read.table('highage_26.csv', header = TRUE)

as.h2o(highage_26)

highage_26 <- as.h2o(highage_26)
highage_26

## data 분리
splits <- h2o.splitFrame(highage_26, c(0.6, 0.2), seed = 1234)
train <- h2o.assign(splits[[1]], "train.hex") # 60%
valid <- h2o.assign(splits[[1]], "valid.hex") # 60%
test <- h2o.assign(splits[[1]], "test.hex") # 60%

response = 'W_4' # 당첨/탈락 여부 필드
predictors <- setdiff(names(highage_26), response)
predictors

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
summary(m1)
head(as.data.frame(h2o.varimp(m1)))
