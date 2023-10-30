library(readxl)
library(openxlsx)
library(stringr)
library(glmnet)


setwd("")
rm(list = ls())

data1 <- read_excel("", sheet=4,col_names = TRUE)
train_tumor<- data1[,c(2:528)]  #tumor
train_vat6<- data1[,c(2,752:1005)] #PRAT
train_all<- data1[,c(2:1005)] #all


data2 <- read_excel("", sheet=1,col_names = TRUE)
val_tumor<- data2[,c(2:528)]  #tumor
val_vat6<- data1[,c(2,752:1005)] #PRAT
val_all<- data1[,c(2:1005)] #all

data3 <- read_excel("", sheet=1,col_names = TRUE)
test_tumor<- data3[,c(2:528)]  #tumor
test_vat6<- data1[,c(2,752:1005)] #PRAT
test_all<- data1[,c(2:1005)] #all

######————————————基于肿瘤ROI特征模型
x<-as.matrix(train_tumor[,2:527])
y<-train_tumor$grade
sum(is.na(x))
set.seed(1)
cv_lasso=cv.glmnet(x,y,family="binomial",nfolds=10, alpha=1)
plot(cv_lasso)
plot(cv_lasso$glmnet.fit, xvar="lambda", label=FALSE)

coef_min<-coef(cv_lasso$glmnet.fit,s=cv_lasso$lambda.min,exact = F)
# 输出筛选得到的特征
selected_feature_indices <- which(coef_min != 0)
selected_feature_names <- colnames(x)[selected_feature_indices]
selected_feature_coefs <- coef_min[selected_feature_indices]
print(selected_feature_names)
selected_feature<-as.data.frame(selected_feature_names)
write.xlsx(selected_feature,"")

# Function to filter selected features from a dataset
filter_selected_features <- function(data, selected_feature_names) {
  selected_columns <- c("name","grade", selected_feature_names)
  filtered_data <- data[selected_columns]
  return(filtered_data)
}

# Filter and save selected features for each dataset
filtered_tumor_train <- filter_selected_features(data1, selected_feature_names)
filtered_tumor_val <- filter_selected_features(data2, selected_feature_names)
filtered_tumor_test <- filter_selected_features(data3, selected_feature_names)
write.xlsx(filtered_tumor_train, "")
write.xlsx(filtered_tumor_val, "")
write.xlsx(filtered_tumor_test, "")

######————————————基于PRAT特征模型
x<-as.matrix(train_vat6[,2:255])
y<-train_vat6$grade
sum(is.na(x))
set.seed(1)
cv_lasso=cv.glmnet(x,y,family="binomial",nfolds=10, alpha=1)
plot(cv_lasso)
plot(cv_lasso$glmnet.fit, xvar="lambda", label=FALSE)

coef_min<-coef(cv_lasso$glmnet.fit,s=cv_lasso$lambda.min,exact = F)
# 输出筛选得到的特征
selected_feature_indices <- which(coef_min != 0)
selected_feature_names <- colnames(x)[selected_feature_indices]
selected_feature_coefs <- coef_min[selected_feature_indices]
print(selected_feature_names)
selected_feature<-as.data.frame(selected_feature_names)
write.xlsx(selected_feature,"")

# Function to filter selected features from a dataset
filter_selected_features <- function(data, selected_feature_names) {
  selected_columns <- c("name","grade", selected_feature_names)
  filtered_data <- data[selected_columns]
  return(filtered_data)
 }

selected_feature_names <- selected_feature_names[!is.na(selected_feature_names)]

# Filter and save selected features for each dataset
filtered_vat6_train <- filter_selected_features(data1, selected_feature_names)
filtered_vat6_val <- filter_selected_features(data2, selected_feature_names)
filtered_vat6_test <- filter_selected_features(data3, selected_feature_names)
write.xlsx(filtered_vat6_train, "")
write.xlsx(filtered_vat6_val, "")
write.xlsx(filtered_vat6_test, "")

######————————————基于all特征模型
x<-as.matrix(train_all[,2:1004])
y<-train_all$grade
sum(is.na(x))
set.seed(1)
cv_lasso=cv.glmnet(x,y,family="binomial",nfolds=10, alpha=1)
plot(cv_lasso)
plot(cv_lasso$glmnet.fit, xvar="lambda", label=FALSE)

coef_min<-coef(cv_lasso$glmnet.fit,s=cv_lasso$lambda.min,exact = F)
# 输出筛选得到的特征
selected_feature_indices <- which(coef_min != 0)
selected_feature_names <- colnames(x)[selected_feature_indices]
selected_feature_coefs <- coef_min[selected_feature_indices]
print(selected_feature_names)
selected_feature<-as.data.frame(selected_feature_names)
write.xlsx(selected_feature,"")

# Function to filter selected features from a dataset
filter_selected_features <- function(data, selected_feature_names) {
  selected_columns <- c("name","grade", selected_feature_names)
  filtered_data <- data[selected_columns]
  return(filtered_data)
}

# Filter and save selected features for each dataset
filtered_all_train <- filter_selected_features(data1, selected_feature_names)
filtered_all_val <- filter_selected_features(data2, selected_feature_names)
filtered_all_test <- filter_selected_features(data3, selected_feature_names)
write.xlsx(filtered_all_train, "")
write.xlsx(filtered_all_val, "")
write.xlsx(filtered_all_test, "")
