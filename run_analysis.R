##Download the file and put the file in the data folder
if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/getdata-projectfiles-UCI HAR Dataset.zip")

##Unzip the file
unzip(zipfile="./data/getdata-projectfiles-UCI HAR Dataset.zip",exdir="./data")
##get all the list of files[count is 28]
dirPath <- file.path("./data" , "UCI HAR Dataset")
files<-list.files(dirPath, recursive=TRUE)
files

##Reading Activity files

dataActivityTest  <- read.table(file.path(dirPath, "test" , "Y_test.txt" ),header = FALSE)
dataActivityTrain <- read.table(file.path(dirPath, "train", "Y_train.txt"),header = FALSE)

##Reading Subject files

dataSubjectTrain <- read.table(file.path(dirPath, "train", "subject_train.txt"),header = FALSE)
dataSubjectTest  <- read.table(file.path(dirPath, "test" , "subject_test.txt"),header = FALSE)

##Reading Fearures files
dataFeaturesTest  <- read.table(file.path(dirPath, "test" , "X_test.txt" ),header = FALSE)
dataFeaturesTrain <- read.table(file.path(dirPath, "train", "X_train.txt"),header = FALSE)

# 1.Merges the training and the test sets to create one data set.
# Concatenate the data tables by rows
# .set names to variables
# Merge columns to get the data frame Data for all data
dataSubject <- rbind(dataSubjectTrain, dataSubjectTest)
dataActivity<- rbind(dataActivityTrain, dataActivityTest)
dataFeatures<- rbind(dataFeaturesTrain, dataFeaturesTest)

names(dataSubject)<-c("subject")
names(dataActivity)<- c("activity")
dataFeaturesNames <- read.table(file.path(dirPath, "features.txt"),head=FALSE)
names(dataFeatures)<- dataFeaturesNames$V2

dataCombine <- cbind(dataSubject, dataActivity)
Data <- cbind(dataFeatures, dataCombine)


# 2.Extracts only the measurements on the mean and standard deviation for each measurement. 
# Subset Name of Features by measurements on the mean and standard deviation
subdataFeaturesNames<-dataFeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", dataFeaturesNames$V2)]
# Subset the data frame Data by seleted names of Features
selectedNames<-c(as.character(subdataFeaturesNames), "subject", "activity" )
Data<-subset(Data,select=selectedNames)



# 3.Uses descriptive activity names to name the activities in the data set
# Read descriptive activity names from "activity_labels.txt"
activityLabels <- read.table(file.path(dirPath, "activity_labels.txt"),header = FALSE)


# 4.Appropriately labels the data set with descriptive variable names. 
names(Data)<-gsub("^t", "time", names(Data))
names(Data)<-gsub("^f", "frequency", names(Data))
names(Data)<-gsub("Acc", "Accelerometer", names(Data))
names(Data)<-gsub("Gyro", "Gyroscope", names(Data))
names(Data)<-gsub("Mag", "Magnitude", names(Data))
names(Data)<-gsub("BodyBody", "Body", names(Data))


# 5.From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject
if (!require("plyr")) {
  install.packages("plyr")
}
library(plyr);
Data2<-aggregate(. ~subject + activity, Data, mean)
Data2<-Data2[order(Data2$subject,Data2$activity),]
write.table(Data2, file = "tidydata.txt",row.name=FALSE)
