#!/bin/bash

#############################################################
####     CREATE RESULTS TABLE FOR RETROMINER'S OUTPUT    ####
#############################################################

#                                                           #
#               convert cpsx to txt files                   #
#                filter for RT proteins                     #
#           create super table with all results             #
#                                                           #



#============================================================#
# sh create_results_table.sh ARGS
# sh create_results_table.sh 
#============================================================#

DIR=/data/SBCS-BessantLab/naz/RetroMiner_to_RTPEA/retrominer_output
SCRIPTS=/data/SBCS-BessantLab/naz/RetroMiner_to_RTPEA/retrominer_output/data
DATA=/data/SBCS-BessantLab/naz/RetroMiner_to_RTPEA/retrominer_output/scripts

cd $DIR

#------------------------------------------------------------#
#                    create a PXD list                       #
#------------------------------------------------------------#

## get all PXDs to parse 
Rscript $SCRIPTS/pxd_statuses.R
echo
readarray PXD < $DIR/pxd_list.txt
echo "PXD list created"
# echo "${PXD[*]}"

#------------------------------------------------------------#
sh custom_report2.sh

#------------------------------------------------------------#
Rscript $SCRIPTS/parser_argumented.R

#------------------------------------------------------------#
Rscript $SCRIPTS/make_output_table.R












