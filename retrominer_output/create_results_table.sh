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
echo
DIR=/data/SBCS-BessantLab/naz/RetroMiner_to_RTPEA/retrominer_output
DATA=/data/SBCS-BessantLab/naz/RetroMiner_to_RTPEA/retrominer_output/results
SCRIPTS=/data/SBCS-BessantLab/naz/RetroMiner_to_RTPEA/retrominer_output/scripts
cd $DIR
echo "CREATE RESULTS TABLE FOR RETROMINER'S OUTPUT"
#------------------------------------------------------------#
#                    create a PXD list                       #
#------------------------------------------------------------#
echo
## get all PXDs to parse 
Rscript $SCRIPTS/pxd_statuses.R
echo
readarray -t PXD < $DIR/pxd_list.txt
echo "PXD list created"
# echo "${PXD[*]}"
echo
#------------------------------------------------------------#
#             run custom PeptideShaker export                #
#------------------------------------------------------------#
echo "start filtration"
# sh $SCRIPTS/custom_report2.sh
echo "filtration completed"
#------------------------------------------------------------#
#            add experimental design to results              #
#------------------------------------------------------------#
echo
# for i in "${PXD[@]}"
#   do Rscript $SCRIPTS/parser_argumented.R --PXD "$i"
# done
echo "added experimental design to results"
#------------------------------------------------------------#
#         collate all results in one output table            #
#------------------------------------------------------------#
echo 
if [ ! -d "$DATA/final" ]; 
  then mkdir $DATA/final
fi

# needs to overwite
find $DATA -name 'PXD*_parsed.txt' -exec mv -it $DATA/final {} \;
echo
Rscript $SCRIPTS/make_output_table.R --DIR "$DATA/final/"
echo "results table created"




