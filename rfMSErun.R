## Prepare data
source("Features.R")

## Load and initialize H2O
require(h2o)
localh2o <- h2o.init(nthreads=-1,max_mem_size="28g")

## Load data into cluster
trainHex <- as.h2o(train)

## Specify factors of interest (ie NOT those listed)
salesFeatures<-colnames(train)[!(colnames(train) %in%
                          c("Id","Date","Sales","logSales","Customers"))]
customerFeatures<-colnames(train)[!(colnames(train) %in%
                          c("Id","Date","Sales","logSales","Customers", "logCustomers"))]

## Create RandomForest
i = 0
mseHold <- as.data.table(matrix(0,nrow=80,ncol=4))
setnames(mseHold,c("V1","V2","V3","V4"),c("ntrees","mtries","max_depth","MSE"))
for (n in seq(100,500, by=100)){
  for (m in seq(4,10,by=2)) {
    for (depth in seq(15,60,by=15)) {
      rfHex <- h2o.randomForest(x=features,
                                y="logSales",
                                ntrees = n,
                                max_depth = depth,
                                mtries = m,
                                nbins_cats = 1115, ## allow it to fit store ID
                                training_frame=trainHex)
      i = i+1
      mseHold$ntrees[i] = n
      mseHold$mtries[i] = m
      mseHold$max_depth[i] = depth
      mseHold$MSE[i] = h2o.mse(rfHex)
    }
  }
}

write.csv(mseHold,"mseResults.csv",row.names=F)

minMSE <- which.min(mseHold$MSE)

rfHex <- h2o.randomForest(x=features,
                          y="logSales",
                          ntrees = mseHold$ntrees[minMSE],
                          max_depth = mseHold$max_depth[minMSE],
                          mtries = mseHold$mtries[minMSE],
                          nbins_cats = 1115, ## allow it to fit store ID
                          training_frame=trainHex)

testHex <- as.h2o(test)
predictions <- as.data.frame(h2o.predict(rfHex,testHex))
pred <- expm1(predictions[,1])
submission <- data.frame(Id=test$Id, Sales=pred)
write.csv(submission,"h2o_opt_rf.csv",row.names=F)