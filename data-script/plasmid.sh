#! /usr/bin/env bash
#! /usr/bin/env bash

# Leave only one comment symbol on selected options
# Those with two commets will be ignored:
# The name to show in queue lists for this job:
##SBATCH -J script.sh

# Number of desired cpus (can be in any node):
#SBATCH --ntasks=1

# Number of desired cpus (all in same node):
##SBATCH --cpus=1

# Amount of RAM needed for this job:
#SBATCH --mem=2gb

# The time the job will be running:
#SBATCH --time=1-00:00:00

# To use GPUs you have to request them:
##SBATCH --gres=gpu:1

# If you need nodes with special features uncomment the desired constraint line:
# * to request only the machines with 80 cores and 2TB of RAM
##SBATCH --constraint=bigmem
# * to request only machines with 16 cores and 64GB with InfiniBand network
##SBATCH --constraint=cal
# * to request only machines with 24 cores and Gigabit network
##SBATCH --constraint=slim

# Set output and error files
#SBATCH --error=job.%J.err
#SBATCH --output=job.%J.out

# MAKE AN ARRAY JOB, SLURM_ARRAYID will take values from 1 to 100
##SARRAY --range=1-100

# To load some software (you can show the list with 'module avail'):
# module load software

PATH=~pedro/software/Sibelia/bin/:$PATH
export PATH
module load circos

query=$1   #plasmid sequence   #PATH:data-script/plasmid_sequence
subject=$2   #genome sequence   #PATH:plasmids/data-script/genomes_problem
out_put=$3    #PATH: plasmids/results

main_folder=`pwd`
mkdir -p $out_put/blast_plasmid_genomes
module load blast_plus/2.2.30+
genomes=( 'e_Pdp11_1' 'e_Shewanella_putrefaciens_SH12_micro1'  'e_Shewanella_putrefaciens_SH6_micro12' 'e_Shewanella_putrefaciens_SdM1'  'e_Shewanella_putrefaciens_SH16_micro22'  'e_Shewanella_putrefaciens_SH9_micro13' 'e_Shewanella_putrefaciens_SdM2'  'e_Shewanella_putrefaciens_SH4_micro9' )
plasmids=( 'plasmid_SH12'  'plasmid_SH4' )
for plasmid in "${plasmids[@]}"
do
	mkdir -p $out_put/blast_plasmid_genomes/$plasmid
	for genome in "${genomes[@]}"
	do  
	blastn -query $query/$plasmid'.txt' -subject $subject/$genome'.fasta' -outfmt '7 std qlen slen' > $out_put/blast_plasmid_genomes/$plasmid/blast_$plasmid_$genome
	grep -v '#' $out_put/blast_plasmid_genomes/$plasmid/blast_$plasmid_$genome | awk '{ if (($3>=80) && (($4/$13*100)>=30)) {print $0}}' > $out_put/blast_plasmid_genomes/$plasmid/blast_$plasmid_$genome'_filtre'
    sed -i "1i $plasmid $genome" $out_put/blast_plasmid_genomes/$plasmid/blast_$plasmid_$genome'_filtre'
    done
done
cd $out_put/blast_plasmid_genomes/ 
cat */*filtre > Total_blast
cd $main_folder
mkdir -p $out_put/sibelia_genomes_SH4_SH12
Sibelia -m 2000 -s fine $subject/e_Shewanella_putrefaciens_SH12_micro1.fasta  $subject/e_Shewanella_putrefaciens_SH4_micro9.fasta -o $out_put/sibelia_genomes_SH4_SH12
	cd $out_put/sibelia_genomes_SH4_SH12/circos
    circos -conf circos.conf -debug_group summary,timer -param image/radius=1500p > run.out 
	cd $main_folder
mkdir -p $out_put/sibelia_plasmid_SH4_SH12
Sibelia -m 2000 -s fine $query/plasmid_SH12.txt  $query/plasmid_SH4.txt -o $out_put/sibelia_plasmid_SH4_SH12
	cd out_put/sibelia_plasmid_SH4_SH12/circos
    circos -conf circos.conf -debug_group summary,timer -param image/radius=1500p > run.out 
	cd $main_folder


