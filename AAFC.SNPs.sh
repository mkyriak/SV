#!/bin/bash
#SBATCH --account=rpp-mstrom
#SBATCH --time=150:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=12
#SBATCH --mem=20g
#SBATCH --mail-user=maria.kyriakidou@mail.mcgill.ca
#SBATCH --mail-type=ALL

#load tools
module load StdEnv/2020 freebayes/1.2.0

#set input directory
AAFC=/home/mariak7/scratch/Potato/AAFC

cd ${AAFC};


#collect the SNPs in the genomes:
for genome in 12625-02 08675-21 11379-03 12120-03 H412-1 10908-06 W5281-2 DW84-1457
do
       cd ${AAFC}/${genome}/RH;
       freebayes -f ../../RH-ref/RH89-039-16_potato_genome_assembly.v3.fa aligned_prop_orient_dedup_RH_${genome}_bwa.bam > ${genome}.RH.var.vcf;
       cd ../..;
done

export PATH=/project/6006724/mariak7/software/vcflib/:$PATH

for genome in 10908-06  W5281-2 oka15 12625-02 08675-21 11379-03 12120-03 H412-1 DW84-1457
do
       cd ${AAFC}/${genome}/RH;
       vcffilter -f "DP > 4" ${genome}.RH.var.vcf > ${genome}.DP4.total.q20;
       vcffilter -f "QUAL > 20" ${genome}.DP4.total.q20 > ${genome}.Q20.DP4.total.q20;
       vcffilter -f "MQM > 20" ${genome}.Q20.DP4.total.q20 > ${genome}.MQM20.Q20.DP4.total.q20;
       vcffilter -f "MQMR > 20 " ${genome}.MQM20.Q20.DP4.total.q20 > ${genome}.MQMR20.MQM20.Q20.DP4.total.q20;
       vcffilter -f "SAF > 0 & SAR > 0" ${genome}.MQMR20.MQM20.Q20.DP4.total.q20 > ${genome}.RH.SAF.SAR.q20.MQMR20.MQM20.Q20.DP4.total.q20.var.vcf;
       rm -rf ${genome}.DP4.* ${genome}.Q20.* ${genome}.MQM*; #temp.* ${genome}.ST403ch01_*
done
