#!/usr/bin/Rscript

#### add meta data to consequence table

suppressMessages(library("argparser"))    # Argument passing

parser <- arg_parser("This parser contains the input arguments")

parser <- add_argument(parser, "--DATA",
                       help = "retrominer_output/results")
parser <- add_argument(parser, "--META",
                       help = "input_data/metadata")
parser <- add_argument(parser, "--SIZES",
                       help = "size data")

argv   <- parse_args(parser)

dir   <- argv$DATA
metadata <- argv$META
size_data <- argv$SIZES

# setwd("/data/SBCS-BessantLab/naz/RetroMiner_to_RTPEA/retrominer_output/results")
setwd(dir)

table <- read.table(paste(dir,"/combined_results/output_table.txt", sep = ""), sep= "\t", header = TRUE)

consequence_table <- read.table(paste(metadata, "/consequence.txt", sep= ""), sep = "\t", header = TRUE)

size_table <- read.table(paste(size_data, "/sizes_matrix.txt", sep = ""), header = TRUE)


####

table$Disease <- as.character(table$Disease)
table$Tissue <- as.character(table$Tissue)
table$Study <- NA
table$spectralSize <- NA
table$diseaseState <- NA


## should be right order?

for(i in 1:length(unique(table$Dataset))) {
  
  pxd <- unique(table$Dataset)[i]
  
  # print(paste(i, pxd))
  
  if(nrow(table[which(table$Dataset==pxd),]) == nrow(consequence_table[which(consequence_table$PXD==as.character(pxd)),])) {
  
    table[which(table$Dataset==pxd),]$Disease <-

      as.character(consequence_table[which(consequence_table$PXD==as.character(pxd)),]$disease)

    table[which(table$Dataset==pxd),]$Tissue <-

      as.character(consequence_table[which(consequence_table$PXD==as.character(pxd)),]$tissue)

    table[which(table$Dataset==pxd),]$Study <-

      as.character(consequence_table[which(consequence_table$PXD==as.character(pxd)),]$description)

    table[which(table$Dataset==pxd),]$diseaseState <-

      as.character(consequence_table[which(consequence_table$PXD==as.character(pxd)),]$diseaseState)


    
    
    table[which(table$Dataset==pxd),]$spectralSize <-
      
      rep(as.numeric(size_table[which(size_table$PXD==as.character(pxd)),]$size), nrow(table[which(table$Dataset==pxd),]))
    
    print(paste(paste(i, "/", length(unique(table$Dataset)), "added metadata to: "), pxd))
  
    
  }
  
}


write.table(table, paste(dir, "/combined_results/output_table_with_consequence.txt", sep = ""), sep = "\t")



#     
# pxd <- unique(table$Dataset)[i]
#   
#   if(nrow(table[which(table$Dataset==pxd),]) == nrow(consequence_table[which(consequence_table$PXD==as.character(pxd)),])) {
#     
#     tab <- table[which(table$Dataset==pxd),]
#     con <- consequence_table[which(consequence_table$PXD==as.character(pxd)),]
#     
#     no_of_samples <- max(tab$Sample)
#     
#     
#     
#     
#     
#     # 
#     # table[which(table$Dataset==pxd),]$Disease <- 
#     #   
#     #   as.character(consequence_table[which(consequence_table$PXD==as.character(pxd)),]$disease)
#     # 
#     # table[which(table$Dataset==pxd),]$Tissue <- 
#     #   
#     #   as.character(consequence_table[which(consequence_table$PXD==as.character(pxd)),]$tissue)
#     
#     
# }


