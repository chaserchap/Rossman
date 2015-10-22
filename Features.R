## Load Data
require(data.table)

train <- fread("train.csv")
store <- fread("store.csv")
test <- fread("test.csv")

## Combine data for utilization
train <- merge(train, store, by = "Store")
test <- merge(test,store,by="Store")
rm(store)

## Scrub data for when the store is closed (not open = no sales)
train <- train[Open==1,]
test <- test[Open==1,]

## Format Dates
train[,Date:=as.Date(Date)]
test[,Date:=as.Date(Date)]

## Compute logSales
train[,logSales:=log1p(Sales)]

## NAs in test$Open imputed as 1s
test$Open[is.na(test$Open)] <- 1

## Define variable types and create Week factor
train[,Store:=as.factor(as.numeric(Store))]
train[,Assortment:=as.factor(train$Assortment)]
train[,DayOfWeek:=as.factor(train$DayOfWeek)]
train[,Promo:=as.factor(train$Promo)]
train[,StateHoliday:=as.factor(train$StateHoliday)]
train[,SchoolHoliday:=as.factor(train$SchoolHoliday)]
train[,StoreType:=as.factor(train$StoreType)]
train[,Promo2:=as.factor(train$StoreType)]
train[,PromoInterval:=as.factor(train$PromoInterval)]
train[,Week:=as.factor(format(Date, "%U"))]

test[,Store:=as.factor(as.numeric(Store))]
test[,Assortment:=as.factor(test$Assortment)]
test[,DayOfWeek:=as.factor(test$DayOfWeek)]
test[,Promo:=as.factor(test$Promo)]
test[,StateHoliday:=as.factor(test$StateHoliday)]
test[,SchoolHoliday:=as.factor(test$SchoolHoliday)]
test[,StoreType:=as.factor(test$StoreType)]
test[,Promo2:=as.factor(test$StoreType)]
test[,PromoInterval:=as.factor(test$PromoInterval)]
test[,Week:=as.factor(format(Date, "%U"))]


