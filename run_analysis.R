##run_analysis.R
    
## This script analyzes data from 
## https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 

## In order to run the script make sure the script and the unzipped data folder "getdata-projectfiles-UCI HAR Dataset"
## are in the same directory

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

# Write the result of last step to the txt file in the working directory
write.table(tidy_dataset_summary,"tidy_dataset_step_5.txt", row.names = FALSE)
