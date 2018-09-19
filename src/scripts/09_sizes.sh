#!/bin/bash

# cd /data/SBCS-BessantLab/naz/pride_reanalysis/outputs
# ls -1 > sizes.txt

ls -1 $RETROMINER/outputs/ | grep "PXD*" > $OUTPUT/size/sizes.txt


# gsub old out

# PXD=PXD002211

# cd /data/SBCS-BessantLab/naz/pride_reanalysis/sizes
cd $OUTPUT/size

# output_to_convert2.txt

# FOLDERS=$(cat /data/SBCS-BessantLab/naz/pride_reanalysis/outputs/sizes.txt)
readarray -t FOLDERS < $OUTPUT/size/sizes.txt
COUNTER=${#FOLDERS[@]}
# COUNTER=6

for y in "${FOLDERS[@]}"
 do  
  # echo $y >> sizes.txt
  echo -en "\033[34m"
  # COUNTER=$[$COUNTER -1]
  COUNTER=$(($COUNTER - 1 ))
  # echo $y
  echo -en "\033[0m"

  wget -O ${y}_files.json https://www.ebi.ac.uk:443/pride/ws/archive/file/list/project/$y --no-check-certificate 2> files.out
  # jq '.list[] | select(.fileName | contains(".mgf") ) | .fileSize ' ${y}_files.json >> sizes.txt
  jq '.list[] | select(.fileName | contains(".mgf"| ".MGF") ) | .fileSize ' ${y}_files.json >> ${y}_size.txt
  rm ${y}_files.json
  echo "$COUNTER of ${#FOLDERS[@]} PXD size: $y"
done


# move all to 
# /Users/nazrathnawaz/Dropbox/PhD/retroelement_expression_atlas/data/sizes























