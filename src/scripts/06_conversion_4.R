#!/usr/bin/Rscript

rm(list=ls())

#### Libraries ####

# library(seqLogo)
suppressMessages(library(Biostrings))
suppressMessages(library("jsonlite"))   # read / write jSON files in R
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

sequence_dir <- paste(example, "/sequences", sep="")  

########################################

print_json <- function(x) {
  x.json <- toJSON(x, pretty = TRUE, na='string', auto_unbox = TRUE)
  print(x.json)
}

write.json <- function(x, file = "", ...) {
  x.json <- toJSON(x, pretty = TRUE, na='string', auto_unbox = TRUE)
  write(x.json, file=file)
}


########################################

# setwd("/Users/nazrathnawaz/Dropbox/PhD/retroelement_expression_atlas/data/variants/")

LINE_1_consensus <- readAAStringSet(paste(sequence_dir, "/consensus_sequences.fasta", sep = ""))
LINE_1_variants <- readAAStringSet(paste(sequence_dir,"/LINE_1.fasta", sep = ""))

# load("../results/table.Rdata")
# table 
# table[which(table$ORF1p_variants!=0),]$ORF1p_variants
genomic_table <- read.table(paste(example, "/genomic_table.txt", sep = ""), sep = "\t", header = TRUE)

########################################


# this is where the result loop should be or an argument

# 3406,7
# 3414
# 3415
# PXD <- "PXD003406"
# PXD <- "PXD003415"

confidence_level <- 10

# pxd_list <- c("PXD000944","PXD002211","PXD002212","PXD003406","PXD003407","PXD003408","PXD003409",
              # "PXD003410","PXD003411","PXD003412","PXD003413","PXD003414","PXD003415","PXD003416",
              # "PXD003965","PXD004051","PXD004280","PXD004624","PXD004625","PXD004626","PXD004682",
              # "PXD004818","PXD004987","PXD005150","PXD005733")



# pxd_list <- c("PXD000944","PXD002211","PXD002212","PXD002523","PXD002614",
#   "PXD003271","PXD003406","PXD003407","PXD003408","PXD003409",
#   "PXD003410","PXD003411","PXD003412","PXD003413","PXD003414",
#   "PXD003415","PXD003416",
#   # "PXD003417","PXD003552",
#   "PXD003965","PXD004051","PXD004280","PXD004624", "PXD004625","PXD004626",
#   "PXD004682","PXD004818","PXD004987","PXD005150","PXD005733")


# errors
# "PXD003417","PXD003552"
# HS 16 has an NA


pxd_list <- readLines("/data/SBCS-BessantLab/naz/RetroMiner_to_RTPEA/src/pxd_list.txt")


# 2212

