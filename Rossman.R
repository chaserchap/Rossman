## Load Data
library(data.table)
train <- fread("train.csv")
store <- fread("store.csv")

## Combine data for utilization
train <- merge(train, store, by = "Store")

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
                train$Promo2SinceWeek,
                rep("1",dim(train)[1]),sep="="),
          format = "%Y-%U-%u")

## Can also combine the competition dates to one parameter,
## competition_time, denoting the time the competition has been
## around.

train$CompetitionOpenFor <- 
  as.Date(paste(train$CompetitionOpenSinceYear,
                train$CompetitionOpenSinceMonth,
                rep("1",dim(train)[1]),sep="-"), 
                format = "%Y-%m-%d")