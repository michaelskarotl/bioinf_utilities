#!/usr/bin/env Rscript
#####################################
# Project Begin: August 26, 2024
# Project End: August 26,2024
# Author: Michael Skaro
# Purpose: Use the skeleton script to create a helper script to add a table to the 
# rna_val_db in the /Users/michael.skaro/Research/tempusRepos/bioinf-rna-onco-verification/device_validation/rnaval_db/rnaval_data/rnaval.db
# directory. 
# Functions:
#   1. create options
#   2. add file to matrix
#   3. create table
#   4. create visulization functions
# Usage: R script to be invoked and interacted with from the terminal.
# Parameters: 
# Rscript Rscript rna_val_db_to_rad-study-design_DPs.R -i /Users/michael.skaro/Research/tempusRepos/bioinf-rna-onco-verification/device_validation/rnaval_db/rnaval_data/db/rnaval.db -p 1.3 -o .  -x /Users/michael.skaro/Research/tempusRepos/bioinf-rna-onco-verification/helpers/db_to_rad/PCL-00089_ref.txt -t BFXA-4210
#####################################

# If there is an renv available, load it
# install the renv package if not already installed
if (!requireNamespace("renv", quietly = TRUE)) {
  install.packages("renv", repos = "http://cran.us.r-project.org")
}

# if there is an existing renv.lock file, restore the R environment to the state saved in the lock file
# This is a nice best practice to ensure that the R environment is consistent across different machines. 
if (file.exists("renv.lock")) {
  library(renv)
  renv::restore()
  # Call the libraries
  library(renv)
  library(optparse)
  library(tidyverse)
  library(data.table)
  library(DBI)
  library(RSQLite)
  library(languageserver)
  # included in tidyverse install
  library(stringr)
  library(dplyr, warn.conflicts = FALSE)
  library(dbplyr)
  library(knitr)
  library(devtools)
}

# if there is no renv.lock file, create a new project library and snapshot the R environment
if (!file.exists("renv.lock")) {
  renv::init()
}

# Load the libraries
library(optparse)
library(tidyverse)
library(data.table)
library(DBI)
library(RSQLite)
library(languageserver)
# included in tidyverse install
library(stringr)
library(dplyr, warn.conflicts = FALSE)
library(dbplyr)
library(knitr)
library(devtools)

# Now that we have a consistent R environment, we can install the necessary packages
print("Installing the necessary packages with renv loaded, this takes a while the first time, go get some coffee []D")

# install the optparse package if not already installed
if (!requireNamespace("optparse", quietly = TRUE)) {
  install.packages("optparse", repos = "http://cran.us.r-project.org")
}

# install the libraries from the cran repo and the bioconductor repo to conduct the differential expression analysis in a nexflow pipeline

# install the tidyverse package if not already installed
if (!requireNamespace("tidyverse", quietly = TRUE)) {
  install.packages("tidyverse", repos = "http://cran.us.r-project.org")
}

# install data.table package if not already installed
if (!requireNamespace("data.table", quietly = TRUE)) {
  install.packages("data.table", repos = "http://cran.us.r-project.org")
}

# install DBI package if not already installed
if (!requireNamespace("DBI", quietly = TRUE)) {
  install.packages("DBI", repos = "http://cran.us.r-project.org")
}

# install languageserver package if not already installed
if (!requireNamespace("languageserver", quietly = TRUE)) {
  install.packages("languageserver", repos = "http://cran.us.r-project.org")
}

# install devtools package if not already installed
if (!requireNamespace("devtools", quietly = TRUE)) {
  install.packages("devtools", repos = "http://cran.us.r-project.org")
}

# install knitr package if not already installed, not sure if this is in tidyverse
if (!requireNamespace("knitr", quietly = TRUE)) {
  install.packages("knitr", repos = "http://cran.us.r-project.org")
}

# install RSQLite package if not already installed, not sure if this is in tidyverse
if (!requireNamespace("RSQLite", quietly = TRUE)) {
  install.packages("RSQLite", repos = "http://cran.us.r-project.org")
}

# snapshot the R environment
renv:::snapshot()
# create an opt list for the aruguements
option_list = list(
  make_option(c("-i", "--input"), type="character", default=NULL, 
              help="input database, expected .db file", metavar="character"),
  make_option(c("-t", "--ticket"), type="character", default=NULL, 
              help="ticket requiest ID", metavar="character"),
  make_option(c("-o", "--output"), type="character", default="output/", 
              help="output file directory [default= %default]", metavar="character"))

# Call the libraries
library(renv)
library(optparse)
library(tidyverse)
library(data.table)
library(DBI)
library(RSQLite)
library(languageserver)
# included in tidyverse install
library(stringr)
library(dplyr, warn.conflicts = FALSE)
library(dbplyr)
library(knitr)
library(devtools)

# parse the arguments using thr arg parser.
opt_parser <- OptionParser(option_list = option_list)
opt <- parse_args(opt_parser)

# file error handling and parse error handling to exit gracefully.
if (is.null(opt$input)) {
  stop("Please provide an input database file")
}

if (is.null(opt$ticket)) {
  stop("Please provide a ticket ID")
}

if (is.null(opt$report_table)) {
  stop("Please provide a report table")
}

# create the output directory if it does not exist
if (!dir.exists(opt$output)) {
  dir.create(opt$output)
}


# annotate the session info and write it into the output directory
my_session_info <- devtools::session_info()
writeLines(text = {
  paste(sep = "\n", collapse = "",
        paste0(rep("-", 80), collapse = ""),
        paste(paste0(rep("-", 32), collapse = ""),
              "R environment",
              paste0(rep("-", 33), collapse = "")),
        paste0(rep("-", 80), collapse = ""),
        paste(knitr::kable(t(data.frame(my_session_info$platform)), col.names = "value"), collapse = "\n"),
        paste0(rep(" ", 80), collapse = ""),      # some separator
        paste0(rep(" ", 80), collapse = ""),      # some separator
        paste0(rep("-", 80), collapse = ""),
        paste(paste0(rep("-", 35), collapse = ""),
              "packages",
              paste0(rep("-", 35), collapse = "")),
        paste0(rep("-", 80), collapse = ""),
        paste(knitr::kable(my_session_info$packages), collapse = "\n")
  )
}, con = str_glue("{output}/{ticket}_session_info.txt"))


# create a fucntion fo reading the input file into a list of tables

read_db <- function(db_file) {
  con <- dbConnect(RSQLite::SQLite(), db_file)
  on.exit(dbDisconnect(con))
  tables <- dbListTables(con)
  tables
}

# create a function to read the table into a data frame and use a query to select all the data from the table

read_table <- function(db_file, table_name) {
  con <- dbConnect(RSQLite::SQLite(), db_file)
  on.exit(dbDisconnect(con))
  query <- dbSendQuery(con, paste0("SELECT * FROM ", table_name))
  data <- dbFetch(query)
  dbClearResult(query)
  data
}


# if the input file is not a .db file, and is a tab or comma separated file, read the file into a data frame
parse_file_io <- function(input) {
  if (str_detect(input, ".db")) {
    tables <- read_db(input)
    tables
  } else {
    dat <- data.table::fread(input)
    dat
  }
}

# iterate through the columns in the data file and return a data frame of the types 
# of the columns in the data file and if they are numeric, take the range of the values in the column

get_column_types <- function(data) {
  column_types <- data.frame(
    column_name = names(data),
    column_type = sapply(data, class),
    column_range = sapply(data, function(x) {
      if (is.numeric(x)) {
        range(x)
      } else {
        NA
      }
    })
  )
  column_types
}







