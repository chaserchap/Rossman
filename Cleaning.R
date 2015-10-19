###############
#
# Cleaning the Data
#
###############

## Note that the test set doesn't have customers
colnames(train)
colnames(test)

## test also has no "b" or "c" holidays
unique(test$StateHoliday)
unique(train$StateHoliday)

## test also has 11 NA values for Open, train has 0
test[is.na(test$Open),]
dim(train[is.na(train$Open),])

## These NAs are all at one store, 622, store 622 is normally open 
## every day of the week except Sunday (7). Based on this, imputing
## all of the NAs in Open to 1.
store622<- subset(test,test$Store==622)
plot(store622$Open,store622$DayOfWeek)
rm(store622)

test$Open[is.na(test$Open)] <- 1

## There are 2642 NAs in the CompetitionDistance variable, presumably
## there is no competition. I imputed 250000 meters, roughly 150 miles
## to show any competition was distant. Did the same to test set
length(train$CompetitionDistance[is.na(train$CompetitionDistance)])
train$CompetitionDistance[is.na(train$CompetitionDistance)] <- 250000
test$CompetitionDistance[is.na(test$CompetitionDistance)] <- 250000

## Based on the following there's clearly a break between distances
## it was pointed out that this may be an indicator that a store is 
## in a highly populated area such as downtown in a large city
## As such I changed the CompetitionDistance variable to 0 if 
## CompetitionDistance is > than the mean of 6065, and 1 if < 6065
ggplot(train[Sales != 0], aes(x = CompetitionDistance, y = Customers)) + 
  geom_point() + geom_smooth(size = 2)
# train[,train$CompetitionDistance>6065] = 0
# train[,train$CompetitionDistance<=6065] = 1


## Looking at PromoRun and CompetitionRun
ggplot(train[Sales != 0], aes(x = PromoRun, y = Customers)) + 
  geom_point() + geom_smooth(size = 2)
ggplot(train[Sales != 0], aes(x = PromoRun, y = Sales)) + 
  geom_point() + geom_smooth(size = 2)
## PromoRun has little effect on customers or sales

ggplot(train[Sales != 0], aes(x = CompetitionRun, y = Customers)) + 
  geom_point() + geom_smooth(size = 2)
ggplot(train[Sales != 0], aes(x = CompetitionRun, y = Sales)) + 
  geom_point() + geom_smooth(size = 2)
## CompetitionRun also seems to have little effect

train[,c("Date","Customers"):=NULL]
