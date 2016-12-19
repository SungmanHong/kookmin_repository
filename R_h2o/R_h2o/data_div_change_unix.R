# install.packages("stringr")
# install.packages("dplyr")
library(stringr)
library(dplyr)
full_data <- read.csv('full_data1011v2.csv', encoding = 'EUC-KR')
head(full_data)

## 우선/일반 나누기 
full_data.priorty <- subset(full_data, W_14 %in% c('우고', '일고', 'N고', '우장', '일장', 'N장', '우신', '일신', 'N신') )
full_data.general <- full_data %>% filter(!str_detect(W_14, "우"))

## REGNUM_BLOCK 필드
full_data.general$REGNUM_BLOCK <- gsub('호평', 'HO', full_data.general$REGNUM_BLOCK)
full_data.priorty$REGNUM_BLOCK <- gsub('호평', 'HO', full_data.priorty$REGNUM_BLOCK)
## BLOCK_NM 필드
full_data.general$BLOCK_NM <- gsub('호평', 'HO', full_data.general$BLOCK_NM)
full_data.priorty$BLOCK_NM <- gsub('호평', 'HO', full_data.priorty$BLOCK_NM)

## W_3 필드
full_data.general$W_3 <- gsub('26형', '26F', full_data.general$W_3)
full_data.general$W_3 <- gsub('36형', '36F', full_data.general$W_3)
full_data.general$W_3 <- gsub('46형', '46F', full_data.general$W_3)
full_data.priorty$W_3 <- gsub('26형', '26F', full_data.priorty$W_3)
full_data.priorty$W_3 <- gsub('36형', '36F', full_data.priorty$W_3)
full_data.priorty$W_3 <- gsub('46형', '46F', full_data.priorty$W_3)

## W_4 필드
full_data.general$W_4 <- gsub('당첨', 'W', full_data.general$W_4)
full_data.general$W_4 <- gsub('예비', 'L', full_data.general$W_4)
full_data.general$W_4 <- gsub('낙첨', 'L', full_data.general$W_4)
full_data.priorty$W_4 <- gsub('당첨', 'W', full_data.priorty$W_4)
full_data.priorty$W_4 <- gsub('예비', 'L', full_data.priorty$W_4)
full_data.priorty$W_4 <- gsub('낙첨', 'L', full_data.priorty$W_4)

## W_13 필드
full_data.general$W_13 <- gsub('1순위', '1st', full_data.general$W_13)
full_data.general$W_13 <- gsub('2순위', '2nd', full_data.general$W_13)
full_data.general$W_13 <- gsub('3순위', '3rd', full_data.general$W_13)
full_data.priorty$W_13 <- gsub('1순위', '1st', full_data.priorty$W_13)
full_data.priorty$W_13 <- gsub('2순위', '2nd', full_data.priorty$W_13)
full_data.priorty$W_13 <- gsub('3순위', '3rd', full_data.priorty$W_13)

## W_14 필드
unique(full_data.general$W_14)
unique(full_data.priorty$W_14)

full_data.general$W_14 <- gsub('N장', 'ND', full_data.general$W_14)
full_data.general$W_14 <- gsub('일장', 'GD', full_data.general$W_14)
full_data.general$W_14 <- gsub('일일', 'GG', full_data.general$W_14)
full_data.general$W_14 <- gsub('일고', 'GH', full_data.general$W_14)
full_data.general$W_14 <- gsub('N일', 'NG', full_data.general$W_14)
full_data.general$W_14 <- gsub('N고', 'NH', full_data.general$W_14)
full_data.general$W_14 <- gsub('일중', 'GC', full_data.general$W_14)
full_data.general$W_14 <- gsub('일노', 'GN', full_data.general$W_14)
full_data.general$W_14 <- gsub('N한', 'NHAN', full_data.general$W_14)
full_data.general$W_14 <- gsub('일한', 'GHAN', full_data.general$W_14)
full_data.general$W_14 <- gsub('N노', 'NN', full_data.general$W_14)
full_data.general$W_14 <- gsub('N신', 'NM', full_data.general$W_14)
full_data.general$W_14 <- gsub('N북', 'NBOOK', full_data.general$W_14)
full_data.general$W_14 <- gsub('일북', 'GBOOK', full_data.general$W_14)
full_data.general$W_14 <- gsub('N근', 'NGEUN', full_data.general$W_14)
full_data.general$W_14 <- gsub('일신', 'GM', full_data.general$W_14)
full_data.general$W_14 <- gsub('일근', 'GGEUN', full_data.general$W_14)
full_data.general$W_14 <- gsub('N중', 'NC', full_data.general$W_14)

