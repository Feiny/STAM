Sequencing Trait-Associated Mutations (STAM)
============================================
### A straightforward method to identify the gene for a trait with phenotyped mutants
![图1-STAM](https://user-images.githubusercontent.com/7081243/208272511-42718937-3272-4729-9759-3fcd483840e2.jpg)
-----
### 1) de novo transcriptome reconstruction
The raw sequencing reads (PacBio subreads) were processed by ccs to generate polished circular consensus sequence (CCS reads), then used for primer removal and demultiplexing using lima to generate full-length reads; The full-length reads were further refined by trimming PolyA tail and artificial concatemer using IsoSeq3 (https://github.com/PacificBiosciences/IsoSeq) to generate full-length, non-concatemer reads (FLNC reads); Two SMRT cells FLNC reads were merged and clustered to generate polished transcript isoforms (HQ transcripts). 
##### a. Generate CCS reads
``` bash
ccs P10-46-1.subreads.0.bam P10-46-1.ccs.bam
ccs P10-46-2.subreads.1.bam P10-46-2.ccs.bam
```
##### b. Generate full-length reads
``` bash
lima --isoseq --dump-clips P10-46-1.ccs.bam primers.fasta P10-46-1.fl.bam --log-file P10-46-1.fl.bam.log
lima --isoseq --dump-clips P10-46-2.ccs.bam primers.fasta P10-46-2.fl.bam --log-file P10-46-2.fl.bam.log
```
##### c. Generate FLNC reads
``` bash
isoseq3 refine --require-polya P10-46-1.fl.primer_5p--primer_3p.bam primers.fasta P10-46-1.flnc.bam
isoseq3 refine --require-polya P10-46-2.fl.primer_5p--primer_3p.bam primers.fasta P10-46-2.flnc.bam
```
##### d. Generate HQ transcripts
``` bash
ls P10-46*.flnc.bam > flnc.fofn
isoseq3 cluster --verbose --use-qvs flnc.fofn P10-46.clustered.bam
```
-----
### 2) Construction of final transcriptome reference
HQ transcripts were mapped to the genome reference of *Pst* isolate 134E (DOI:10.1094/MPMI-09-21-0236-A) using Minimap2 (https://github.com/lh3/minimap2) to identify the stripe rust transcripts introduced during sampling and RNA extracting. After removing stripe rust transcripts, transposable elements were masked using Repeatmasker (http://www.repeatmasker.org) based on the repeat library Dfam3.6 (https://www.dfam.org). After filtration and masking, masked HQ transcripts were mapped to wheat Chinese Spring genome reference IWGSC RefSeq v2.1 (https://www.wheatgenome.org) using Minimap2 and generated aligned HQ transcripts. To collapse redundant isoforms caused by 5’ RNA degradation, Cupcake and Cogent (https://github.com/Magdoll) were used to generate unique transcripts for well-mapped reads and unmapped reads, respectively. Then, two parts of unique transcripts were merged to generate the final transcript set using CD-HIT-EST with the sequence identity threshold at 100% (-c 1).
##### a. Generate fished HQ transcripts
``` bash
minimap2 -t 8 -Y -R "@RG\tID:Sample\tSM:hs\tLB:ga\tPL:PacBio" --MD -ax splice:hq -uf --secondary=no Pst134e.reference.fasta P10-46.clustered.hq.fasta >aligned.Pst134e.sam
grep -v '@' aligned.Pst134e.sam | awk '$3!="*"{print}' | cut -f 1 | sort | uniq >aligned.Pst134e.id ##655
```
##### b. Generate masked HQ transcripts
``` bash
RepeatMasker -gff -nolow -no_is -xsmall -pa 24 P10-46.clustered.hq.fasta
grep -v '^#' P10-46.clustered.hq.fasta.out.gff | cut -f 1 | sort -t "/" -k 2 -n >P10-46.clustered.hq.fasta.out.id #1706
```
##### c. Generate aligned HQ transcripts
``` bash
minimap2 -t 24 -Y -R "@RG\tID:Sample\tSM:hs\tLB:ga\tPL:PacBio" --MD -ax splice:hq -uf --secondary=no iwgsc_refseqv2.1_assembly.mmi P10-46.clustered.hq.fished.fasta -o aligned.RefSeq2.1.sam
sort -k 3,3 -k 4,4n aligned.RefSeq2.1.sam >aligned.RefSeq2.1.sorted.sam
collapse_isoforms_by_sam.py --input P10-46.clustered.hq.fished.fasta -s aligned.RefSeq2.1.sorted.sam --dun-merge-5-shorter -o clustered
get_abundance_post_collapse.py clustered.collapsed P10-46.cluster_report.csv
filter_by_count.py --min_count 1 --dun_use_group_count clustered.collapsed
filter_away_subset.py clustered.collapsed.min_fl_1



```
##### d. Generate final transcript set
``` bash

```
---
### 3) Variant calling
Adapter trimming and quality filtration of RNA-Seq reads of seven Yr10-defective mutants and resistant cultivar Moro were firstly performed using fastp (https://github.com/OpenGene/fastp), and the clean data was then mapped to the final transcript set obtained in the previous step using STAR (https://github.com/alexdobin/STAR). Potential PCR duplicates reads were further removed using Picard (https://broadinstitute.github.io/picard) and generated analysis ready reads. SNPs were identified by the HaplotypeCaller tool of GATK v4.2 in GVCF mode (https://gatk.broadinstitute.org). Then, all the per-sample GVCFs were gathered and passed to GATK GenotypeGVCFs for joint calling. Variants were preliminarily filtered using GATK VariantFiltration with the parameter “DP < 5 || FS > 60.0 || MQ < 40.0 || QD < 2.0” and generated analysis-ready SNPs. 
##### a. Adapter trimming and quality filtration of RNA-Seq data
``` bash
for sample in $(cat sample.id)
do
    $fastp --thread 2 \
        --in1 ./RNA-Seq_Batch2/$name.R1.out.fastq.gz \
        --in2 ./RNA-Seq_Batch2/$name.R2.out.fastq.gz \
        --out1 ./1.cleandata/$name.R1.clean.fq.gz \
        --out2 ./1.cleandata/$name.R2.clean.fq.gz \
        -q 3 \
        -u 50 \
        --length_required 150 \
        -h ./1.cleandata/$name.html \
        -j ./1.cleandata/$name.json
done
```
##### b. Mapping
``` bash
for sample in $(cat sample.id)
do
    $STAR --runThreadN 24 \
        --genomeDir $refdir \
        --readFilesIn $name.R1.clean.fq.gz $name.R2.clean.fq.gz \
        --readFilesCommand zcat \
        --outSAMtype BAM SortedByCoordinate \
        --limitBAMsortRAM 100000000000 \
        --outFileNamePrefix $name. \
        --outSAMmapqUnique 60

    java -XX:ParallelGCThreads=24 -jar $picard \
        AddOrReplaceReadGroups \
        --INPUT $name.Aligned.sortedByCoord.out.bam \
        --OUTPUT $name.RG.bam \
        --SORT_ORDER coordinate \
        --MAX_RECORDS_IN_RAM 1000000 \
        --RGLB $name \
        --RGPL ILLUMINA \
        --RGPU BARCODE \
        --RGSM $name
    
    java -XX:ParallelGCThreads=24 -jar $picard \
        MarkDuplicates \
        --INPUT $name.RG.bam \
        --OUTPUT $name.dedupped.bam \
        --CREATE_INDEX true \
        --VALIDATION_STRINGENCY SILENT \
        --METRICS_FILE $name.metrics
    
    #rm -rf $name.Aligned.sortedByCoord.out.bam $name.Log.out $name.Log.progress.out $name.SJ.out.tab $name.RG.bam $name.metrics
done
```
##### c. Variant calling
``` bash
for sample in $(cat sample.id)
do
    $gatk --java-options -Xmx5G HaplotypeCaller -R $ref -I $name.dedupped.bam -OVI false -ERC GVCF -O $name.g.vcf.gz 1>$name.hc.log 2>&1
    $gatk --java-options -Xmx5G IndexFeatureFile -I $name.g.vcf.gz
done

$gatk --java-options -Xmx10G CombineGVCFs \
    -R $ref \
    --variant M110.g.vcf.gz \
    --variant M160.g.vcf.gz \
    --variant M16.g.vcf.gz \
    --variant M168.g.vcf.gz \
    --variant M19.g.vcf.gz \
    --variant M38.g.vcf.gz \
    --variant M62.g.vcf.gz \
    --variant Moro.g.vcf.gz \
    -O YrNAM.cohort.g.vcf.gz

$gatk --java-options -Xmx10G GenotypeGVCFs \
    -R $ref \
    -V YrNAM.cohort.g.vcf.gz \
    -O YrNAM.output.vcf.gz

#Variant filtering
$gatk --java-options -Xmx10G VariantFiltration \
    -R $ref \
    -V YrNAM.output.vcf.gz \
    -O YrNAM.output.filtered.vcf.gz \
    --filter-name "GATK_Filter" \
    --filter-expression "DP < 5.0 || FS > 60.0 || MQ < 40.0 || QD < 2.0 "
```
-----
### 4) Mutation filtering
SNPs that meet all of the following criterias were further retained in the result of final mutations: a. read depth ≥ 5; b. homozygous sites; c. G to A and C to T mutations; d. independent mutations among all seven Yr10-defective mutants; e. No. of SNPs per transcript in each mutant = 1; f. missing rate ≤ 60%. 
``` bash
perl select_homo.pl YrNAM.output.filtered.vcf > YrNAM.homo.txt #filtration criterias: a. read depth ≥ 5; b. homozygous sites;
perl select_mutation1.pl YrNAM.homo.txt > YrNAM.mutation1.txt #filtration criterias: c. G to A and C to T mutations; d. independent mutations among all seven Yr10-defective mutants;
perl select_mutation2.pl YrNAM.mutation1.txt > YrNAM.mutation2.txt #filtration criterias: e. No. of SNPs per transcript in each mutant = 1;
perl filter_mutation.pl YrNAM.mutation2.txt > YrNAM.mutation2.txt #filtration criterias: f. missing rate ≤ 60%; mutation sites absent in Moro were also removed;

```
