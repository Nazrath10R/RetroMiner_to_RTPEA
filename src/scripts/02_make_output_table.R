#!/usr/bin/Rsript

suppressMessages(library("argparser"))    # Argument passing

parser <- arg_parser("This parser contains the input arguments")

parser <- add_argument(parser, "--DIR",
                       help = "working directory")

argv   <- parse_args(parser)

DIR   <- argv$DIR

# setwd("/data/SBCS-BessantLab/naz/RetroMiner_to_RTPEA/retrominer_output/results/final")
setwd(DIR)


input_files <-  list.files(path = ".", pattern = "*_parsed.txt")

# example <- input_files[1]

# example_table <- read.table(example, sep="\t", header=TRUE)
# second_table <- read.table(input_files[2], sep="\t", header=TRUE)

# rbind(example_table, second_table)

# create empty table
table <- matrix(NA, 1, 12)
table <- as.data.frame(table)

colnames(table) <- c("Dataset","Disease","Tissue","Sample","Replicate","ORF1p","ORF2p","ORF0","ORF1p_variants","ORF2p_variants","HERV_proteins","PTMs")


for(i in 1:length(input_files)) {
  tab <- read.table(input_files[i], sep="\t", header=TRUE)
  table <- rbind(table, tab)
}

table <- table[-1,]

write.table(table, "output_table.txt", sep="\t")

print("Output table re-generated")
