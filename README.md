## Overview

**run_analysis.R** script prepares tidy data set per the requirements described in the Project page of the Getting and Cleaning data course on Coursera.

(https://class.coursera.org/getdata-030/human_grading/view/courses/975114/assessments/3/submissions)
 
The script uses Human Activity Recognition Using Smartphones Dataset (Version 1.0).
For more information about this data set refer to http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones 

The script reads the raw data and performs the following:

* Merge the training and the test sets to create one data set.
* Extract only the measurements on the mean and standard deviation for each measurement. 
* Use descriptive activity names to name the activities in the data set
* Appropriately label the data set with descriptive variable names. 
* Create an independent tidy data set with the average of each variable for each activity and each subject (wide data format).
	

## Before running the script

Before running the script, follow the steps below: 

1. Download the data from  https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
2. Unzip the archive 
3. Copy **run_analysis.R** script into the folder which contains unzipped folder
   **getdata-projectfiles-UCI HAR Dataset**
4. This script makes use of **dplyr** and **stringr** packages. If not installed, run 
```S
install.packages("dplyr")
install.packages("stringr")
```

## Usage

1. Run the script 
2. The script will read the raw data and create as the output tidy data frame, which can be found in the workspace under the name **tidy_dataset_summary**
3. The script will also write the output data frame into the tidy_dataset_step_5.txt file in working directory.  The file can be read back to R using read.table().

## Output tidy data format
The script constructs output data frame **tidy_dataset_summary** in wide format having 180 rows (30 subjects x 6 activities) and 68 columns (subject, activity + average of each of 66 features from the original dataset including mean and standard deviation of the physical measurements).

Below the first 12 rows x 5 columns are given as example of the dataset  

```S
> head(tidy_dataset_summary[,1:5],12)
Source: local data frame [12 x 5]
Groups: subject

   subject           activity tBodyAccX-mean tBodyAccY-mean tBodyAccZ-mean
1        1             LAYING      0.2215982   -0.040513953     -0.1132036
2        1            SITTING      0.2612376   -0.001308288     -0.1045442
3        1           STANDING      0.2789176   -0.016137590     -0.1106018
4        1            WALKING      0.2773308   -0.017383819     -0.1111481
5        1 WALKING_DOWNSTAIRS      0.2891883   -0.009918505     -0.1075662
6        1   WALKING_UPSTAIRS      0.2554617   -0.023953149     -0.0973020
7        2             LAYING      0.2813734   -0.018158740     -0.1072456
8        2            SITTING      0.2770874   -0.015687994     -0.1092183
9        2           STANDING      0.2779115   -0.018420827     -0.1059085
10       2            WALKING      0.2764266   -0.018594920     -0.1055004
11       2 WALKING_DOWNSTAIRS      0.2776153   -0.022661416     -0.1168129
12       2   WALKING_UPSTAIRS      0.2471648   -0.021412113     -0.1525139
```
For more details regarding the data structure and description of the variables refer to CodeBook.md.

## Code structure

### Checking availability of the data and required packages

```S
#Clear workspace
rm(list=ls())

#Loading dplyr and stringr libraries
suppressWarnings(suppressMessages(library(dplyr)))
suppressWarnings(suppressMessages(library(stringr)))


#Path to the actual data files
wd <- ".\\getdata-projectfiles-UCI HAR Dataset\\UCI HAR Dataset"

#Check if data folder is in the working directory
if (!file.exists(wd)){
    stop("Data not found. Copy the unzipped data (\"getdata-projectfiles-UCI HAR Dataset\" folder) in your working directory")
    
}
```

### Reading raw data

```S
# Read train data files
set_name<-"train"

x_train <- read.table(file.path(wd,set_name,paste("X_", set_name, ".txt",sep = ""), fsep = .Platform$file.sep))
y_train <- read.table(file.path(wd,set_name,paste("y_", set_name, ".txt",sep = ""), fsep = .Platform$file.sep))
subject_train <- read.table(file.path(wd,set_name,paste("subject_", set_name, ".txt",sep = ""), fsep = .Platform$file.sep))

# Read test data files
set_name<-"test"

x_test <- read.table(file.path(wd,set_name,paste("X_", set_name, ".txt",sep = ""), fsep = .Platform$file.sep))
y_test <- read.table(file.path(wd,set_name,paste("y_", set_name, ".txt",sep = ""), fsep = .Platform$file.sep))
subject_test <- read.table(file.path(wd,set_name,paste("subject_", set_name, ".txt",sep = ""), fsep = .Platform$file.sep))

# Read activity labels and features files
activity_labels <- read.table(file.path(wd,"activity_labels.txt", fsep = .Platform$file.sep))
features <- read.table(file.path(wd,"features.txt", fsep = .Platform$file.sep))
```

### Formatting the data and preparing tidy dataset

```S
# Add column names to test and train data frames
names(x_test)<-features[,2]
names(x_train)<-features[,2]

## Step 1 and 2 of the assignment

# Merge train and test data (features vectors), select only columns with mean() and std()
x <- rbind(x_train,x_test)
x <- x[,grep("(?:mean\\(\\)|std\\(\\))", names(x))]

#Check that all columns have unique names, stop otherwise 
stopifnot(length(unique(names(x)))==length(names(x)))


## Step 3 and 4 of the assignment

# Create data frame with single column including dataset labels ("train"/"test")   
# This infotmation is not required by the assignment and is added for traceability 
dataset <- data.frame("dataset" = c(rep("train",nrow(x_train)), rep("test",nrow(x_test) )))

# Create data frame with single column including subject labels combining train and test data frames
subjects <- rbind(subject_train,subject_test)
names(subjects) <- c("subject")

# Create data frame with activity labels for both train and test data
y <- rbind(y_train,y_test)
y <- activity_labels[unlist(y),2]
y <- data.frame("activity"=y)

# Format features names for consistency
# 1. Swap (where applicable) mean/std with X/Y/Z, such that the mathematical operator (mean/std) will be always in end of the name
# 2. Remove parentheses from the operator
# 3. Remove dash before X/Y/Z to be consistent with Magnitude (Mag) variables
# 4. Remove double "Body" in some of the variables for consistency, e.g. "fBodyBodyAccJerkMag"   -> "fBodyAccJerkMag"
# Comment: I am leaving the capital letters unchanged since I believe it allows better understanding of the parameters

old_names<-names(x)
new_names <- character(length(old_names))

for (i in 1:length(old_names)){
    old_names[i]<-gsub("-", "", old_names[i])
    
    if (grepl("mean\\(\\)", old_names[i])){
        new_names[i] <- paste0(gsub("mean\\(\\)", "", old_names[i]),"-mean")
    }
    if (grepl("std\\(\\)", old_names[i])){
        new_names[i] <- paste0(gsub("std\\(\\)", "", old_names[i]),"-std")
    } 
    
    if (str_count(new_names[i], "Body")==2){
        new_names[i] <- sub("Body", "", new_names[i])
    }
}

#Check that all columns have unique names, stop otherwise 
stopifnot(length(unique(new_names))==length(new_names))

names(x)<-new_names

# Binding all columns together, creating a single data frame with tidy data 
tidy_dataset <- cbind(subjects, dataset,y, x)

## Step 5 of the assignment 
#  Create independent tidy data set with the average of each variable for each activity and each subject, ignoring dataset type (train/test) 
tidy_dataset_summary <- select(tidy_dataset,-dataset) %>% group_by(subject,activity) %>% summarise_each(funs(mean))
```

### Writing tidy dataset to the txt file

```S
# Write the result of last step to the txt file in the working directory
write.table(tidy_dataset_summary,"tidy_dataset_step_5.txt", row.names = FALSE)
```
