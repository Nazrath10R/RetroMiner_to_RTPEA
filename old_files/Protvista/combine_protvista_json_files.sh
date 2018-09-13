#!/bin/bash

DIR="/Users/nazrathnawaz/Dropbox/PhD/retroelement_expression_atlas/RetroMiner_to_RTPEA/Protvista/results"
cd $DIR

# loop for both LINE-1 proteins
PROT=(1p 2p)

for i in "${PROT[@]}"
do 
  # seperate files into protein folders
  mkdir ORF$i
  mv ./*ORF$i*jSON ORF$i/

  FILES=(`ls ./ORF$i/ -1`)
  touch ORF$i/combined_ORF$i.jSON

  # parse features from each file into a combined file per protein
  cd ORF$i
  for j in "${FILES[@]}"
    do jq '.features' $j >> combined_ORF$i.jSON
  done

  # use slurping to add commas appropriately after square brackets
  jq -s . combined_ORF$i.jSON > all_features_ORF$i.json
  sed -i 's/\(\[\|\]\)//g' all_features_ORF$i.json   # remove all square brackets
  cd ..

  # add headers and sequence and finalise json structure
  cat ../orf${i}_head.json > complete_ORF$i.jSON
  cat ORF$i/all_features_ORF$i.json >> complete_ORF$i.jSON
  echo "]}" >> complete_ORF$i.jSON

  # prettify json structure
  jq '.' complete_ORF$i.jSON > final_ORF$i.jSON

  # delete files
  rm complete_ORF$i.jSON
  rm ORF$i/all_features_ORF$i.json
  rm ORF$i/combined_ORF$i.jSON
  
done











# cd ORF1p

# # use slurping to add commas appropriately after square brackets
# # jq -s . combined_ORF1p.jSON > new.json
# # sed -i 's/\(\[\|\]\)//g' new.json   # remove all square brackets
# # cd ..

# # add headers and sequence and finalise json structure
# cat ../orf1p_head.json > final_ORF1p.jSON
# cat ORF1p/new.json >> final_ORF1p.jSON
# echo "]}" >> final_ORF1p.jSON

# jq '.' final_ORF1p.jSON > final_ORF1p.jSON



















# grep ""

# jq '.' combined_ORF1p.jSON
# echo "][" | grep -Eo "[][ a-z]+"

# jq -r '[.]' combined_ORF1p.jSON


# sed 's/\[/,/g' combined_ORF1p.jSON
# sed 's/\]//g' combined_ORF1p.jSON

  # printf "%s\n" "${FILES[@]}"




  # echo $i 
  # echo $'\n'


# jq '.features' PXD000944_variant_ORF1p_HS_116.jSON >> new.jSON
# echo "COMMA" >> new.jSON






