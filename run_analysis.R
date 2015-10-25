# This script will perform the following steps on the UCI HAR Dataset downloaded from 
# https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
# 1. Merge the training and the test sets to create one data set.
# 2. Extract only the measurements on the mean and standard deviation for each measurement. 
# 3. Use descriptive activity names to name the activities in the data set
# 4. Appropriately label the data set with descriptive activity names. 
# 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject. 

## Get the data
library(plyr)

temp <- tempfile()
download.file("http://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",temp)
unzip(temp, list = TRUE) #This provides the list of variables and I choose the ones that are applicable for this data set
YTest <- read.table(unzip(temp, "UCI HAR Dataset/test/y_test.txt"))
XTest <- read.table(unzip(temp, "UCI HAR Dataset/test/X_test.txt"))
SubjectTest <- read.table(unzip(temp, "UCI HAR Dataset/test/subject_test.txt"))
YTrain <- read.table(unzip(temp, "UCI HAR Dataset/train/y_train.txt"))
XTrain <- read.table(unzip(temp, "UCI HAR Dataset/train/X_train.txt"))
SubjectTrain <- read.table(unzip(temp, "UCI HAR Dataset/train/subject_train.txt"))
Features <- read.table(unzip(temp, "UCI HAR Dataset/features.txt"))
Activities <-read.table(unzip(temp, "UCI HAR Dataset/activity_labels.txt"))
unlink(temp)

# 1. Merge the training and the test sets to create one data set.
XData <- rbind(XTrain, XTest)
YData <- rbind(YTrain, YTest)
names(YData) <- "activity"
SubjectData <- rbind(SubjectTrain, SubjectTest)
names(SubjectData) <- "participant"

# 2. Extract only the measurements on the mean and standard deviation for each measurement. 
ExtractFeatures <- grep("-(mean|std)\\(\\)", Features[, 2])
XData <- XData[, ExtractFeatures]
names(XData) <- Features[ExtractFeatures, 2]
AllData <- cbind(SubjectData, YData, XData)

# 3. Use descriptive activity names to name the activities in the data set
AllData[, 2] <- Activities[AllData[, 2], 2]

# 4. Appropriately label the data set with descriptive activity names. 
names(AllData) <- gsub("Acc", "Accelerator", names(AllData))
names(AllData) <- gsub("Mag", "Magnitude", names(AllData))
names(AllData) <- gsub("Gyro", "Gyroscope", names(AllData))
names(AllData) <- gsub("^t", "time", names(AllData))
names(AllData) <- gsub("^f", "frequency", names(AllData))

# 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject. 
AveragesData <- ddply(AllData, .(participant, activity), function(x) colMeans(x[, 3:68]))
write.table(AveragesData, "TidyData.txt", row.name=FALSE)