full_data.priorty$W_14 <- gsub('우고', 'PH', full_data.priorty$W_14)
full_data.priorty$W_14 <- gsub('일고', 'GH', full_data.priorty$W_14)
full_data.priorty$W_14 <- gsub('N고', 'NH', full_data.priorty$W_14)
full_data.priorty$W_14 <- gsub('우장', 'PD', full_data.priorty$W_14)
full_data.priorty$W_14 <- gsub('일장', 'GD', full_data.priorty$W_14)
full_data.priorty$W_14 <- gsub('N장', 'ND', full_data.priorty$W_14)
full_data.priorty$W_14 <- gsub('우신', 'PM', full_data.priorty$W_14)
full_data.priorty$W_14 <- gsub('일신', 'GM', full_data.priorty$W_14)
full_data.priorty$W_14 <- gsub('N신', 'NM', full_data.priorty$W_14)

## W_15
full_data.general$W_15 <- gsub('장애없음', 'N', full_data.general$W_15)
full_data.general$W_15 <- gsub('6급', '6R', full_data.general$W_15)
full_data.general$W_15 <- gsub('5급', '5R', full_data.general$W_15)
full_data.general$W_15 <- gsub('4급', '4R', full_data.general$W_15)
full_data.general$W_15 <- gsub('3급', '3R', full_data.general$W_15)
full_data.general$W_15 <- gsub('2급', '2R', full_data.general$W_15)
full_data.general$W_15 <- gsub('1급', '1R', full_data.general$W_15)
full_data.priorty$W_15 <- gsub('장애없음', 'N', full_data.priorty$W_15)
full_data.priorty$W_15 <- gsub('6급', '6R', full_data.priorty$W_15)
full_data.priorty$W_15 <- gsub('5급', '5R', full_data.priorty$W_15)
full_data.priorty$W_15 <- gsub('4급', '4R', full_data.priorty$W_15)
full_data.priorty$W_15 <- gsub('3급', '3R', full_data.priorty$W_15)
full_data.priorty$W_15 <- gsub('2급', '2R', full_data.priorty$W_15)
full_data.priorty$W_15 <- gsub('1급', '1R', full_data.priorty$W_15)

## W_16

## W_18
full_data.general$W_18 <- gsub('당해', 'RESI', full_data.general$W_18)
full_data.general$W_18 <- gsub('타', 'N_RESI', full_data.general$W_18)
full_data.priorty$W_18 <- gsub('당해', 'RESI', full_data.priorty$W_18)
full_data.priorty$W_18 <- gsub('타', 'N_RESI', full_data.priorty$W_18)

