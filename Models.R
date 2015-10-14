

myControl <- trainControl(method = "repeatedcv", repeats=5, number = 10)

## Random Forest called through Caret's train took 2000 seconds 
## on 8000 observations. Originally did 1:8000 observations
## This showed a Randomly Selected Predictors value of 8 should
## be good. 

## May be hitting memory limits? Won't work on rf or rpart in caret
## Doesn't work calling randomForest() either.

pmt <- proc.time()
modFit <- train(Sales~DayOfWeek+Promo+StateHoliday+
                  SchoolHoliday+StoreType+Assortment+
                  CompetitionDistance+PromoRun+CompetitionRun,
                method="rf",data=train[1:8000,],allowParallel=TRUE)
pmt <- proc.time()-pmt

## GLM HUGE MSE ~7802906...

glmtime <- proc.time()
glmFit <- train(Sales~DayOfWeek+Promo+StateHoliday+
                  SchoolHoliday+StoreType+Assortment+
                  CompetitionDistance+PromoRun+CompetitionRun+Open,
                method="glm",data=train,allowParallel=TRUE,
                trControl=myControl)
glmtime <- proc.time() - glmtime

myControl <- trainControl(method="repeatedcv",number="10",repeats="5")
qdatime <- proc.time()
qdaFit <- train(Sales~DayOfWeek+Promo+StateHoliday+
                  SchoolHoliday+StoreType+Assortment+
                  CompetitionDistance+PromoRun+CompetitionRun+Open,
                method="qda",data=train,allowParallel=TRUE,trControl=myControl)
qdatime <- proc.time()-qdatime