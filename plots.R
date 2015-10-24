source("Features.R")
require(ggplot2)

plot <- ggplot(train,aes(Sales,Customers))
plotAssortmanet <- plot + geom_point(aes(color=Assortment))
plotDayofWeek <- plot + geom_point(aes(color=DayOfWeek))
plotPromo <- plot + geom_point(aes(color=Promo))
plotPromo2 <- plot + geom_point(aes(color=Promo2))
plotStoreType <- plot + geom_point(aes(color=StoreType))