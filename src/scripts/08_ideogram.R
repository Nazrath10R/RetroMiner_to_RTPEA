#!/usr/bin/Rscript
suppressMessages(library("argparser")) 

rm(list=ls())

#### Libraries #### 
suppressMessages(library(Biostrings))
suppressMessages(library("jsonlite"))   # read / write jSON files in R
# library(seqLogo)

print_json <- function(x) {
  x.json <- toJSON(x, pretty = TRUE, na='string', auto_unbox = TRUE)
  print(x.json)
}

write.json <- function(x, file = "", ...) {
  x.json <- toJSON(x, pretty = TRUE, na='string', auto_unbox = TRUE)
  write(x.json, file=file)
}



#### working directory #### 
setwd("/data/SBCS-BessantLab/naz/RetroMiner_to_RTPEA")


# HS_genomic_table <- read.table("./HS_genomic_table.txt", sep = "\t", header = TRUE)

HS_genomic_table <- read.table("example_files/genomic_table.txt", sep = "\t", header = TRUE)
HS_genomic_table <- HS_genomic_table[1:(nrow(HS_genomic_table)-6),]


chr_json <- fromJSON("example_files/chr.json")


# duplication
chr_json[1:nrow(HS_genomic_table),]  <- chr_json[1,]

# extract protein names
names <- as.character(HS_genomic_table$ORF1p)
names <- gsub("_ORF1p", "", names)

# add protein names to json
chr_json$name <- names



## extract chr numbers
grep("chr", HS_genomic_table$genomic_location)

unlist(strsplit(as.character(HS_genomic_table$genomic_location), split = "chr"))


chr_no <- unlist(strsplit(as.character(HS_genomic_table$genomic_location), split = "range="))
chr_no <- chr_no[seq(2,length(chr_no),2)]
chr_no <- unlist(strsplit(chr_no, split = ":"))
chr_no <- chr_no[seq(1,length(chr_no),2)]

chr_no <- gsub("chr", "", chr_no)

# remove non numeric
chr_no <- gsub("_.+", "", chr_no)


# chr_no  <- c(as.numeric(chr_no[1:111]), chr_no[112:length(chr_no)])

chr_json$chr <- chr_no





## extract location cordinates

loc <- unlist(strsplit(as.character(HS_genomic_table$genomic_location), split = ":"))
loc <- loc[seq(2,length(loc),2)]
loc <- unlist(strsplit(loc, split = " 5"))
loc <- loc[seq(1,length(loc),2)]
loc <- strsplit(loc, split = "-")
loc <- unlist(loc)

chr_json$start <- loc[seq(1,length(loc),2)]
chr_json$stop <- loc[seq(2,length(loc),2)]


chr_json$start <- as.numeric(chr_json$start)
chr_json$stop <- as.numeric(chr_json$stop)


# print_json(chr_json)


write.json(chr_json, path="output/chromosome/chromosome_2.json")

