## Load Data
require(data.table)
require(caret)
require(randomForest)
set.seed(1214)
train <- fread("train.csv")
store <- fread("store.csv")
test <- fread("test.csv")

## Combine data for utilization
train <- merge(train, store, by = "Store")
test <- merge(test,store,by="Store")
rm(store)


## Scrub data for when the store is closed (not open = no sales)
# train <- train[Open==1,]
# test <- test[Open==1,]


## Cleaning dates
train[,Date:=as.Date(Date)]
test[,Date:=as.Date(Date)]


test[,DayOfWeek:=as.factor(test$DayOfWeek)]
test[,Promo:=as.factor(test$Promo)]
test$StateHoliday <- as.factor(test$StateHoliday)
test$SchoolHoliday <- as.factor(test$SchoolHoliday)
test$StoreType <- as.factor(test$StoreType)
test$Assortment <- as.factor(test$Assortment)
train$DayOfWeek <- as.factor(train$DayOfWeek)
train$Promo <- as.factor(train$Promo)
train$StateHoliday <- as.factor(train$StateHoliday)
train$SchoolHoliday <- as.factor(train$SchoolHoliday)
train$StoreType <- as.factor(train$StoreType)
train$Assortment <- as.factor(train$Assortment)
train[,Open:=as.factor(train$Open)]
test[,Open:=as.factor(test$Open)]

## Idea: Create new parameter: promo2_run_time delineating the 
## length of time the particular promo2 has been running. Then
## multiply promo2 times the new parameter (thus it'll be zero
## or the amount of time the promo has been running). The rest
## of the info doesn't need to be used in the fit.

train$Promo2For <-
  as.Date(paste(train$Promo2SinceYear,
                train$Promo2SinceWeek
                ,sep="-"),
          format = "%Y-%W")
train$PromoRun <- difftime(
  train$Date, train$Promo2For, units = "weeks")

test$Promo2For <-
  as.Date(paste(test$Promo2SinceYear,
                test$Promo2SinceWeek
                ,sep="-"),
          format = "%Y-%W")
test$PromoRun <- difftime(
  test$Date, test$Promo2For, units = "weeks")

## Can also combine the competition dates to one parameter,
## competition_time, denoting the time the competition has been
## around.

train$CompetitionOpenFor <- 
  as.Date(paste(train$CompetitionOpenSinceYear,
                train$CompetitionOpenSinceMonth,
                rep("1",dim(train)[1]),sep="-"), 
                format = "%Y-%m-%d")
train$CompetitionRun <- difftime(train$Date, train$CompetitionOpenFor, units = "weeks")

test$CompetitionOpenFor <- 
  as.Date(paste(test$CompetitionOpenSinceYear,
                test$CompetitionOpenSinceMonth,
                rep("1",dim(test)[1]),sep="-"), 
          format = "%Y-%m-%d")
test$CompetitionRun <- difftime(test$Date, test$CompetitionOpenFor, units = "weeks")
## Dropping unneeded variables. Specifically all of the OpenFor
## and OpenSince variables as well as the PromoInterval

train <- train[,c("CompetitionOpenSinceMonth",
                     "CompetitionOpenSinceYear",
                     "Promo2SinceWeek",
                     "Promo2SinceYear",
                     "PromoInterval",
                     "Promo2For",
                     "CompetitionOpenFor"):=NULL]
test <- test[,c("CompetitionOpenSinceMonth",
                     "CompetitionOpenSinceYear",
                     "Promo2SinceWeek",
                     "Promo2SinceYear",
                     "PromoInterval",
                     "Promo2For",
                     "CompetitionOpenFor"):=NULL]

train$PromoRun[is.na(train$PromoRun)] <- 0
train$CompetitionRun[is.na(train$CompetitionRun)] <- 0
## Setup training and testing sets for none cross-validated models
# inTrain <- createDataPartition(train$Sales,p=0.6,list=FALSE)
# testing <- train[-inTrain[,1]]
# training <- train[inTrain[,1]]

test$PromoRun <- as.numeric(test$PromoRun)
train$PromoRun <- as.numeric(train$PromoRun)
test$CompetitionRun <- as.numeric(test$CompetitionRun)
train$CompetitionRun <- as.numeric(train$CompetitionRun)