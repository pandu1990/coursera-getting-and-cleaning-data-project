library(reshape2)

filename <- "dataset.zip"
# Download data files if they do not exist
if(!file.exists(filename)) {
  url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(url, filename, method = "curl")
}

# Dataset directory
directory <- "UCI HAR Dataset"
if(!file.exists(directory)) {
  unzip(filename)
}

# Save old work directory
oldwd <- getwd()
# Set current work directory to "UCI HAR Dataset"
setwd(directory)

# Load activity labels and features
activityLabels <- read.table("activity_labels.txt", colClasses = "character")
features <- read.table("features.txt", colClasses = "character")

#Extract data for mean and standard deviation
featuresNeeded <- grep("(mean|std)\\(\\)", features[, 2])
featuresNeededNames <- features[featuresNeeded, 2]
featuresNeededNames <- gsub("-mean", "Mean", featuresNeededNames)
featuresNeededNames <- gsub("-std", "Std", featuresNeededNames)
featuresNeededNames <- gsub("[-()]", "", featuresNeededNames)

# Load training dataset
trainData <- read.table("train/X_train.txt")[featuresNeeded]
trainActivities <- read.table("train/y_train.txt")
trainSubjects <- read.table("train/subject_train.txt")
trainData <- cbind(trainSubjects, trainActivities, trainData)

#Load test dataset
testData <- read.table("test/X_test.txt")[featuresNeeded]
testActivities <- read.table("test/y_test.txt")
testSubjects <- read.table("test/subject_test.txt")
testData <- cbind(testSubjects, testActivities, testData)

#Merge datasets
allData <- rbind(trainData, testData)

#Add Labels
colnames(allData) <- c("subject", "activity", featuresNeededNames)

#Convert activity and subject into factors
allData$activity <- factor(allData$activity, activityLabels[, 1], labels = activityLabels[, 2])
allData$subject <- as.factor(allData$subject)

allDataMelted <- melt(allData, id = c("subject", "activity"))
allDataMean <- dcast(allDataMelted, subject + activity ~ variable, mean)

write.table(allDataMean, "tidy_data.txt", row.names = FALSE, quote = FALSE)

# Set old working directory
setwd(oldwd)