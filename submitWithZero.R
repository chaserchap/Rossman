## Add in Zeros

require(dplyr)
require(data.table)
testWithZeros <- fread("test.csv")
fullId <- data.frame(Id = testWithZeros$Id)
rm(testWithZeros)

submitWithZero <- function(DF,filename){
  submission <- full_join(as.data.frame(DF),as.data.frame(fullId),by="Id")
  colnames(submission) <- c("Id","Sales")
  submission$Sales[is.na(submission$Sales)] <- 0
  write.csv(submission,filename,row.names = FALSE)
}
