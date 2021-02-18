#!/bin/bash

mkdir -p filtered

for file in *.out

do

awk '$3 > 1000' $file > temp1.out

awk '$5 < 0.05' temp1.out > temp2.out

awk '$9 < 0.5' temp2.out > temp3.out

grep 'deletion' temp3.out > filtered/${file}_deletion.out

grep 'duplication' temp3.out > filtered/${file}_duplication.out

rm -rf temp1.out temp2.out temp3.out

done

#split the genome into overlapping bins:
module load StdEnv/2020 bedtools/2.29.2

bedtools makewindows -g v4.03_chrom_size.txt -w 200000 -s 10000 > v4.03.200kb.10kb.bed

bedtools intersect -a v4.03.200kb.10kb.bed -b only.genes.gon1.bed -F 1 -c -sorted > gon1CNV.density_200kb.10kb_bin.txt
