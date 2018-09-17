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
# sh population_script.sh ARGS
# sh src/population_script.sh
#============================================================#

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# ssh apoc5
# R version to use - 3.4.3
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#



## Set up all path variables
WD=/data/SBCS-BessantLab/naz/RetroMiner_to_RTPEA

DIR=$WD/src
SCRIPTS=$WD/src/scripts

DATA=$WD/input/retrominer_results/individual_results
META=$WD/input/metadata
SIZES=$WD/input/sizes

OUTPUT=$WD/output

ARCHIVE=$WD/z_archive
EXAMPLES=$WD/example_files

echo
cd $DIR
echo -en "\033[34m"
echo "CREATE RESULTS TABLE FOR RETROMINER'S OUTPUT"
echo -en "\033[0m"
#------------------------------------------------------------#
#                    create a PXD list                       #
#------------------------------------------------------------#
echo
## get all PXDs to parse 
Rscript $SCRIPTS/00_pxd_statuses.R --DIR "$DIR"
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
COUNTER=0

for i in "${PXD[@]}"
  do 
  COUNTER=$(($COUNTER + 1 ))
  echo "$COUNTER of ${#PXD[@]}"

  Rscript $SCRIPTS/01_parser_argumented.R \
              --PXD "$i" --DIR "$DATA"
done

echo
mkdir individual_results
mv PXD* individual_results/
echo
echo "added experimental design to results"

#------------------------------------------------------------#
#         collate all results in one output table            #
#------------------------------------------------------------#
echo 
if [ ! -d "$DATA/combined_results" ]; 
  then mkdir $DATA/combined_results
else
  mv $DATA/combined_results $ARCHIVE/results
  mv $ARCHIVE/results/combined_results "$ARCHIVE/results/combined_final.$(date)"
  mkdir $DATA/combined_results
fi

# needs to overwite
find $DATA -name 'PXD*_parsed.txt' -exec mv -it $DATA/combined_results {} \;
echo
echo
Rscript $SCRIPTS/02_make_output_table.R --DIR "$DATA/combined_results/"
echo
echo "results table created"


#------------------------------------------------------------#
#         collate all results in one output table            #
#------------------------------------------------------------#
echo 
Rscript $SCRIPTS/03_adding_consequence_to_output_table.R \
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

Rscript $SCRIPTS/04_convert_results_to_json_working.R \
        --DATA "$DATA" --EXAMPLES "$EXAMPLES" --OUTPUT "$OUTPUT"
echo
echo "converted table data to json"
echo
 

#------------------------------------------------------------#
#                     fix json files                         #
#------------------------------------------------------------#

# copy this script into that folder
cp $SCRIPTS/05_Fix_Json_ORF.py $OUTPUT/table

cd $OUTPUT/table
python 05_Fix_Json_ORF.py

# maybe archive it instead of deleting
find $OUTPUT/table -maxdepth 1 -name '*.jSON' -delete

# move all files up by one directory
mv $OUTPUT/table/output/* $OUTPUT/table/

rmdir output
rm 05_Fix_Json_ORF.py

cd $DIR

echo
echo "fixed json files"
echo

rm -r $ARCHIVE/results/*
rm -r $ARCHIVE/table/*

