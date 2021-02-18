#!/bin/bash 
#SBATCH --account=rrg-mstrom
#SBATCH --time=15:40:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem=10G
#SBATCH --mail-user=maria.kyriakidou@mail.mcgill.ca
#SBATCH --mail-type=ALL

#load tools:
module load nixpkgs/16.09  gcc/8.3.0 cnvnator/0.4.1

input_dir=/home/mariak7/scratch/Potato/AAFC/10908-06

cd ${input_dir}

ref=/home/mariak7/scratch/Potato/AAFC/oka15/pseudomolecules

mkdir cnvnator;

for i in {01..12};
do
        # Extract Read mapping:
        cnvnator -root chr${i}.root 100kb.10908-06.root -tree aligned_prop_orient_dedup_10908-06_bwa.bam -chrom chr${i};
        #Generate Histogram:
        cnvnator -root chr${i}.root 100kb.10908-06.root -his 100 -d ${ref};
        #Calculate statistics:
        cnvnator -root chr${i}.root 100kb.10908-06.root -stat 100;
        #Partition:
        cnvnator -root chr${i}.root 100kb.10908-06.root -partition 100;
        #Call CNVs:
        cnvnator -root chr${i}.root 100kb.10908-06.root -call 100 > call.chr${i}.100kb.10908-06.out;
done

cd cnvnator

./do.filter.sh
