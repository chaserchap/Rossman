prepSubmit <- function(fit,filename){
  results <- predict(fit,newdata=test)
  results <- data.frame(test$Id,results)
  colnames(results) <- c("Id","Sales")
  write.csv(results,filename,row.names = FALSE)
}