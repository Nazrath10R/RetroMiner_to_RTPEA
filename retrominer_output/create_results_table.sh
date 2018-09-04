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
DATA=/data/SBCS-BessantLab/naz/RetroMiner_to_RTPEA/retrominer_output/data
SCRIPTS=/data/SBCS-BessantLab/naz/RetroMiner_to_RTPEA/retrominer_output/scripts

cd $DIR

#------------------------------------------------------------#
#                    create a PXD list                       #
#------------------------------------------------------------#

## get all PXDs to parse 
Rscript $SCRIPTS/pxd_statuses.R
echo
readarray -t PXD < $DIR/pxd_list.txt
echo "PXD list created"
# echo "${PXD[*]}"

#------------------------------------------------------------#
sh $SCRIPTS/custom_report2.sh

#------------------------------------------------------------#


for i in "${PXD[@]}"
do
  # echo "$i"
  Rscript $SCRIPTS/parser_argumented.R --PXD "$i"
done



Rscript $SCRIPTS/parser_argumented.R --PXD "PXD002211" 

#------------------------------------------------------------#
Rscript $SCRIPTS/make_output_table.R 












