
setwd("/data/SBCS-BessantLab/naz/RetroMiner_to_RTPEA/retrominer_output/results")

table <- read.table("/data/SBCS-BessantLab/naz/RetroMiner_to_RTPEA/retrominer_output/results/final/output_table.txt", sep= "\t", header = TRUE)

consequence_table <- read.table("/data/SBCS-BessantLab/naz/RetroMiner_to_RTPEA/retrominer_output/input_data/metadata/consequence.txt", sep = "\t", header = TRUE)

size_table <- read.table("/data/SBCS-BessantLab/naz/RetroMiner_to_RTPEA/retrominer_output/input_data/sizes/sizes_matrix.txt", header = TRUE)


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
    
    print(paste("added metadata to: ", pxd))
  
    
  }
  
}


write.table(table, "/data/SBCS-BessantLab/naz/RetroMiner_to_RTPEA/retrominer_output/results/final/output_table_with_consequence.txt", sep = "\t")






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


