## W_27
full_data.general$W_27 <- gsub("00년", "0", full_data.general$W_27)
full_data.general$W_27 <- gsub("01년", "1", full_data.general$W_27)
full_data.general$W_27 <- gsub("02년", "2", full_data.general$W_27)
full_data.general$W_27 <- gsub("03년", "3", full_data.general$W_27)
full_data.general$W_27 <- gsub("04년", "4", full_data.general$W_27)
full_data.general$W_27 <- gsub("05년", "5", full_data.general$W_27)
full_data.general$W_27 <- gsub("06년", "6", full_data.general$W_27)
full_data.general$W_27 <- gsub("07년", "7", full_data.general$W_27)
full_data.general$W_27 <- gsub("08년", "8", full_data.general$W_27)
full_data.general$W_27 <- gsub("09년", "9", full_data.general$W_27)
full_data.general$W_27 <- gsub("10년", "10", full_data.general$W_27)
full_data.general$W_27 <- gsub("11년", "11", full_data.general$W_27)
full_data.general$W_27 <- gsub("12년", "12", full_data.general$W_27)
full_data.general$W_27 <- gsub("13년", "13", full_data.general$W_27)
full_data.general$W_27 <- gsub("14년", "14", full_data.general$W_27)
full_data.general$W_27 <- gsub("15년", "15", full_data.general$W_27)
full_data.general$W_27 <- gsub("16년", "16", full_data.general$W_27)
full_data.general$W_27 <- gsub("17년", "17", full_data.general$W_27)
full_data.general$W_27 <- gsub("18년", "18", full_data.general$W_27)
full_data.general$W_27 <- gsub("19년", "19", full_data.general$W_27)
full_data.general$W_27 <- gsub("20년", "20", full_data.general$W_27)
full_data.general$W_27 <- gsub("21년", "21", full_data.general$W_27)
full_data.general$W_27 <- gsub("22년", "22", full_data.general$W_27)
full_data.general$W_27 <- gsub("23년", "23", full_data.general$W_27)
full_data.general$W_27 <- gsub("24년", "24", full_data.general$W_27)
full_data.general$W_27 <- gsub("25년", "25", full_data.general$W_27)
full_data.general$W_27 <- gsub("26년", "26", full_data.general$W_27)
full_data.general$W_27 <- gsub("27년", "27", full_data.general$W_27)
full_data.general$W_27 <- gsub("28년", "28", full_data.general$W_27)
full_data.general$W_27 <- gsub("29년", "29", full_data.general$W_27)
full_data.general$W_27 <- gsub("30년", "30", full_data.general$W_27)
full_data.general$W_27 <- gsub("31년", "31", full_data.general$W_27)
full_data.general$W_27 <- gsub("32년", "32", full_data.general$W_27)
full_data.general$W_27 <- gsub("33년", "33", full_data.general$W_27)
full_data.general$W_27 <- gsub("34년", "34", full_data.general$W_27)
full_data.general$W_27 <- gsub("35년", "35", full_data.general$W_27)
full_data.general$W_27 <- gsub("36년", "36", full_data.general$W_27)
full_data.general$W_27 <- gsub("37년", "37", full_data.general$W_27)
full_data.general$W_27 <- gsub("38년", "38", full_data.general$W_27)
full_data.general$W_27 <- gsub("39년", "39", full_data.general$W_27)
full_data.general$W_27 <- gsub("40년", "40", full_data.general$W_27)
full_data.general$W_27 <- gsub("41년", "41", full_data.general$W_27)
full_data.general$W_27 <- gsub("48년", "48", full_data.general$W_27)
full_data.general$W_27 <- gsub("63년", "63", full_data.general$W_27)

