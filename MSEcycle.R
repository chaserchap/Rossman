source("Features.R")
require(h2o)
mseHold <- read.csv("results.csv")
localh2o <- h2o.init(nthreads=-1,max_mem_size="6g")
trainHex <- as.h2o(train)
features <- colnames(train)[!colnames(train) %in% c("Id","Date","Sales","logSales","Customers")]
i=24
n=200
m = 8
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
  removeLastValues(localh2o)
}

removeLastValues <- function(conn) {
  df <- h2o.ls(conn)
  keys_to_remove <- grep("^Last\\.value\\.", perl=TRUE, x=df$Key, value=TRUE)
  unique_keys_to_remove = unique(keys_to_remove)
  if (length(unique_keys_to_remove) > 0) {
    h2o.rm(conn, unique_keys_to_remove)
  }
}