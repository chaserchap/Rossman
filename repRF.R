## An attempt at keeping some value of a randomforest while
## maintaining a relatively quick fit.
require(data.table)
require(randomForest)


for (i in seq(10)){
  set.seed(i)
  inTrainer <- createDataPartition(train$Sales,p=0.01,list=FALSE)
  trainer <- train[inTrainer[,1],]
  model <- randomForest(Sales~.,data=trainer)
  predhold <- predict(model,newdata=test)
  pred <- pred + as.numeric(predhold)
}

