## Load Data
library(data.table)
train <- fread("train.csv")
store <- fread("store.csv")
test <- fread("test.csv")

## Combine data for utilization
train <- merge(train, store, by = "Store")
test <- merge(test,store,by="Store")
rm(store)

## Scrub data for when the store is closed (not open = no sales)
train <- train[Open==1,]

## Cleaning dates
train[,Date:=as.Date(Date)]
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
## Can also combine the competition dates to one parameter,
## competition_time, denoting the time the competition has been
## around.

train$CompetitionOpenFor <- 
  as.Date(paste(train$CompetitionOpenSinceYear,
                train$CompetitionOpenSinceMonth,
                rep("1",dim(train)[1]),sep="-"), 
                format = "%Y-%m-%d")
train$CompetitionRun <- difftime(
  train$Date, train$CompetitionOpenFor, units = "weeks")

## Dropping unneeded variables. Specifically all of the OpenFor
## and OpenSince variables as well as the PromoInterval

training <- train[,c("CompetitionOpenSinceMonth",
                     "CompetitionOpenSinceYear",
                     "Promo2SinceWeek",
                     "Promo2SinceYear",
                     "PromoInterval",
                     "Promo2For",
                     "CompetitionOpenFor"):=NULL]