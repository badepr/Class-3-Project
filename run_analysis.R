library(dplyr)
library(stringr)
##
## I initially used linux "wc -l filename" to get a handle on the number of lines in the files
##
## Now read training data file in as a data frame, specifing that the separator is one or more 
## white spaces and there is no header
trainingDataFile<-"./UCI\ HAR\ Dataset/train/X_train.txt"
trainingData<-read.table(trainingDataFile, sep="", header=FALSE)
## Read file of corresponding subject ID into a data frame
trainingSubjectFile<-"./UCI\ HAR\ Dataset/train/subject_train.txt"
trainingSubject<-read.table(trainingSubjectFile,header=FALSE)
## Read file of corresponding testActivities into a data frame
trainingActivityFile<-"./UCI\ HAR\ Dataset/train/y_train.txt"
trainingActivity<-read.table(trainingActivityFile,header=FALSE)
##
## Read test data file in as a data frame, specifing that the separator is one or more 
## white spaces and there is no header
testDataFile<-"./UCI\ HAR\ Dataset/test/X_test.txt"
testData<-read.table(testDataFile, sep="", header=FALSE)
## Read file of corresponding subject ID into a data frame
testSubjectFile<-"./UCI\ HAR\ Dataset/test/subject_test.txt"
testSubject<-read.table(testSubjectFile,header=FALSE)
## Read file of corresponding testActivities into a data frame
testActivityFile<-"./UCI\ HAR\ Dataset/test/y_test.txt"
testActivity<-read.table(testActivityFile,header=FALSE)
##
## Merge the training and test Data
subject <- rbind(trainingSubject, testSubject)
activity <- rbind(trainingActivity, testActivity)
data <- rbind(trainingData, testData)
##
## read the labels for the features
## note that we don't want the labels to be factors
featureLabelsFile<-"./UCI\ HAR\ Dataset/features.txt"
featureLabels<-read.table(featureLabelsFile, sep="", header=FALSE, stringsAsFactors=FALSE)
##
## now rename the columns of the features
names(data)[] = featureLabels[[2]]

##
## read the labels for the activities
## note that we don't want the labels to be factors
## We will end up with a file with 2 columns:
## The first Column V1 contains the vector of numbers that correspond to Activities
## The second Column V2 are the labels corrsponding to those Activities
activityLabelsFile<-"./UCI\ HAR\ Dataset/activity_labels.txt"
activityLabels<-read.table(activityLabelsFile, sep="", header=FALSE, stringsAsFactors=FALSE)
## 
## Now let's take the vector of numbers for training/test activities and use it
## to generate a corresponding vector of named activities
## For each activity number, we do this by subsetting the combined vector  
## and assigning the corresponding activity label to the new vector $V3
namedActivities=data.frame(Activity=character(length(activity[[1]])), stringsAsFactors=FALSE)
for (index in seq_len(length(activityLabels$V1))) {
    namedActivities$Activity[activity$V1 == index]<-activityLabels$V2[index]
}

##
## Now we use those two columns to generate a third Column of
## activity names which corresponds to the combined vector of training/test activities
## For each activity number, we do this by subsetting the combined vector  
## and assigning the corresponding activity label to the new vector $V3
##for (index in seq_len(length(activityLabels$V1))) {
##    activity$V3[activity$V1 == index]<-activityLabels$V2[index]
##}
##
## For the activity DF, Rename column V3 to Activity
##names(activity)[names(activity)=="V3"] <-"Activity"

## For the subject DF, rename the column V1 to Subject
names(subject)[names(subject)=="V1"] <-"Subject"
## Now let's combine activity, subject, and data DFs
all<-cbind(namedActivities, cbind(subject, data, stringsAsFactors=FALSE))
## Now let's Filter the columns that we want to keep
##
## This will show you the names with mean in it:
##      names(all)[grep("mean", names(all), ignore.case=TRUE)]
##
## This will show you the names with std in it:
##      names(all)[grep("std", names(all), ignore.case=TRUE)]
##
## So, we want the columns with subject, activity, any mean, any std
columnNumsWithMean=grep("mean", names(all), ignore.case=TRUE)
columnNumsWithStd=grep("std", names(all), ignore.case=TRUE)
subjectColumnNum=match("Subject", names(all))
activityColumnNum=match("Activity", names(all))
meanStdData<-all[,c(activityColumnNum, subjectColumnNum, columnNumsWithMean,columnNumsWithStd)]
##
## Now let's get rid of the "-"'s and "()"'s in the names
##
## get rid of the special characters "(,),-"
names(meanStdData)[] = stringr::str_replace_all(names(meanStdData)[], "[(,),-]", "_")

#
# Now create data set with average of each variable for each activity and each subject 
#

## Create a data frame grouped by Activity and Subject
finalResult = summarize(group_by(meanStdData,Activity,Subject))
## Now iterate through the names of the columns (excluding the subject and activity columns)
for (myIndex in seq(from = 3, to = length(names(meanStdData)))) {
    ## extract the name of the column we are working on
    columnName<-names(meanStdData)[myIndex]
    ## get the symbol for that column
    column = as.symbol(columnName)
    ## determine the means of that column for each (Activity and Subject)
    result = summarize(group_by(meanStdData,Activity,Subject), mean(column))
    ## fix the name for the mean(column)
    names(result)[3] = stringr::str_replace_all(names(result)[3], "column", columnName)
    if(myIndex == 3){
        ## initialize final result if this is the first time through the loop
        finalResult = result
    } else {
        ## Combine this column to the finalresult
        finalResult<-cbind(finalResult, result[3])
    }
}
## Write out the tidy data set
write.table(finalResult, file="myTidyDataSet.txt", row.name=FALSE)