full_data.priorty$W_27 <- gsub("00년", "0", full_data.priorty$W_27)
full_data.priorty$W_27 <- gsub("01년", "1", full_data.priorty$W_27)
full_data.priorty$W_27 <- gsub("02년", "2", full_data.priorty$W_27)
full_data.priorty$W_27 <- gsub("03년", "3", full_data.priorty$W_27)
full_data.priorty$W_27 <- gsub("04년", "4", full_data.priorty$W_27)
full_data.priorty$W_27 <- gsub("05년", "5", full_data.priorty$W_27)
full_data.priorty$W_27 <- gsub("06년", "6", full_data.priorty$W_27)
full_data.priorty$W_27 <- gsub("07년", "7", full_data.priorty$W_27)
full_data.priorty$W_27 <- gsub("08년", "8", full_data.priorty$W_27)
full_data.priorty$W_27 <- gsub("09년", "9", full_data.priorty$W_27)
full_data.priorty$W_27 <- gsub("10년", "10", full_data.priorty$W_27)
full_data.priorty$W_27 <- gsub("11년", "11", full_data.priorty$W_27)
full_data.priorty$W_27 <- gsub("12년", "12", full_data.priorty$W_27)
full_data.priorty$W_27 <- gsub("13년", "13", full_data.priorty$W_27)
full_data.priorty$W_27 <- gsub("14년", "14", full_data.priorty$W_27)
full_data.priorty$W_27 <- gsub("15년", "15", full_data.priorty$W_27)
full_data.priorty$W_27 <- gsub("16년", "16", full_data.priorty$W_27)
full_data.priorty$W_27 <- gsub("17년", "17", full_data.priorty$W_27)
full_data.priorty$W_27 <- gsub("18년", "18", full_data.priorty$W_27)
full_data.priorty$W_27 <- gsub("19년", "19", full_data.priorty$W_27)
full_data.priorty$W_27 <- gsub("20년", "20", full_data.priorty$W_27)
full_data.priorty$W_27 <- gsub("21년", "21", full_data.priorty$W_27)
full_data.priorty$W_27 <- gsub("22년", "22", full_data.priorty$W_27)
full_data.priorty$W_27 <- gsub("23년", "23", full_data.priorty$W_27)
full_data.priorty$W_27 <- gsub("24년", "24", full_data.priorty$W_27)
full_data.priorty$W_27 <- gsub("25년", "25", full_data.priorty$W_27)
full_data.priorty$W_27 <- gsub("26년", "26", full_data.priorty$W_27)
full_data.priorty$W_27 <- gsub("27년", "27", full_data.priorty$W_27)
full_data.priorty$W_27 <- gsub("28년", "28", full_data.priorty$W_27)
full_data.priorty$W_27 <- gsub("29년", "29", full_data.priorty$W_27)
full_data.priorty$W_27 <- gsub("30년", "30", full_data.priorty$W_27)
full_data.priorty$W_27 <- gsub("31년", "31", full_data.priorty$W_27)
full_data.priorty$W_27 <- gsub("32년", "32", full_data.priorty$W_27)
full_data.priorty$W_27 <- gsub("33년", "33", full_data.priorty$W_27)
full_data.priorty$W_27 <- gsub("34년", "34", full_data.priorty$W_27)
full_data.priorty$W_27 <- gsub("35년", "35", full_data.priorty$W_27)
full_data.priorty$W_27 <- gsub("36년", "36", full_data.priorty$W_27)
full_data.priorty$W_27 <- gsub("37년", "37", full_data.priorty$W_27)
full_data.priorty$W_27 <- gsub("38년", "38", full_data.priorty$W_27)
full_data.priorty$W_27 <- gsub("39년", "39", full_data.priorty$W_27)
full_data.priorty$W_27 <- gsub("40년", "40", full_data.priorty$W_27)
full_data.priorty$W_27 <- gsub("41년", "41", full_data.priorty$W_27)
full_data.priorty$W_27 <- gsub("48년", "48", full_data.priorty$W_27)
full_data.priorty$W_27 <- gsub("63년", "63", full_data.priorty$W_27)

## W_38
full_data.general$W_38 <- gsub("해당없음", "N", full_data.general$W_38)
full_data.general$W_38 <- gsub("0년", "0", full_data.general$W_38)
full_data.general$W_38 <- gsub("1년", "1", full_data.general$W_38)
full_data.general$W_38 <- gsub("2년", "2", full_data.general$W_38)
full_data.general$W_38 <- gsub("3년", "3", full_data.general$W_38)
full_data.general$W_38 <- gsub("4년", "4", full_data.general$W_38)
full_data.general$W_38 <- gsub("5년", "5", full_data.general$W_38)
full_data.priorty$W_38 <- gsub("해당없음", "N", full_data.priorty$W_38)
full_data.priorty$W_38 <- gsub("0년", "0", full_data.priorty$W_38)
full_data.priorty$W_38 <- gsub("1년", "1", full_data.priorty$W_38)
full_data.priorty$W_38 <- gsub("2년", "2", full_data.priorty$W_38)
full_data.priorty$W_38 <- gsub("3년", "3", full_data.priorty$W_38)
full_data.priorty$W_38 <- gsub("4년", "4", full_data.priorty$W_38)
full_data.priorty$W_38 <- gsub("5년", "5", full_data.priorty$W_38)

## W_39 
full_data.general$W_39 <- gsub('해당없음', 'N', full_data.general$W_39)
full_data.general$W_39 <- gsub('1순위', '1st', full_data.general$W_39)
full_data.general$W_39 <- gsub('2순위', '2nd', full_data.general$W_39)
full_data.priorty$W_39 <- gsub('해당없음', 'N', full_data.priorty$W_39)
full_data.priorty$W_39 <- gsub('1순위', '1st', full_data.priorty$W_39)
full_data.priorty$W_39 <- gsub('2순위', '2nd', full_data.priorty$W_39)


## W_40
full_data.general$W_40 <- gsub('해당없음', 'N', full_data.general$W_40)
full_data.general$W_40 <- gsub('당해', 'RESI', full_data.general$W_40)
full_data.general$W_40 <- gsub('타', 'N_RESI', full_data.general$W_40)
full_data.priorty$W_40 <- gsub('해당없음', 'N', full_data.priorty$W_40)
full_data.priorty$W_40 <- gsub('당해', 'RESI', full_data.priorty$W_40)
full_data.priorty$W_40 <- gsub('타', 'N_RESI', full_data.priorty$W_40)

