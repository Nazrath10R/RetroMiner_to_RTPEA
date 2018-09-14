
suppressMessages(library("argparser"))    # Argument passing

parser <- arg_parser("This parser contains the input arguments")

parser <- add_argument(parser, "--DIR",
                       help = "retrominer_output/results")

argv   <- parse_args(parser)

dir   <- argv$DIR


mining_status <- read.table("/data/SBCS-BessantLab/naz/pride_reanalysis/reanalysis_log.txt", sep = "\t", header = TRUE)

re_analysed <- mining_status[which(mining_status$retromined=="y"),]$pxd

re_analysed <- as.character(re_analysed)

re_analysed <- re_analysed[-which(re_analysed=="PXD003410_old")]

write(re_analysed, file = paste(dir, "/pxd_list.txt", sep = ""), sep = "\n")

