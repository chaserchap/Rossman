## Prepare data
source("Features.R")
require(dplyr)

## Load and initialize H2O
require(h2o)
localh2o <- h2o.init(nthreads=-1,max_mem_size="28g")

## Load data into cluster
trainHex <- as.h2o(train)

## Specify factors of interest (ie NOT those listed)
features<-colnames(train)[!(colnames(train) %in%
                              c("Id","Date","Sales","logSales","Customers","logCustomers"))]

rfHexSales <- h2o.randomForest(x=features,
                          y="logSales",
                          ntrees = 100,
                          max_depth = 30,
                          nbins_cats = 1115, ## allow it to fit store ID
                          training_frame=trainHex)

gbmHexSales <- h2o.gbm(x=features,
                      y="logSales",
                      distribution="AUTO",
                      ntrees = 100,
                      max_depth = 30,
                      nbins_cats = 1115, ## allow it to fit store ID
                      training_frame=trainHex)

rfHexCustomers <- h2o.randomForest(x=features,
                               y="logCustomers",
                               ntrees = 100,
                               max_depth = 30,
                               nbins_cats = 1115, ## allow it to fit store ID
                               training_frame=trainHex)

gbmHexCustomers <- h2o.gbm(x=features,
                       y="logCustomers",
                       distribution="AUTO",
                       ntrees = 100,
                       max_depth = 30,
                       nbins_cats = 1115, ## allow it to fit store ID
                       training_frame=trainHex)

rfPredSales <- as.data.frame(h2o.predict(rfHexSales,trainHex))
rfPredCustomers <- as.data.frame(h2o.predict(rfHexCustomers,trainHex))
gbmPredSales <- as.data.frame(h2o.predict(gbmHexSales,trainHex))
gbmPredCustomers <- as.data.frame(h2o.predict(gbmHexCustomers,trainHex))

predDF <- data.frame(rfSales = rfPredSales,
                     rfCustomers = rfPredCustomers,
                     gbmSales = gbmPredSales,
                     gbmCustomers = gbmPredCustomers,
                     Sales = train$logSales)

newFeatures <- colnames(predDF)[!(colnames(predDF) %in% c("Sales"))]
predHex <- as.h2o(predDF)

finalFit <- h2o.randomForest(x = newFeatures,
                             y = "Sales",
                             ntrees = 100,
                             max_depth = 30,
                             nbins_cats = 1115, ## allow it to fit store ID
                             training_frame=predHex)

testHex <- as.h2o(test)

rfTestSales <- as.data.frame(predict(rfHexSales,testHex))
rfTestCustomers <- as.data.frame(predict(rfHexCustomers,testHex))
gbmTestSales <- as.data.frame(predict(gbmHexSales,testHex))
gbmTestCustomers <- as.data.frame(predict(gbmHexCustomers,testHex))

testDF <- data.frame(rfSales = rfTestSales,
                     rfCustomers = rfTestCustomers,
                     gbmSales = gbmTestSales,
                     gbmCustomers = gbmTestCustomers)

finalTestHex <- as.h2o(testDF)

finalPred <- as.data.frame(predict(finalFit,finalTestHex))
finalPred <- expm1(finalPred[,1])
submission <- data.frame(Id=test$Id, Sales=finalPred)

testWithZeros <- fread("test.csv")
submit <- data.frame(Id = testWithZeros$Id)
finalSubmit <- full_join(submit, submission, by = "Id")
finalSubmit$Sales[is.na(finalSubmit$Sales)] <- 0
write.csv(finalSubmit,"rfGbmStack.csv",row.names=F)
