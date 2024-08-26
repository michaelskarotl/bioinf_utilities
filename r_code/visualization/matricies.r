#!/usr/bin/env Rscript
#####################################
# Project Begin: August 26, 2024
# Project End: August 26,2024
# Author: Michael Skaro
# Purpose: Use the skeleton script to create a helper script to add a table to the 

# Functions:
#   1. create options
#   2. add file to matrix
#   3. create table
#   4. create visulization functions
# Usage: R script to be invoked and interacted with from the terminal.
# Parameters: 
# Rscript 
#####################################


# For the purposes of this script let's assume you have used the skeleton script
# for the cli exectution. We can just load the libraries and build a from there. 

library(optparse)
library(tidyverse)
library(data.table)
library(stringr)
library(dplyr, warn.conflicts = FALSE)
library(dbplyr)
library(knitr)
library(devtools)



# create a matrix of 10 colums and 3000 rows, random integers between 1, 1000
matrix <- matrix(sample(1:1000, 3000*10, replace = TRUE), ncol = 10)
# make the column names 1:5 control 1,2,3,4,5 and 6:10 treatment 1,2,3,4,5
colnames(matrix) <- c("control1", "control2", "control3", "control4", "control5", "treatment1", "treatment2", "treatment3", "treatment4", "treatment5")
# make the row names gene 1:3000
rownames(matrix) <- paste0("gene", 1:3000)
# convert the matrix to a data frame
df <- as.data.frame(matrix)

# create a study design data frame
study_design <- data.frame(
  group = c(rep("control", 5), rep("treatment", 5)),
  timepoint = rep(1:5, 2),
  dose = rep(1:5, 2)
)




















