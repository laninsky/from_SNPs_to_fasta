ls *.fasta > namelist.txt

forsamplenames=`tail -n+1 namelist.txt | head -n1`
grep ">" $forsamplenames > samplenamelist.txt

for i in `ls *.fasta`;
do mv $i temp;
echo $i > namefile
Rscript split_samples.R;
rm -rf temp;
rm -rf namefile;
done;

gatk=`tail -n+1 phasing_settings | head -n1`
picard=`tail -n+2 phasing_settings | head -n1`
sequencing=`tail -n+3 phasing_settings | head -n1`

for i in `ls *.fa`;
do sed -i 's/\?/N/g' $i;
sed -i 's/-//g' $i;
bwa index -a is $i;
samtools faidx $i;
name=`echo $i | sed 's/.fa//'`;

forward_proto=`tail -n+4 phasing_settings | head -n1`;
forward=`eval "echo $forward_proto"`;

java -jar $picard CreateSequenceDictionary R=$i O=$name.dict;

if [ $sequencing == paired ]
then
reverse_proto=`tail -n+5 phasing_settings | head -n1`;
reverse=`eval "echo $reverse_proto"`;
bwa mem $i $forward $reverse > temp.sam;
fi

if [ $sequencing == single ]
then
bwa mem $i $forward > temp.sam;
fi

java -jar $picard AddOrReplaceReadGroups I=temp.sam O=tempsort.sam SORT_ORDER=coordinate LB=rglib PL=illumina PU=phase SM=everyone;
java -jar $picard MarkDuplicates MAX_FILE_HANDLES=1000 I=tempsort.sam O=tempsortmarked.sam M=temp.metrics AS=TRUE;
java -jar $picard SamFormatConverter I=tempsortmarked.sam O=tempsortmarked.bam;
samtools index tempsortmarked.bam;
# These tools were depreciated in gatk version 4
#$gatk/gatk -T RealignerTargetCreator -R $i -I tempsortmarked.bam -o tempintervals.list;
#$gatk/gatk -T IndelRealigner -R $i -I  tempsortmarked.bam -targetIntervals tempintervals.list -o temp_realigned_reads.bam;
# The -stand_emit_conf 30 option is deprecated in GATK v 3.7 and was removed from this code on the 5-June-2017
$gatk/gatk HaplotypeCaller -R $i -I temp_realigned_reads.bam -stand_call_conf 30 -o temp_raw_variants.vcf;
$gatk/gatk ReadBackedPhasing -R $i -I temp_realigned_reads.bam  --variant temp_raw_variants.vcf -o temp_phased_SNPs.vcf;
$gatk/gatk FastaAlternateReferenceMaker -V temp_phased_SNPs.vcf -R $i -o temp_alt.fa;

Rscript onelining.R;

rm -rf $name.*;
mv temp_alt2.fa $name.fa;
rm -rf temp*;

sed -i 's/\?/N/g' $i;
sed -i 's/-//g' $i;
bwa index -a is $i;
samtools faidx $i;
java -jar $picard CreateSequenceDictionary R=$i O=$name.dict;

if [ $sequencing == paired ]
then
bwa mem $i $forward $reverse > temp.sam;
fi

if [ $sequencing == single ]
then
bwa mem $i $forward > temp.sam;
fi

java -jar $picard AddOrReplaceReadGroups I=temp.sam O=tempsort.sam SORT_ORDER=coordinate LB=rglib PL=illumina PU=phase SM=everyone;
java -jar $picard MarkDuplicates MAX_FILE_HANDLES=1000 I=tempsort.sam O=tempsortmarked.sam M=temp.metrics AS=TRUE;
java -jar $picard SamFormatConverter I=tempsortmarked.sam O=tempsortmarked.bam;
samtools index tempsortmarked.bam;
# These tools were depreciated in gatk version 4
#$gatk/gatk -T RealignerTargetCreator -R $i -I tempsortmarked.bam -o tempintervals.list;
#$gatk/gatk -T IndelRealigner -R $i -I  tempsortmarked.bam -targetIntervals tempintervals.list -o temp_realigned_reads.bam;
# The -stand_emit_conf 30 option is deprecated in GATK v 3.7 and was removed from this code on the 5-June-2017
$gatk/gatk HaplotypeCaller -R $i -I temp_realigned_reads.bam -stand_call_conf 30 -o temp_raw_variants.vcf;
$gatk/gatk ReadBackedPhasing -R $i -I temp_realigned_reads.bam  --variant temp_raw_variants.vcf -o temp_phased_SNPs.vcf;
$gatk/gatk FastaAlternateReferenceMaker -V temp_phased_SNPs.vcf -R $i -o temp_alt.fa;

Rscript onelining.R;

mv $i safe.$i.ref.fa
rm -rf $name.*;
mv temp_alt2.fa $name.1.fa;
mv safe.$i.ref.fa $name.2.fa
rm -rf temp*;

done

for i in `ls *1.fa`;
do sed -i 's/-//g' $i;
done
