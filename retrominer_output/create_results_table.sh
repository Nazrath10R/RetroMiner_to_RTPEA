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
echo -en "\033[34m"
echo "CREATE RESULTS TABLE FOR RETROMINER'S OUTPUT"
echo -en "\033[0m"
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
for i in "${PXD[@]}"
  do Rscript $SCRIPTS/parser_argumented.R --PXD "$i"
done
echo "added experimental design to results"

#------------------------------------------------------------#
#         collate all results in one output table            #
#------------------------------------------------------------#
echo 
if [ ! -d "$DATA/final" ]; 
  then mkdir $DATA/final
else
  mv $DATA/final $DATA/z_archive
  mv $DATA/z_archive/final "$DATA/z_archive/final.$(date)"
fi

# needs to overwite
find $DATA -name 'PXD*_parsed.txt' -exec mv -it $DATA/final {} \;
echo
Rscript $SCRIPTS/make_output_table.R --DIR "$DATA/final/"
echo
echo "results table created"

#------------------------------------------------------------#
#         collate all results in one output table            #
#------------------------------------------------------------#
echo 
Rscript $SCRIPTS/adding_consequence_to_output_table.R
echo

