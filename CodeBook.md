# Codebook


## Overview

**run_analysis.R** script prepares tidy data set per the requirements described in the Project page of the Getting and Cleaning data course on Coursera (https://class.coursera.org/getdata-030/human_grading/view/courses/975114/assessments/3/submissions)
 
The script uses Human Activity Recognition Using Smartphones Dataset (Version 1.0).
For more information about this data set refer to http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones 

For more details about **run_analysis.R** refer to README.md.

## Input variables

The files used as input to the **run_analysis.R** script can be dowloaded from
https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 

The dataset data was collected from 30 volunteers who performed six activities (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) wearing a smartphone. Each recording included collecting data from 3-axial accelerometer and gyroscope. The data then was processed to generate 561-feature vectors with time and frequency domain variables.

For the detailed description of the features and input dataset structure please refer to README.txt, features_info.txt and features.txt which are part of the original dataset.


## Output dataset

The script creates tidy dataset based on the original data and writes it to tidy_dataset_step_5.txt file.
The dataset has a wide format having 180 rows (30 subjects x 6 activities) and 68 columns (subject, activity + average of each of 66 features from the original dataset which re3present mean and standard deviation of the physical measurements).

Below the first 12 rows x 5 columns are given to demonstrate the structure of the dataset  

```S
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
Note: Per the requirements of the project, only features which had mean() or std() in their name were included in the ouput dataset. 

### Variables description
#### [1] "subject"
```
Type:			integer
Values:			1 to 30 
Description:	An identifier of the subject who carried out the experiment
```
#### [2] "activity"
```
Type:			Factor
Levels: 		LAYING SITTING STANDING WALKING WALKING_DOWNSTAIRS WALKING_UPSTAIRS
Description: 	Six activities performed during the experiments
```
#### [3:68] 66-feature vector as described below
```
Type:			numeric
Values: 		all features are within [-1,1] range
Description: 	66 features were calclulated by finding an average value of the corresponding features in the original dataset having mean() or std() in the their name (per each activity and per each subject).
The new features are derived from the measurements of the following parameters both in time and frequency domains:

1. Parameter: Body Accelaration						
   New features name scheme: {t,f}BodyAcc{X,Y,Z, Mag}-{mean,std} 		(16 features)
    
2. Parameter: Gravity Acceleration						
   New features name scheme: tGravityAcc{X,Y,Z, Mag}-{mean,std}			(8 features)
    
3. Parameter: Body Acclelerometer Jerk					
   New features name scheme: {t,f}BodyAccJerk{X,Y,Z, Mag}-{mean,std}	(16 features)
    
4. Parameter: Body Angular Velocity 					
   New features name scheme: {t,f}BodyGyro{X,Y,Z, Mag}-{mean,std}		(16 features)
    
5. Parameter: Body Gyroscope Jerk 						
   New features name scheme:  tBodyGyroJerk{X,Y,Z, Mag}-{mean,std}		(8 features)
   New features name scheme:  fBodyGyroJerkMag-{mean,std}				(2 features)

The feature names tranformation was performed by
1. Swapping (where applicable) mean/std with X/Y/Z, such that the mathematical operator (mean/std) will be always in end of the name
2. Removing parentheses from the mean/std operator
3. Removing dash before X/Y/Z to be consistent with Magnitude (Mag) variables
4. Removing double "Body" in some of the variables for consistency, e.g. 
      "fBodyBodyAccJerkMag"   -> "fBodyAccJerkMag"

For example, 
"fBodyBodyAccJerkMag-mean()" is transformed to "fBodyAccJerkMag-mean"
"tBodyAccJerk-std()-X"      is transformed to "tBodyAccJerkX-std"

```

