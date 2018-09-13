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
# sh population_script.sh
#============================================================#

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# ssh apoc5
# R version to use - 3.4.3
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#


echo
DIR=/data/SBCS-BessantLab/naz/RetroMiner_to_RTPEA/retrominer_output
DATA=/data/SBCS-BessantLab/naz/RetroMiner_to_RTPEA/retrominer_output/results
SCRIPTS=/data/SBCS-BessantLab/naz/RetroMiner_to_RTPEA/retrominer_output/scripts
OUTPUT=/data/SBCS-BessantLab/naz/RetroMiner_to_RTPEA/output_data
ARCHIVE=/data/SBCS-BessantLab/naz/RetroMiner_to_RTPEA/z_archive
META=/data/SBCS-BessantLab/naz/RetroMiner_to_RTPEA/retrominer_output/input_data/metadata
SIZES=/data/SBCS-BessantLab/naz/RetroMiner_to_RTPEA/retrominer_output/input_data/sizes

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
echo
for i in "${PXD[@]}"
  do Rscript $SCRIPTS/parser_argumented.R \
              --PXD "$i" --DIR "$DATA"
done
echo
echo "added experimental design to results"

#------------------------------------------------------------#
#         collate all results in one output table            #
#------------------------------------------------------------#
echo 
if [ ! -d "$DATA/final" ]; 
  then mkdir $DATA/final
else
  mv $DATA/final $ARCHIVE/results
  mv $ARCHIVE/results/final "$ARCHIVE/results/final.$(date)"
  mkdir $DATA/final
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
Rscript $SCRIPTS/adding_consequence_to_output_table.R \
        --DATA "$DATA" --META "$META" --SIZES "$SIZES"
echo
echo
echo "metadata added"
echo


#------------------------------------------------------------#
#           convert output table to json files               #
#------------------------------------------------------------#
echo 
if [ ! -d "$OUTPUT/table" ]; 
  then mkdir $OUTPUT/table
else
  mv $OUTPUT/table $ARCHIVE/table
  mv $ARCHIVE/table/table "$ARCHIVE/table/table.$(date)"
  mkdir $OUTPUT/table
fi

Rscript $SCRIPTS/convert_results_to_json_working.R
echo
echo "converted table data to json"
echo
 

#------------------------------------------------------------#
#                     fix json files                         #
#------------------------------------------------------------#

# copy this script into that folder
cp $SCRIPTS/Fix_Json_ORF.py $OUTPUT/table

cd $OUTPUT/table
python Fix_Json_ORF.py

# maybe archive it instead of deleting
find $OUTPUT/table -maxdepth 1 -name '*.jSON' -delete

# move all files up by one directory
mv $OUTPUT/table/output/* $OUTPUT/table/

rmdir output
rm Fix_Json_ORF.py

cd $DIR

echo
echo "fixed json files"
echo




