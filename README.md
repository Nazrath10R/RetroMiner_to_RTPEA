# RetroMiner to RTPEA

Steps to retrieve data from RetroMiner and populate into MongoDB for RTPEA

## RetroMiner

The last script of RetroMiner is "Data_filtering.sh", which uses a custom version of PeptideShakers' ReportCLI to write out tables with the protein identification information we need for all proteins 

### Get RT data out - <span style="color:blue">*Apocrita*</span>

```
sh custom_report2.sh
```

this script runs the modified data export for PeptideShaker and outputs .txt files
loop requires a list of PXDs in a text file. write a way to automatically find the ones not parsed. 
(maybe using reanalysis log) 

run second part of the script for the filtration
awk commands filter RT protein lines out super fast and create LINE and HERV .txt files 

### Create output table - <span style="color:blue">*Apocrita*</span>

creates one output table with all results

```
Rscript parser_argumented.R --PXD "PXD00xxxx"
```

make new folder called final
move all filtered files into final folder

```
find . -name 'PXD*_parsed.txt' -exec mv -it ../final {} +
```

## visualise results - <span style="color:blue">*Apocrita*</span>

```
Rscript result_interpretation.R
```

### collate output table - <span style="color:blue">*Apocrita*</span>


```
Rscript make_output_table.R
```


## Table Data - <span style="color:blue">*DropBox*</span>

Table data

```
/data/results/
```

### add metadata - <span style="color:blue">*DropBox*</span>

```
Rscript adding_consequence_to_output_table.R
````

### convert results to json - <span style="color:blue">*DropBox*</span>

using example.json

```
Rscript convert_results_to_json_working_final.R
```

move all json files to new folder and put this script in there

```
python Fix_Json_ORF.py
```

move them out of the newly generated folder back out and delete generated folder 



## ProtVista data - <span style="color:blue">*DropBox*</span>

/variants/

using visualise_example_new.json

```
Rscript conversion_4.R
```

need to add a newly compiled PXD list


### merge into one file per protein - <span style="color:blue">*Apocrita*</span>

/ProtVista/results/

```
sh combine_protvista_json_files.sh
```

## ideogram data - <span style="color:blue">*DropBox*</span>

in data/variants/

using sequences from data/variants/sequences

```
Rscript ideogram.R
```


## bar chart data - <span style="color:blue">*Apocrita*</span>

on Apocrita /outputs/

```
du -sh *
```
use this to write all files into one file and call it sizes.txt

move to dropbox

make a matrix with sizes and PXDs
```
Rscript sizes.R
```

