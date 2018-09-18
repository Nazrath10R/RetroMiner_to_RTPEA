#!/usr/bin/Rscript

####################################################################
##   converting RetroMiner's parsed output_table to jSON format   ##
####################################################################

#   This script is to restructure the result parser output         #
#   to suit an example jSON format used to populate a MongoDb      #
#                 ~~ work in progress                              #

########################################################################

rm(list=ls())

########################################################################

suppressMessages(library("argparser"))    # Argument passing

parser <- arg_parser("This parser contains the input arguments")

parser <- add_argument(parser, "--DATA",
                       help = "retrominer_output/results")
parser <- add_argument(parser, "--OUTPUT",
                       help = "output directory")
parser <- add_argument(parser, "--EXAMPLES",
                       help = "path to directory with example files")



argv   <- parse_args(parser)

dir   <- argv$DATA
output <- argv$OUTPUT
example <- argv$EXAMPLES


########################################################################

#### Functions to read and write jSON files #### 

write.json <- function(x, file = "", ...) {
  x.json <- toJSON(x, pretty = TRUE, na='string', auto_unbox = TRUE)
  write(x.json, file=file)
}


print.json <- function(x) {
  x.json <- toJSON(x, pretty = TRUE, na='string', auto_unbox = TRUE)
  print(x.json)
}


########################################################################




#### Libraries #### 
# install.packages('jsonlite', dependencies=TRUE, repos='http://cran.rstudio.com/')
suppressMessages(library("jsonlite"))   # read / write jSON files in R


#### working directory #### 
setwd(dir)

#### reset counter #### 
counter_data <- fromJSON(paste(example,"/CounterData.json", sep = ""))
counter_data$prideDatasets <- 0
counter_data$samples <- 0
counter_data$specSize <- 0
write.json(counter_data, paste(example,"/CounterData.json", sep = ""))

#### Input #### 
# diseaseState
# spectralSize
# load example jSON - CHANGE PATH
json_copy <- fromJSON(paste(example,"/example.json", sep = ""))

# read in RetroMiner output
table <- read.table(paste(dir, "/combined_results/output_table_with_consequence.txt", sep = ""), sep= "\t", header = TRUE)

# add fields for manual description
# Consequence table goes here
# table$Study <- NA
table$State <- NA

# restructure table to put Tissue after Sample
table <- table[c("Dataset","Study","Disease","spectralSize","Tissue", "Sample", "Replicate", "diseaseState","State","ORF1p","ORF2p", "ORF0","ORF1p_variants","ORF2p_variants","HERV_proteins","PTMs")]
# head(table)


## Saved RData table for quicker loading
# save(table, file="table.RData")
# load(file="table.RData")







########  Conversion function  ######## 

## List of datasets to convert
pxd_list <- as.character(unique(table$Dataset))


# for(y in 1:length(pxd_list)) {


