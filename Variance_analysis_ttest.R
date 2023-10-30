library(readxl)
library(openxlsx)
library(stringr)
library(Matrix)
library(glmnet)
setwd("")
rm(list = ls()) 

train<-read_excel("", sheet=1,col_names = TRUE)


#方差分析
variances<-apply(train[14:3682], 2, var)
variances_df<-as.data.frame(variances)
write.xlsx(variances_df,'', rowNames = TRUE)
name_var<-variances[which(variances>0.1)]
name_var_df<-as.data.frame(name_var)
write.xlsx(name_var_df,'', rowNames = TRUE)

# 将选中的数据保存为新的 Excel 表格
selected_columns <- which(names(train) %in% names(name_var))

selected_train <- train[c("name","grade", names(train)[selected_columns])]
#selected_test <- test[c("name","grade", names(test)[selected_columns])]


write.xlsx(selected_train, '', rowNames = FALSE)


#t检验
#rm(list = ls()) 
dat1<-read_excel("", sheet=1,col_names = TRUE)
dat2<-data.frame(t1=as.character(1:3))
Star<-3
Over<-1987

for ( i in c(Star:Over)){                       
  means<-tapply(dat1[[i]],dat1$grade,mean)
  means<-sprintf('%.4f',round(means,3))  
  SD<-tapply(dat1[[i]],dat1$grade,sd)
  SD<-sprintf('%.4f',round(SD,3))       
  M.t<-wilcox.test(dat1[[i]]~grade,data=dat1) 
  pvalue<-M.t[[3]]
  if(pvalue>0.1){
    a<-paste(means,'±',SD)
    a[3]<-"NS"     
  }
  else if(pvalue>0.05){
    a<-paste(means,'±',SD)
    a[3]<-pvalue
  }
  else if(pvalue>0.01){
    a<-paste(means,'±',SD)
    a[3]<-pvalue
  }
  else {
    a<-paste(means,'±',SD)
    a[3]<-pvalue
  }
  dat2[i-(Star-1)]<-a
  names(dat2)[i-(Star-1)]<-names(dat1[,i])
}


dat3<-t(dat2)  
final_dat<-as.data.frame(dat3)
write.xlsx(final_dat,'', rowNames = TRUE)

# 根据 final_dat 行名的条件进行筛选
filtered_rows <- rownames(final_dat)[final_dat$V3 != "NS"] 
selected_columns <- c("name","grade",filtered_rows)
dat4<-read_excel("", sheet=1,col_names = TRUE)
dat5<-read_excel("", sheet=1,col_names = TRUE)
# 创建新的数据框
selected_dat_train <- dat1[selected_columns]
selected_dat_val <- dat4[selected_columns]
selected_dat_test <- dat5[selected_columns]
# 将选中的数据保存为新的 Excel 表格
write.xlsx(selected_dat_train, '', rowNames = FALSE)
write.xlsx(selected_dat_val, '', rowNames = FALSE)
write.xlsx(selected_dat_test, '', rowNames = FALSE)

