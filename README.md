# phase_everyone
Phase_hybrid... phases hybrids. This phases all the samples in your next-gen dataset

#Phasing_settings file example
Note the differences between this file and the one used in the Phase_hybrid_from_next_gen pipeline if you are familiar with that one

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
