install.packages("dplyr")
library(dplyr)


# get train data
xtrain<-read.table('./UCI HAR Dataset/train/X_train.txt', header=FALSE)
ytrain<-read.table('./UCI HAR Dataset/train/y_train.txt', header=FALSE)
# get test data
xtest<-read.table('./UCI HAR Dataset/test/X_test.txt', header=FALSE)
ytest<-read.table('./UCI HAR Dataset/test/y_test.txt', header=FALSE)
# get features data
features<-read.table('./UCI HAR Dataset/features.txt', header=FALSE)
# get activity data
activity<-read.table('./UCI HAR Dataset/activity_labels.txt', header=FALSE)
# get subject data
subtrain<-read.table('./UCI HAR Dataset/train/subject_train.txt', header=FALSE)
subtrain<-subtrain%>%
  rename(subjectID=V1)
subtest<-read.table('./UCI HAR Dataset/test/subject_test.txt', header=FALSE)
subtest<-subtest%>%
  rename(subjectID=V1)

# add column names to both train and test data
features<-features[,2]
featrasp<-t(features)
colnames(xtrain)<-featrasp
colnames(xtest)<-featrasp
# rename activity columns to id and actions(walk,lay,etc.)
colnames(activity)<-c('id','actions')

# row bind xtrain and xtest 
combineX<-rbind(xtrain, xtest)
# row bind ytrain and ytest
combineY<-rbind(ytrain, ytest)
# row bind subject train and subject test
combineSubj<-rbind(subtrain,subtest)

# column bind Y and X (the two data frames created above). We then have everything except for activity 
YXdf<-cbind(combineY,combineX, combineSubj)

# merge the above data frame with the activity
df<-merge(YXdf, activity,by.x = 'V1',by.y = 'id')




# getting the mean and standard deviation
colNames<-colnames(df)
df2<-df%>%
  select(actions, subjectID, grep("\\bmean\\b|\\bstd\\b",colNames))

# transform activity to a factor variable 
df2$actions<-as.factor(df2$actions)

# use descriptive activity names to name the activities in the data set
colnames(df2)<-gsub("^t", "time", colnames(df2))
colnames(df2)<-gsub("^f", "frequency", colnames(df2))
colnames(df2)<-gsub("Acc", "Accelerometer", colnames(df2))
colnames(df2)<-gsub("Gyro", "Gyroscope", colnames(df2))
colnames(df2)<-gsub("Mag", "Magnitude", colnames(df2))
colnames(df2)<-gsub("BodyBody", "Body", colnames(df2))

# creates a second data set with the average of each variable for activity and subject.
df2.2<-aggregate(. ~subjectID + actions, df2, mean)

# text file for final output
write.table(df2.2, file = "tidydata.txt",row.name=FALSE)
