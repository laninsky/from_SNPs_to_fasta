# phase_everyone
Phase_hybrid_from_next_gen phases defined hybrids in your dataset. In comparison, this pipeline phases all the samples in your next-gen dataset. You will end up with two fasta files per individual containing the phased alleles (the first contains allele one for all the loci, and the other contains allele two for all the loci). This pipeline assumes you only have diploid individuals. 

#How does it work, and what do you need?
For this program to work, you need to have a folder that contains:

-- fasta alignments (full alignments, not just SNPs. You also need a separate fasta file per locus, not one giant concatenated file) for the loci you want to use (with any missing samples padded out with Ns or ?s). If you are coming from pyRAD see the instructions at the bottom of the readme for converting your *.loci file to fasta. Any hyphens "-" will be stripped from your sample names and loci names, so please be aware of this.

-- phase_everyone.sh

-- The R-scripts: onelining.R and split_samples.R scripts (although most of the code in onelining.R is similar to the eponymous script in Phase_hybrid_from_next_gen, they are a litle bit different so make sure you use the script from this repository)

-- Your phasing_settings file (see below - note, this file is also slightly different to the one used by Phase_hybrid_from_next_gen).

You'll need to have installed bwa, samtools, R and Java, and added these to your path. You'll also need to install GenomeAnalysisTK.jar (GATK) and picard.jar (picard), but we'll actually need the full pathway to these jars in the phasing_settings folder below.

#Phasing_settings file example
The shell script is using bwa, gatk, samtools and R to pull out your samples (R), do a reference-guided assembly (bwa, samtools) on your cleaned *.fastq.gz reads from your samples, and then calling variants/phasing these (gatk), before using the "new reference" to do the process again to get the other alleles for each of your samples. The program will strip any hyphens "-" from your sample names and loci names, so please be aware of this.

To run phase_everyone, you will need a file with the input settings named phasing_settings in the folder with your fasta sequences and the scripts. In this file, on each separate line, in this order, you will need:

Line 1: path to gatk

Line 2: path to picard

Line 3: paired or single, depending on your sequencing method

Line 4: the pathway to your 'cleaned' F reads (or just your cleaned reads if single end). Substitute "${name}" for the actual sample name wherever this occurs in the pathway to the reads. This program expects the name of the reads to match the name of the samples in the fasta files, and for the pathway to the reads to be standard across your samples.

Line 5: the same thing for your 'cleaned' R reads if you have paired sequence data

```
/home/a499a400/bin/GenomeAnalysisTK.jar
/home/a499a400/bin/picard/dist/picard.jar
paired
/home/a499a400/Kaloula/cleaned-reads/${name}/split-adapter-quality-trimmed/${name}-READ1.fastq.gz
/home/a499a400/Kaloula/cleaned-reads/${name}/split-adapter-quality-trimmed/${name}-READ2.fastq.gz
```

NB: Note the differences between this file and the one used in the Phase_hybrid_from_next_gen pipeline, if you are familiar with that pipeline

#To run the script
bash phase_everyone.sh

#Is the script running successfully?
The first few steps of phase_everyone are bash/R so it might not look like it is doing much using top/htop. To confirm it is actually running, check your directory: files corresponding to your sample names should be growing in size as the scripts syphon off the samples into them. After these first steps, you should see bwa/java running through top/htop.

#Coming from pyRAD
Your .loci file can be turned in a folder of fasta alignments using the scripts at: https://github.com/laninsky/Phase_hybrid_from_next_gen/tree/master/helper_scripts

#What if I have already got *.bam files together for my samples?
You will need to tweak the phase_everyone.sh file to target your *.bam files to begin with instead. Check out the example_bam folder for an example of this. You'll still need the other scripts mentioned above.

#Suggested citation
This code was first published in: TBD

If you could cite the pub, and the progam as below, that would be lovely:

Alexander, A. 2015. phase_everyone v0.0.0. Available from https://github.com/laninsky/phase_everyone

This pipeline also wouldn't be possible without the programs listed below. Please cite them as well:

R: R Core Team. 2015. R: A language and environment for statistical computing. URL http://www.R-project.org/. R Foundation for Statistical Computing, Vienna, Austria. https://www.r-project.org/

bwa: See citation info at: http://bio-bwa.sourceforge.net/bwa.shtml#13 and Li, H. "Toward better understanding of artifacts in variant calling from high-coverage samples." Bioinformatics (Oxford, England) 30, no. 20 (2014): 2843.

samtools: See citation info at: http://www.htslib.org/doc/#manual-pages

picard: http://broadinstitute.github.io/picard/

GATK: See citation info at https://www.broadinstitute.org/gatk/about/citing

#Version history
v0.0.0: still a work in progress
