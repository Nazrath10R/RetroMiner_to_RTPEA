
mining_status <- read.table("/data/SBCS-BessantLab/naz/pride_reanalysis/reanalysis_log.txt", sep = "\t", header = TRUE)

re_analysed <- mining_status[which(mining_status$retromined=="y"),]$pxd

re_analysed <- as.character(re_analysed)

re_analysed <- re_analysed[-which(re_analysed=="PXD003410_old")]

write(re_analysed, file = "/data/SBCS-BessantLab/naz/RetroMiner_to_RTPEA/retrominer_output/pxd_list.txt", sep = "\n")