for(pxd_id in 1:length(pxd_list)) {
  
  # pxd_id=21
  
  # print(pxd_list[pxd_id])
  
  PXD <- pxd_list[pxd_id]
  # print(PXD)
  
  input_file_name <- paste(paste(output, "/table/", sep = ""), PXD,".jSON", sep = "")
  
  if(file.exists(input_file_name)==FALSE) { next }

  result_1 <- fromJSON(input_file_name)    
  

  for(protein in 1:2) {
  
    # protein=2
    
    top_exp_samples_1p <- c()
    
    for(x in 1:nrow(result_1$sample)) {
      # x=84
      confidences <- result_1$sample[,protein+8][[x]]$confidence
      
      for(y in 1:length(confidences)) {
        if (confidences[y]>confidence_level) {
          top_exp_samples_1p <- c(top_exp_samples_1p, x)
        }
      }
    }
    
    top_exp_samples_1p <- unique(top_exp_samples_1p)
    
    if(is.null(top_exp_samples_1p)==TRUE) { next }
    
    
    ########################################################
    tissues <- result_1$sample[top_exp_samples_1p,]$tissue_type
    dis <- result_1$sample[top_exp_samples_1p,]$diseaseState
    
    state <- ""
    if(unique(dis)=="disease"){state <- "diseased"}
    # if(unique(dis)=="healthy"){state <- "healthy"}
    
    dis[which(dis=="disease")] <- result_1$disease
    
    diseases <- dis
    ########################################################
    
    
    top_variant_1p <- result_1$sample[top_exp_samples_1p[1],][,protein+8]
    top_exp_var_1p <- which(unlist(top_variant_1p[[1]]$confidence)>confidence_level)
    
    var_list <- unlist(top_variant_1p[[1]]$name)[top_exp_var_1p]
    confidences_list <- unlist(top_variant_1p[[1]]$confidence[top_exp_var_1p])
    
    for(y in 1:length(var_list)) {
      # y=1
      var_name <- var_list[y]
      var_p_name <- var_name
      var_p_name <- gsub("p","P", var_p_name)
      con <- confidences_list[y]
      
      if(protein==1) { var_name <- gsub("ORF1p_", "", var_name) }
      if(protein==2) { var_name <- gsub("ORF2p_", "", var_name) }
      
      
      var_seq <- LINE_1_variants[grep(var_name, names(LINE_1_variants))][protein]   # 1 for 1p
      var_sequence <- var_seq[[1]]
      
      
      #### Alignment
      if(protein==1) { consensus_protein <- 1 }
      if(protein==2) { consensus_protein <- 2 }
      
      
      align <- pairwiseAlignment(LINE_1_consensus[consensus_protein],var_sequence,type="global")
      variant_table <-  mismatchTable(align)
      
      
      #### jSON
      json_template <- fromJSON(paste(example, "/visualise_example_new.json", sep = ""))
      
      no_of_variants <- nrow(variant_table)
      
      for(z in 1:no_of_variants) {
        json_template$features[z,] <- json_template$features[1,]
      }
      
      
      # fill info
      json_template$PXD <- var_p_name
      json_template$sequence <- as.character(var_sequence)
      json_template$features$description <- var_name
      json_template$features$type <- "SNP"
      json_template$features$type <- "VARIANT"
      
      
      # for(x in 1:no_of_variants) {
      for(x in 1:no_of_variants) {
        
        json_template$features$alternativeSequence[x] <- as.character(variant_table$SubjectSubstring[x])
        json_template$features$wildType[x] <- as.character(variant_table$PatternSubstring[x])
        json_template$features$begin[x] <- variant_table$PatternStart[x]
        json_template$features$end[x] <- variant_table$PatternEnd[x]
        # json_template$features$polyphenPrediction[x] <- "unknown"
        # json_template$features$polyphenScore[x] <- 0.0
        # json_template$features$evidences[x] <- "NA"
        # json_template$features$siftPrediction[x] <- "not tolerated, low value"
        
        ## siftScore = protein confidence score divided by 100
        json_template$features$siftScore[x] <- con/100
        
        
        json_template$features$Family[x] <- unlist(strsplit(var_p_name, split = "_"))[2]
        
        
        if(state=="diseased"){
        json_template$features$consequence[x] <- paste(tissues, state, sep = " ")
        } else {
        json_template$features$consequence[x] <- tissues
        }
        
                
        if(state=="diseased"){
        json_template$features$consequence2[x] <- paste(tissues, state, sep = " ")
        } else { json_template$features$consequence2[x] <- "" }
        json_template$features$consequence3[x] <- diseases
        
      }
      
      # print_json(json_template)
      output_name <- paste(PXD, var_list[y], sep = "_variant_")
      
      
      ####
      
      write.json(json_template, file = paste(paste(output,"/protvista/",sep = ""), output_name,".jSON", sep=""))
      
      ####
      
      # print_json(json_template$features$siftScore)
      
      if(pxd_id<10) { pxd_id_print <- paste(0, pxd_id, sep="") } else { pxd_id_print <- pxd_id }

      print(paste("(", pxd_id_print, "of", length(pxd_list), ")" ,paste("ProtVista json generated: ", PXD, sep = " "), sep = " "))
    }
  }
}

# 
# exampleFiles <- list.files(path = "./results/", pattern = "*.jSON", full.names = TRUE)               
# 
# 
# fromJSON("./results/*.jSON")
# 
# 

# 
# 
# # ORF2p_PA2_26
# genomic_table
# 
# example_seq <- LINE_1_variants[which(names(LINE_1_variants)=="LINE_1_PA2_26_ORF2p")][[1]]
# 
# LINE_1_consensus[2]
# 
# 
# align <- pairwiseAlignment(LINE_1_consensus[2],example_seq, type="global")
# 
# variant_table <-  mismatchTable(align)
# 
# 
# 
# 
# 
# 
# align <- global(LINE_1_consensus[2],example_seq)
# 
# muscle(LINE_1_consensus[2],example_seq)
# 
# 
# 
# 
# 
# paste(LINE_1_variants[which(names(LINE_1_variants)=="LINE_1_PA2_26_ORF2p")], LINE_1_consensus[2])
# 
# 




