args <- commandArgs(trailingOnly = TRUE)

rm(list = ls())
library(h2o)
library(dplyr)
library(rjson)

localH2O <- h2o.init() ## using a max 1GB of RAM
h2o.removeAll()

setwd('C:/apps/foo/kmapps/R')
model_lst <- read.table('C:/apps/foo/model_lst.txt' , sep=",")
model_len <- length(model_lst)

x_data <- list()
series_data <- data.frame(name=character(), data=numeric(0))

tmp <- read.csv('C:/apps/foo/test.csv', header = TRUE)

tmp$W_38 <- as.factor(x=tmp$W_38)
# levels(tmp$W_38) = c("1","2","3","4","5")
tmp = as.h2o(tmp)

idx <- 1
for (model in model_lst) {
	rf <- h2o.loadModel(paste0("C:/apps/foo/kmapps/R/",model,""))
	## result data.frame
	res_df <- as.data.frame(h2o.predict(rf,tmp))
	## save list
	x_data[idx] <- paste0(model,"", sep='')
	# series_data[[idx]]['name'] <- paste0(model,"")
	# series_data[[idx]]['data'] <- res_df$W
	print(model)
	series_data <- rbind(series_data, data.frame(name=paste(model,"", sep=''), data=round(res_df$W, digits=4)*100))
	series_data <- series_data[order(series_data$data, decreasing = TRUE), ]
	idx <- idx+1
}

write(toJSON(x_data), "x_data.json")
write(toJSON(series_data), "series_data.json")

cat(paste("+","success",sep=""))