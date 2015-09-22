# phase_everyone
Phase_hybrid_from_next_gen phases defined hybrids in your dataset. This phases all the samples in your next-gen dataset.

#How does it work, and what do you need?
For this program to work, you need to have a folder that contains:

-- fasta alignments (full alignments, not just SNPs. You also need a separate fasta file per locus, not one giant concatenated file) for the loci you want to use (with any missing samples padded out with Ns or ?s). If you are coming from pyRAD see the instructions at the bottom of the readme for converting your *.loci file to fasta.

-- phasing_everyone.sh

-- The R-scripts: onelining.R and split_samples.R scripts (although most of the code in onelining.R is similar to the eponymous script in Phase_hybrid_from_next_gen, they are a litle bit different so make sure you use the script from this repository)

-- Your phasing_settings file (see below - note, this file is slightly different to the one used by Phase_hybrid_from_next_gen).

You'll also need to have installed bwa, samtools, R and Java, and added these to your path. You'll also need to install GenomeAnalysisTK.jar (GATK) and picard.jar (picard), but we'll actually need the full pathway to these jars in the phasing_settings folder below.

#Phasing_settings file example
The shell script is using bwa, gatk, samtools and R to pull out the hybrid sample (R), do a reference-guided assembly (bwa, samtools) on your cleaned *.fastq.gz reads from your hybrid, and then calling variants/phasing these (gatk), before using the "new reference" to do the process again to get the other alleles for your hybrid.

To run this yourself you will need a file with the input settings named phasing_settings in the folder with your fasta sequences and the scripts. In this file, on each separate line in this order you will need:

Line 1: path to gatk

Line 2: path to picard

Line 3: paired or single, depending on your sequencing method

Line 4: the pathway to your F reads (or plain "reads" if single end). Substitute "$name" for the actual sample name wherever this occurs in the pathway to the reads

Line 5: the same thing for your R reads if you have paired sequence data

```
/home/a499a400/bin/GenomeAnalysisTK.jar
/home/a499a400/bin/picard/dist/picard.jar
paired
/home/a499a400/Kaloula/cleaned-reads/$name/split-adapter-quality-trimmed/$name-READ1.fastq.gz
/home/a499a400/Kaloula/cleaned-reads/$name/split-adapter-quality-trimmed/$name-READ2.fastq.gz
```

NB: Note the differences between this file and the one used in the Phase_hybrid_from_next_gen pipeline if you are familiar with that pipeline

#To run the script
bash phasing_everyone.sh

#Is the script running successfully?
The first few steps of phasing_everyone.sh are bash/R so it might not look like it is doing much using top/htop. To confirm it is actually running, check your directory: files corresponding to your sample names should be growing in size as the scripts syphon off the samples into them. After these first steps, you should see bwa/java running through top/htop.

#Coming from pyRAD
Your .loci file can be turned in a folder of fasta alignments using the scripts at: https://github.com/laninsky/Phase_hybrid_from_next_gen/tree/master/helper_scripts

#Suggested citation
This code was first published in: TBD

If you could cite the pub, and the progam as below, that would be lovely:

Alexander, A. 2015. phase_everyone v0.0.0. Available from https://github.com/laninsky/phase_everyone

#Version history
v0.0.0: still a work in progress
