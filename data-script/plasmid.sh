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
subject=$2     #genome sequence   #PATH:plasmids/data-script/genomes_problem
plasmid_NCBI=$3  #shewanella plasmid sequence
out_put=$4    #PATH: plasmids/results

main_folder=`pwd`
mkdir -p $out_put/blast_plasmid_genomes
module load blast_plus/2.2.30+
genomes=( 'e_Pdp11_1' 'e_Shewanella_putrefaciens_SH12_micro1'  'e_Shewanella_putrefaciens_SH6_micro12' 'e_Shewanella_putrefaciens_SdM1'  'e_Shewanella_putrefaciens_SH16_micro22'  'e_Shewanella_putrefaciens_SH9_micro13' 'e_Shewanella_putrefaciens_SdM2'  'e_Shewanella_putrefaciens_SH4_micro9' )
plasmids_shewanella_NCBI=( 'GCF_000215895.1_ASM21589v1_genomic'   'GCF_003957745.1_ASM395774v1_genomic' 'GCF_000014665.1_ASM1466v1_genomic'   'GCF_002209245.2_ASM220924v2_genomic'  'GCF_006494715.1_ASM649471v1_genomic' 'GCF_000015845.1_ASM1584v1_genomic'  'GCF_002216875.1_ASM221687v1_genomic'  'GCF_009846595.1_ASM984659v1_genomic' 'GCF_000017325.1_ASM1732v1_genomic'   'GCF_002836075.1_ASM283607v1_genomic'  'GCF_011765625.1_ASM1176562v1_genomic' 'GCF_000018765.1_ASM1876v1_genomic'   'GCF_002836135.1_ASM283613v1_genomic'  'GCF_016757755.1_ASM1675775v1_genomic' 'GCF_000021665.1_ASM2166v1_genomic'   'GCF_002836795.1_ASM283679v1_genomic' 'GCF_000146165.2_ASM14616v2_genomic'  'GCF_003028295.1_ASM302829v1_genomic' 'GCF_000178875.2_ASM17887v2_genomic'  'GCF_003427415.1_ASM342741v1_genomic' 'GCF_000203935.1_ASM20393v1_genomic'  'GCF_003721455.1_ASM372145v1_genomic' )
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
    for plasmid_sequence in "${plasmids_shewanella_NCBI[@]}"
    do 
    	blastn -query $query/$plasmid'.txt' -subject $plasmid_NCBI/$plasmid_sequence'.fna' -outfmt '7 std qlen slen' >  $out_put/blast_plasmid_NCBI/$plasmid_sequence'_'$plasmid
        grep -v '#' $out_put/blast_plasmid_NCBI/$plasmid_sequence'_'$plasmid | awk '{ if (($3>=50) && (($4/$13*100)>=4)) {print $0}}' > $out_put/blast_plasmid_NCBI/$plasmid_sequence'_'$plasmid'_filtre'
    done
done
cat $out_put/blast_plasmid_genomes/*/*filtre > $out_put/blast_plasmid_genomes/Total_blast
cat $out_put/blast_plasmid_NCBI/*filtre > $out_put/blast_plasmid_NCBI/Total_blast
mkdir -p $out_put/sibelia_genomes_SH4_SH12
Sibelia -m 2000 -s fine $subject/e_Shewanella_putrefaciens_SH12_micro1.fasta  $subject/e_Shewanella_putrefaciens_SH4_micro9.fasta -o $out_put/sibelia_genomes_SH4_SH12
	cd $out_put/sibelia_genomes_SH4_SH12/circos
    circos -conf circos.conf -debug_group summary,timer -param image/radius=1500p > run.out 
cd $main_folder
mkdir -p $out_put/sibelia_plasmid_SH4_SH12
Sibelia -m 2000 -s fine $query/plasmid_SH12.txt  $query/plasmid_SH4.txt -o $out_put/sibelia_plasmid_SH4_SH12
	cd $out_put/sibelia_plasmid_SH4_SH12/circos
    circos -conf circos.conf -debug_group summary,timer -param image/radius=1500p > run.out 
cd $main_folder