summary(full_data.priorty)
summary(full_data.general)

highage_26 <- subset(full_data.priorty, W_3 == '26F' & (W_14 == 'PH' | W_14 == 'GH' | W_14 == 'NH'))
highage_36 <- subset(full_data.priorty, W_3 == '36F' & (W_14 == 'PH' | W_14 == 'GH' | W_14 == 'NH'))
highage_46 <- subset(full_data.priorty, W_3 == '46F' & (W_14 == 'PH' | W_14 == 'GH' | W_14 == 'NH'))

## W_1, W_6, W_14 제거
highage_26 <- highage_26[, !names(highage_26) %in% c("W_1", "W_6", "W_14")]
highage_36 <- highage_36[, !names(highage_36) %in% c("W_1", "W_6", "W_14")]
highage_46 <- highage_46[, !names(highage_46) %in% c("W_1", "W_6", "W_14")]

write.table(highage_26, 'highage_26.csv')
write.table(highage_36, 'highage_36.csv')
write.table(highage_46, 'highage_46.csv')

## 장애인
disabled_26 <- subset(full_data.priorty, W_3 == '26F' & (W_14 == 'PD' | W_14 == 'GD' | W_14 == 'ND'))
disabled_36 <- subset(full_data.priorty, W_3 == '36F' & (W_14 == 'PD' | W_14 == 'GD' | W_14 == 'ND'))
disabled_46 <- subset(full_data.priorty, W_3 == '46F' & (W_14 == 'PD' | W_14 == 'GD' | W_14 == 'ND'))

## W_1, W_6, W_14 제거
disabled_26 <- disabled_26[, !names(disabled_26) %in% c("W_1", "W_6", "W_14")]
disabled_36 <- disabled_36[, !names(disabled_36) %in% c("W_1", "W_6", "W_14")]
disabled_46 <- disabled_46[, !names(disabled_46) %in% c("W_1", "W_6", "W_14")]

write.table(disabled_26, 'disabled_26.csv')
write.table(disabled_36, 'disabled_36.csv')
write.table(disabled_46, 'disabled_46.csv')

## 신혼부부
married_46 <- subset(full_data.priorty, W_3 == '46F' & (W_14 == 'PM' | W_14 == 'GM' | W_14 == 'NM'))

## W_1, W_6, W_14 제거
married_46 <- married_46[, !names(married_46) %in% c("W_1", "W_6", "W_14")]
write.table(married_46, 'married_46.csv')

## 일반공급
general_26 <- full_data.general %>% filter(W_3 == "26F" & W_14 %in% c('ND', 'GD', 'GG', 'GH', 'NG', 'NH', 'GC', 'GN', 'NHAN', 'GHAN', 'NN', 'NM', 'NBOOK', 'GBOOK', 'NGEUN', 'GM', 'GGEUN', 'NC'))
general_36 <- full_data.general %>% filter(W_3 == "36F" & W_14 %in% c('ND', 'GD', 'GG', 'GH', 'NG', 'NH', 'GC', 'GN', 'NHAN', 'GHAN', 'NN', 'NM', 'NBOOK', 'GBOOK', 'NGEUN', 'GM', 'GGEUN', 'NC'))
general_46 <- full_data.general %>% filter(W_3 == "46F" & W_14 %in% c('ND', 'GD', 'GG', 'GH', 'NG', 'NH', 'GC', 'GN', 'NHAN', 'GHAN', 'NN', 'NM', 'NBOOK', 'GBOOK', 'NGEUN', 'GM', 'GGEUN', 'NC'))

## W_1, W_6, W_14 제거
general_26 <- general_26[, !names(general_26) %in% c("W_1", "W_6", "W_14")]
general_36 <- general_36[, !names(general_36) %in% c("W_1", "W_6", "W_14")]
general_46 <- general_46[, !names(general_46) %in% c("W_1", "W_6", "W_14")]

write.table(general_26, 'general_26.csv')
write.table(general_36, 'general_36.csv')
write.table(general_46, 'general_46.csv')