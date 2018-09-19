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
BASE_DIR=/data/SBCS-BessantLab/naz/RetroMiner_to_RTPEA
RETROMINER=/data/SBCS-BessantLab/naz/pride_reanalysis

DIR=$BASE_DIR/src
SCRIPTS=$BASE_DIR/src/scripts

INPUT=$BASE_DIR/input/retrominer_results/
DATA=$INPUT/individual_results
META=$BASE_DIR/input/metadata
SIZES=$BASE_DIR/input/sizes

OUTPUT=$BASE_DIR/output

ARCHIVE=$BASE_DIR/z_archive
EXAMPLES=$BASE_DIR/example_files


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
sh $SCRIPTS/loading.sh 3

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

# mkdir individual_results
# mv PXD* individual_results/
echo
echo "added experimental design to results"
sh $SCRIPTS/loading.sh 3

#------------------------------------------------------------#
#         collate all results in one output table            #
#------------------------------------------------------------#
echo 
if [ ! -d "$INPUT/combined_results" ]; 
  then mkdir $INPUT/combined_results
else
  mv $INPUT/combined_results $ARCHIVE/results
  mv $ARCHIVE/results/combined_results "$ARCHIVE/results/combined_final.$(date)"
  mkdir $INPUT/combined_results
fi

# needs to overwite
find $DATA -name 'PXD*_parsed.txt' -exec mv -it $INPUT/combined_results {} \;
echo
echo
Rscript $SCRIPTS/02_make_output_table.R --DIR "$INPUT/combined_results/"
echo
echo "results table created"
sh $SCRIPTS/loading.sh 3

#------------------------------------------------------------#
#         collate all results in one output table            #
#------------------------------------------------------------#
echo 
Rscript $SCRIPTS/03_adding_consequence_to_output_table.R \
        --DATA "$INPUT" --META "$META" --SIZES "$SIZES"
echo
echo
echo "metadata added"
echo
sh $SCRIPTS/loading.sh 3

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
        --DATA "$INPUT" --EXAMPLES "$EXAMPLES" --OUTPUT "$OUTPUT"
echo
echo "converted table data to json"
echo
sh $SCRIPTS/loading.sh 3

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

#------------------------------------------------------------#
#               generate ProtVista json files                #
#------------------------------------------------------------#
echo 
if [ ! -d "$OUTPUT/protvista" ]; 
  then mkdir $OUTPUT/protvista
else
  mv $OUTPUT/protvista $ARCHIVE/protvista
  mv $ARCHIVE/protvista/protvista "$ARCHIVE/protvista/protvista.$(date)"
  mkdir $OUTPUT/protvista
fi

Rscript $SCRIPTS/06_conversion_4.R \
        --EXAMPLES "$EXAMPLES" --OUTPUT "$OUTPUT" --DATA "$PXD"

echo
echo "ProtVista json data generated"
echo

sh $SCRIPTS/loading.sh 3


#------------------------------------------------------------#
#               merge json files per protein                 #
#------------------------------------------------------------#
echo
sh $SCRIPTS/07_combine_protvista_json_files.sh $OUTPUT/protvista $EXAMPLES
echo
echo "combined json files per protein"
echo


#------------------------------------------------------------#
#                generate chromosome data                    #
#------------------------------------------------------------#
echo
if [ ! -d "$OUTPUT/chromosome" ]; 
  then mkdir $OUTPUT/chromosome
else
  mv $OUTPUT/chromosome $ARCHIVE/chromosome
  mv $ARCHIVE/chromosome/chromosome "$ARCHIVE/chromosome/chromosome.$(date)"
  mkdir $OUTPUT/chromosome
fi

Rscript $SCRIPTS/08_ideogram.R \
        --EXAMPLES "$EXAMPLES" --OUTPUT "$OUTPUT"
echo
echo "chromosome data generated"
echo
sh $SCRIPTS/loading.sh 3



#------------------------------------------------------------#
#                generate bar chart data                     #
#------------------------------------------------------------#
echo
if [ ! -d "$OUTPUT/size" ]; 
  then mkdir $OUTPUT/size
else
  mv $OUTPUT/size $ARCHIVE/size
  mv $ARCHIVE/size/size "$ARCHIVE/size/size.$(date)"
  mkdir $OUTPUT/size
fi

du -sh $RETROMINER/outputs/PXD* > $OUTPUT/size/sizes.txt

sh 09_sizes.sh








# Rscript 10_sizes.R








#### checkpoint
rm -r $ARCHIVE/results/*
rm -r $ARCHIVE/table/*
rm -r $ARCHIVE/protvista/*
rm -r $ARCHIVE/chromosome/*
rm -r $ARCHIVE/size/*
echo "archive cleared"
echo