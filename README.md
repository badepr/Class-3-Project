## Class-3-Project
The purpose of this project is to demonstrate my ability to collect, work with, and clean a data set. 

## Assumptions:
* training data file is located in "./UCI\ HAR\ Dataset/train/X_train.txt"
* training subject file is located in "./UCI\ HAR\ Dataset/train/subject_train.txt"
* training activity file is located in "./UCI\ HAR\ Dataset/train/y_train.txt"
* test data file is located in "./UCI\ HAR\ Dataset/test/X_test.txt"
* test subject file is located in "./UCI\ HAR\ Dataset/test/subject_test.txt"
* test activity file is located in "./UCI\ HAR\ Dataset/test/y_test.txt"
* feature lable file is located in "./UCI\ HAR\ Dataset/features.txt"

## Program flow

### Reading and combining test and training (data, subject, and activity files)
* training data,subject,activity files were read in as separate data frames using read.table, specifing that the separator is one or more white spaces and there is no header
* test data,subject,activity files were read in as separate data frames using read.table, specifing that the separator is one or more white spaces and there is no header
* the training and test data frames were combined using "rbind", such that there was now a single df for each of the following: subject, activity, data

### Read the labels for the features and re-nameing the columns in the data
* label file was read in as a data frame using read.table, specifing that the separator is one or more white spaces, there is no header, and we do not want strings to be interpreted as factors
* columns of features in data frame were renamed

### Read the labels for the activities and create a new data frame of names of activities corresponding to the activity data frame read in earlier
* label file for activities was read in as a data frame using read.table, specifing that the separator is one or more white spaces, there is no header, and we do not want strings to be interpreted as factors
* The result was a data frame with 2 columns:
** first Column V1 contains the vector of numbers that correspond to Activities
** second Column V2 are the labels corrsponding to those Activities
* Next we take the vector of numbers for training/test activities and use it to generate a corresponding vector of named activities. For each activity number, we do this by subsetting the combined vector and assigning the corresponding activity label 

### For the subject DF, we rename the column V1 to Subject

### Combine activity, subject, and data Data Frames 
* Combine using cbind, specifying that we don't want strings to be interpreted as factors

### Extract the subject, activity columns and any columns containing "mean" or "std"
* find column numbers containing mean using grep
* find column numbers containing std using grep
* find column number of Subject using match()
* find column number of Activity using match()
* extract the above columns into a new data frame

## Get rid of the "-"'s and "()"'s in the names
* use stringr::str_replace_all()

## Now create data set with average of each variable for each activity and each subject 
* Create an initial "result" data frame grouped by Activity and Subject
* Iterate through the names of the columns, using summarize to generate a column of means (grouped by Activity and Subject), and using cbind to add the resulting column produced by summarize to the "result" data frame.

## Write out the tidy data set
* Use write.table to write result to "myTidyDataSet.txt"

