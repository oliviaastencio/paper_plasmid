#! /usr/bin/env bash

shewanella_csv=$1  #all shewanella genomes from https://www.ncbi.nlm.nih.gov/genome/browse/#!/prokaryotes/13542/prokaryotes

grep "plasmid" $shewanella_csv | tr ',' '\t'| cut -f 16 | tr '"' '\t'| cut -f 2 > plasmid_link
# We online need the genomic.fna.gz file 

file="plasmid_link"
while IFS= read -r line
do
    wget "$line/*1_genomic.fna.gz" 
    wget "$line/*2_genomic.fna.gz" 
done < "$file"