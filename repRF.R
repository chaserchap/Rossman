## An attempt at keeping some value of a randomforest while
## maintaining a relatively quick fit.
require(data.table)
require(randomForest)

repRF <- function(formula,data,draws,percent,reproducible=TRUE,...){
  models <- vector(mode="list",length=draws)
  for (i in seq(10)){
    if (TRUE){
      set.seed(i)
    }
    inTrainer <- createDataPartition(data[1,],p=percent,times=draws)
    trainer <- train[inTrainer[[i]],]
    model <- randomForest(Sales~.,data=trainer)
    
  }
}

for (i in seq(10)){
  trainer <- train[inTrainer[[i]],]
  models[[i]]<-randomForest(Sales~.,data=trainer)}

rfpred <- function(models,newdata,...){
  for(i in models){
    prediction <- 
  }
}