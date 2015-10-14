## Random Forest called through Caret's train took 2000 seconds 
## on 8000 observations. Originally did 1:8000 observations
## This showed a Randomly Selected Predictors value of 8 should
## be good.
pmt <- proc.time()
modFit <- train(Sales~DayOfWeek+Promo+StateHoliday+
                  SchoolHoliday+StoreType+Assortment+
                  CompetitionDistance+PromoRun+CompetitionRun,
                method="rf",data=train,allowParallel=TRUE)
pmt <- proc.time()-pmt

## GLM HUGE MSE ~7802906...

glmtime <- proc.time()
glmFit <- train(Sales~DayOfWeek+Promo+StateHoliday+
                  SchoolHoliday+StoreType+Assortment+
                  CompetitionDistance+PromoRun+CompetitionRun,
                method="glm",data=training)
glmtime <- proc.time() - glmtime