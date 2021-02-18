#!/bin/bash 

#SBATCH --account=rrg-mstrom
#SBATCH --time=51:00:00
#SBATCH -n 2
#SBATCH --ntasks-per-node=4
#SBATCH --mem=500G
#SBATCH --mail-user=maria.kyriakidou@mail.mcgill.ca
#SBATCH --mail-type=ALL

#define input sample and directories:
genome=adg2 #change this
data=/scratch/mariak7/Potato/${genome}
RefGenomeName=scratch/mariak7/Potato/RefGenome/potato_dm_v404_all_pm_un.fasta

#load tools
module load nixpkgs/16.09  intel/2016.4 load bwa/0.7.17 samtools/1.9 picard/2.18.9

cd ${data}

#index reference only once, then comment:
bwa index ${RefGenomeName}
samtools faidx ${RefGenomeName}

#for multiple genomes uncomment the following line:
#for genome in 
#do


#Alignment
bwa mem -t 20 ${RefGenomeName} ${genome}_1P.fq ${genome}_2P.fq > ${genome}_P_bwa.sam
bwa mem -t 20 ${RefGenomeName} ${genome}_U.fq > ${genome}_U_bwa.sam

#SAM to BAM conversion
samtools view -bS ${genome}_P_bwa.sam -o ${genome}_P_bwa.bam
samtools view -bS ${genome}_U_bwa.sam -o ${genome}_U_bwa.bam

#remove sam files
rm ${bwa_align}/*.sam

#sort and index BAM files
samtools sort ${genome}_P_bwa.bam -o sorted_${genome}_P_bwa.bam
samtools index sorted_${genome}_P_bwa.bam
samtools sort ${genome}_U_bwa.bam -o sorted_${genome}_U_bwa.bam
samtools index sorted_${genome}_U_bwa.bam

#mark duplicates witl Picard
java -jar $EBROOTPICARD/picard.jar MarkDuplicates INPUT=sorted_${genome}_P_bwa.bam OUTPUT=dedup_${genome}_P_bwa.bam METRICS_FILE=${genome}_P_metrics.txt
java -jar $EBROOTPICARD/picard.jar MarkDuplicates INPUT=sorted_${genome}_U_bwa.bam OUTPUT=dedup_${genome}_U_bwa.bam METRICS_FILE=${genome}_U_metrics.txt

#index bam files with samtools
samtools sort dedup_${genome}_P_bwa.bam -o sorted_dedup_${genome}_P_bwa.bam
samtools sort dedup_${genome}_U_bwa.bam -o sorted_dedup_${genome}_U_bwa.bam
samtools index sorted_dedup_${genome}_P_bwa.bam
samtools index sorted_dedup_${genome}_U_bwa.bam


samtools view -bhf 2 sorted_dedup_${genome}_P_bwa.bam -o prop_orient_dedup_${genome}_P_bwa.bam
samtools view -bhF 2 sorted_dedup_${genome}_P_bwa.bam -o unprop_orient_dedup_${genome}_P_bwa.bam
samtools view -b -F 4 sorted_dedup_${genome}_P_bwa.bam -o aligned_prop_orient_dedup_${genome}_P_bwa.bam
samtools view -b -f 4 sorted_dedup_${genome}_P_bwa.bam -o unaligned_dedup_${genome}_P_bwa.bam

samtools view -b -F 4 sorted_dedup_${genome}_U_bwa.bam -o aligned_dedup_${genome}_U_bwa.bam
samtools view -b -f 4 sorted_dedup_${genome}_U_bwa.bam -o unaligned_dedup_${genome}_U_bwa.bam

samtools merge total.${genome}.aligned.bwa.bam aligned_prop_orient_dedup_${genome}_P_bwa.bam aligned_dedup_${genome}_U_bwa.bam
samtools merge total.${genome}.unaligned.bwa.bam unprop_orient_dedup_${genome}_P_bwa.bam unaligned_dedup_${genome}_P_bwa.bam unaligned_dedup_${genome}_U_bwa.bam

#filter based on quality >20 and concatenate the bam files:
samtools view -bhq 20 total.${genome}.aligned.bwa.bam -o q20.total.${genome}.aligned.bwa.bam
samtools merge unaligned_paired.${genome}.bam unprop_orient_dedup_${genome}_P_bwa.bam unaligned_dedup_${genome}_P_bwa.bam
samtools rmdup -S unaligned_paired.${genome}.bam unaligned_rmdup_paired.${genome}.bam
samtools rmdup -s unaligned_dedup_${genome}_U_bwa.bam unaligned_rmdup_dedup_${genome}_U_bwa.bam

#done