output_to_json_conversion <- function(y) {

  # y=1
  # pxd <- "PXD000944"
  
  pxd <- pxd_list[y]
    
  current_dataset <- table[table$Dataset==pxd_list[y],]
    
  
  ## counter file
  counter_data <- fromJSON(paste(example, "/CounterData.json", sep = ""))
  
  # extract metadata for dataset
  meta <- unique(current_dataset[,1:4])
  
  meta$no_of_samples <- unique(max(current_dataset$Sample))   # number of samples
  
  
  # meta$no_of_samples <- unique(meta$no_of_samples) 
  
  
  #### set up jSON file to complete ####
  
  new_json <- NULL
  
  new_json$PXD <- as.character(meta$Dataset[1])
  new_json$study <- paste(unlist(strsplit(as.character(meta$Study[1]), split = "_")), collapse = " ")
  new_json$disease <- as.character(paste(meta$Disease, collapse = ", "))
  new_json$no_of_samples <- meta$no_of_samples[1]
  
  new_json$spectralSize <- meta$spectralSize[1]

  json_narrowed <- json_copy$sample[-(meta$no_of_samples[1]+1:200),]
  
  # set up internal dataframe based on example files
  new_json$sample <- data.frame()
  new_json$sample <- json_narrowed
  
  
    
  for(x in 1:new_json$no_of_samples) {
    
    current_sample <- current_dataset[current_dataset$Sample==x,]

    # remove metadata
    current_sample[,1:4] <- NULL
    
    # changes Sample to Snumber
    colnames(current_sample)[2] <- "Snumber"
    
    
    if(nrow(current_sample)>1) {current_sample <- current_sample[1,]}
    
    # fill in information from current sample to jSON 
    new_json$sample[x,]$Snumber <- current_sample$Snumber
    new_json$sample[x,]$replicate <- current_sample$Replicate
    new_json$sample[x,]$phenotype <- current_sample$State
    new_json$sample[x,]$tissue_type <- as.character(current_sample$Tissue)    # moved inside now
    new_json$sample[x,]$diseaseState <- as.character(current_sample$diseaseState)
    
    # LINE-1 consensus proteins
    new_json$sample[x,]$ORF1p$confidence <- current_sample$ORF1p
    new_json$sample[x,]$ORF2p$confidence <- current_sample$ORF2p
    
    ## Given Sample can express several variants
    
    # if Variants are present, add as a list - change this! 
    if(current_sample$ORF1p_variants!=0){
      y <- unlist(strsplit(as.character(current_sample$ORF1p_variants), split="_\\(|\\),|\\)"))
      names <- y[seq(1,(length(y)),2)]
      confidences <- y[seq(2,(length(y)),2)]
      new_json$sample[x,]$ORF1p_variants$name <- list(names)
      new_json$sample[x,]$ORF1p_variants$confidence <- list(as.numeric(confidences))
    }
    
    if(current_sample$ORF2p_variants!=0){
      z <- unlist(strsplit(as.character(current_sample$ORF2p_variants), split="_\\(|\\),|\\)"))
      names <- z[seq(1,(length(z)),2)]
      confidences <- z[seq(2,(length(z)),2)]
      new_json$sample[x,]$ORF2p_variants$name <- list(names)
      new_json$sample[x,]$ORF2p_variants$confidence <- list(as.numeric(confidences))
    }
    
    # using spare field to check loop iterations
    # new_json$sample[x,]$phenotype <- "parsed"
    
    # print(toJSON(new_json, pretty = TRUE, na='string', auto_unbox = TRUE))
    
  }
  
  
  
  ## print jSON
  # toJSON(new_json, pretty = TRUE, na='string', auto_unbox = TRUE)
  # print.json(new_json)
  # print(unique(new_json$sample$diseaseState))

  # print(new_json$sample$ORF1p$confidence)
  
  ## fill counter
  counter_data$prideDatasets <- counter_data$prideDatasets + 1
  
  if(is.na(new_json$no_of_samples)==FALSE){
  counter_data$samples  <- counter_data$samples + new_json$no_of_samples
  }
  
  if(is.na(new_json$spectralSize)==FALSE){
  counter_data$specSize  <- counter_data$specSize + (new_json$spectralSize/1024)
  }
  
  # print(paste(pxd, " size: ", round(counter_data$specSize, 3)))
  
  write.json(counter_data, paste(example,"/CounterData.json", sep = ""))
  
  
  ## write jSON out
  write.json(new_json, paste(paste(output, "/table/", sep = ""), pxd, ".jSON", sep = ""))

}



#### Run for all datasets ####

for(z in 1:length(pxd_list)) {
  # print("")
  if(z < 10) {print_z <- paste(0,z, sep = "") } else {print_z <- z}
  print(paste(paste("(",print_z,"/",length(pxd_list),")",
                    "converted to json: "), pxd_list[z]))
  output_to_json_conversion(z)
  # print("")  
}


