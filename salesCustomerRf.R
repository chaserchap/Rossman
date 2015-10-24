## Prepare data
source("Features.R")
require(dplyr)

## Load and initialize H2O
require(h2o)
localh2o <- h2o.init(nthreads=-1,max_mem_size="6g")

## Load data into cluster
trainHex <- as.h2o(train)
testHex <- as.h2o(test)

## Specify factors of interest (ie NOT those listed)
features <- colnames(train)[!(colnames(train) %in%
                                      c("Id","Date","Sales","logSales",
                                        "CompetitionDistance",
                                        "Customers", "logCustomers"))]

## Build customer prediction model

rfCustomerHex <- h2o.randomForest(x=features,
                                  y="logCustomers",
                                  ntrees = 200,
                                  max_depth = 30,
                                  nbins_cats = 1115, ## allow it to fit store ID
                                  training_frame=trainHex)

## Obtain predicted logCustomers for train and test sets
train$predictedCustomers <- exp(as.data.frame(predict(rfCustomerHex,trainHex))[,1])
test$predictedCustomers <- exp(as.data.frame(predict(rfCustomerHex,testHex))[,1])

## Reload new dataframe
trainHex <- as.h2o(train)
testHex <- as.h2o(test)

## Add predictedLogCustomers as variable
features <- colnames(train)[!(colnames(train) %in%
                                      c("Id","Date","Sales","logSales",
                                        "Customers", "logCustomers"))]
## Build sales prediction model
rfSalesHex <- h2o.randomForest(x=features,
                               y="logSales",
                               ntrees = 200,
                               max_depth = 30,
                               nbins_cats = 1115, ## allow it to fit store ID
                               training_frame=trainHex)

## Collect predicted sales
predictedSales <- as.data.frame(predict(rfSalesHex,testHex))


## Build submission
colnames(predictedSales) <- "Sales"
predictedSales$Id <- test$Id
submission <- full_join(predictedSales,fullId,by="Id")
submission$Sales <- expm1(submission$Sales)
submission$Sales[is.na(submission$Sales)] <- 0
write.csv(submission,"./Results/SalesCustRF.csv",row.names = FALSE)

## Original attempt had created second model with logCustomers and
## both models with logCompetitionDistance and logSales
## also had integers Month and Year, all other variables remained.
## Removed days the stores were closed. Score ~.20045
##
## Second attempt had regular Customers on second model, and regular
## CompetitionDistance in both, otherwise same as original.
## Messed this one up, Month was labeled Week in the test set.
## Score .14117 MSE 0.01675013
##
## Third attempt fixed second attempt