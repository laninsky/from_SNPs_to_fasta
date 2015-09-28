# A list function that only grabs your samples of interest rather than all the other assorted files
\ls -d varanus_* >  samplenamelist.txt

#"contigs_to_probes.fasta" is whatever the fasta reference is that you used to assemble your bams
samtools faidx contigs_to_probes.fasta

#"contigs_to_probes.fasta" is whatever the fasta reference is that you used to assemble your bams
grep ">" contigs_to_probes.fasta > namelist.txt
sed -i 's/>//g' namelist.txt;

java -jar $picard CreateSequenceDictionary R=contigs_to_probes.fasta O=contigs_to_probes.dict;

gatk=`tail -n+1 phasing_settings | head -n1`
picard=`tail -n+2 phasing_settings | head -n1`
sequencing=`tail -n+3 phasing_settings | head -n1`

for i in \ls -d varanus_*;
do name=`echo $i`;

forward_proto=`tail -n+4 phasing_settings | head -n1`;
forward=`eval "echo $forward_proto"`;

#The pathway to your bam reads with the ${name} parts replaced
cp ${name}/${name}.bam temp.bam;
samtools view -h temp.bam > temp.sam; 

java -jar $picard AddOrReplaceReadGroups I=temp.sam O=tempsort.sam SORT_ORDER=coordinate LB=rglib PL=illumina PU=phase SM=everyone VALIDATION_STRINGENCY=SILENT;
java -jar $picard MarkDuplicates MAX_FILE_HANDLES=1000 I=tempsort.sam O=tempsortmarked.sam M=temp.metrics AS=TRUE VALIDATION_STRINGENCY=SILENT;
java -jar $picard SamFormatConverter I=tempsortmarked.sam O=tempsortmarked.bam VALIDATION_STRINGENCY=SILENT;
samtools index tempsortmarked.bam;
java -jar $gatk -T RealignerTargetCreator -R contigs_to_probes.fasta -I tempsortmarked.bam -o tempintervals.list;
java -jar $gatk -T IndelRealigner -R contigs_to_probes.fasta -I  tempsortmarked.bam -targetIntervals tempintervals.list -o temp_realigned_reads.bam;
java -jar $gatk -T HaplotypeCaller -R contigs_to_probes.fasta -I temp_realigned_reads.bam --genotyping_mode DISCOVERY -stand_emit_conf 30 -stand_call_conf 30 -o temp_raw_variants.vcf;
java -jar $gatk -T ReadBackedPhasing -R contigs_to_probes.fasta -I temp_realigned_reads.bam  --variant temp_raw_variants.vcf -o temp_phased_SNPs.vcf;
java -jar $gatk -T FastaAlternateReferenceMaker -V temp_phased_SNPs.vcf -R contigs_to_probes.fasta -o temp_alt.fa;

Rscript onelining.R;

mv temp_alt2.fa $name.fa;
rm -rf temp*;

sed -i 's/\?/N/g' $name.fa;
sed -i 's/-//g' $name.fa;
bwa index -a is $name.fa;
samtools faidx $name.fa;
java -jar $picard CreateSequenceDictionary R=$name.fa O=$name.dict;

if [ $sequencing == paired ]
then
bwa mem $name.fa $forward $reverse > temp.sam;
fi

if [ $sequencing == single ]
then
bwa mem $name.fa $forward > temp.sam;
fi

java -jar $picard AddOrReplaceReadGroups I=temp.sam O=tempsort.sam SORT_ORDER=coordinate LB=rglib PL=illumina PU=phase SM=everyone;
java -jar $picard MarkDuplicates MAX_FILE_HANDLES=1000 I=tempsort.sam O=tempsortmarked.sam M=temp.metrics AS=TRUE;
java -jar $picard SamFormatConverter I=tempsortmarked.sam O=tempsortmarked.bam;
samtools index tempsortmarked.bam;
java -jar $gatk -T RealignerTargetCreator -R $name.fa -I tempsortmarked.bam -o tempintervals.list;
java -jar $gatk -T IndelRealigner -R $name.fa -I  tempsortmarked.bam -targetIntervals tempintervals.list -o temp_realigned_reads.bam;
java -jar $gatk -T HaplotypeCaller -R $name.fa -I temp_realigned_reads.bam --genotyping_mode DISCOVERY -stand_emit_conf 30 -stand_call_conf 30 -o temp_raw_variants.vcf;
java -jar $gatk -T ReadBackedPhasing -R $name.fa -I temp_realigned_reads.bam  --variant temp_raw_variants.vcf -o temp_phased_SNPs.vcf;
java -jar $gatk -T FastaAlternateReferenceMaker -V temp_phased_SNPs.vcf -R $name.fa -o temp_alt.fa;

Rscript onelining.R;

mv $name.fa safe.$name.fa.ref.fa
rm -rf $name.*;
mv temp_alt2.fa $name.1.fa;
mv safe.$name.fa.ref.fa $name.2.fa
rm -rf temp*;

done

for i in `ls *1.fa`;
do sed -i 's/-//g' $i;
done
