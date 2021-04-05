---
title: "Unix tricks for bioinformagicians"
date: 2018-03-30T13:00:43+03:00
lastmod: 2019-09-30T23:00:01+03:00
---


I use these Unix one-liners and such all the time in my bioinformatic work. I hope you'll find then useful as well!
</br>

Reverse complement all sequences in a fasta file.

```bash
paste -d "\n" \
    <(grep ">" sequences.fasta) \
    <(grep -v ">" sequences.fasta | tr ATGC TACG | rev) \
    > reverse_complemented_sequences.fasta
```

Prepare a stability file from paired end reads.

```bash
paste \
    <(ls *R1*.fastq | awk -F"_" '{print $1}') \
    <(ls *R1*.fastq)\
    <(ls *R2*.fastq)\
    > stability.txt
```

Compress the contents of a folder individually; separate process for each. Uses SLURM. Credit goes to <a href="https://stackoverflow.com/questions/29810186/is-there-a-one-liner-for-submitting-many-jobs-to-slurm-similar-to-lsf" target="_blank">this thread</a>.

```bash
ls | xargs -I {} sbatch --wrap="gzip {}"
```

Convert a fastq to a fasta. Assumes that a comma can be used as a line separator.

```bash
cat file.fastq | paste -d, - - - - | awk -F, '{print ">" $1 "\n" $2 "\n"}' > file.fasta
```

Trim first 24 and last 20 bases from each sequence in a fasta file.

```bash
paste -d "\n" \
    <(grep ">" sequences.fasta)
    <(grep -v ">" sequences.fasta | cut -c25- | rev | cut -c21- | rev)
```

Remove line breaks in a fasta file. Credit goes to <a href="https://stackoverflow.com/questions/15857088/remove-line-breaks-in-a-fasta-file" target="_blank">this thread</a>.

```bash
awk '/^>/ {print s ? s "\n" $0 : $0; s=""; next} \
          {s=s sprintf("%s", $0)} END {if (s) print s}' \
    sequences.fasta > sequences_with_no_line_breaks.fasta
```

Create size bins (intervals of 10 bases) of a fasta file.

```bash
cat file.fasta | paste -d, - - | \
    awk -F, '{f = int(length($2)/10)*10 ".fas"; print $1 "\n" $2 > f}'
```

Make an indexed fasta from a list of sequences.

```bash
awk '$0 = ">" NR "\n" $0' sequences.seq > sequences.fasta
```

Quality-trim a bunch of fastq files. Depends on <a href="http://hannonlab.cshl.edu/fastx_toolkit/" target="_blank">FASTX-Toolkit</a>.

```bash
ls *.fastq | while read file; \
    do echo $file; fastx_clipper -Q 33 -i $file -o ${file}_trimmed; done
```

Intersperse paired end reads from two fastq files into a single fastq file.

```bash
paste -d "\n" \
    <(cat reads1.fastq | paste -d% - - - -) \
    <(cat reads2.fastq | paste -d% - - - -) | tr '%' '\n' \
 > joined_reads.fastq
```

Calculate the number of entries in a fasta file.

```bash
grep -c ">" file.fasta
```

Calculate the length distribution (bin size 1000) of sequences in a fasta file.

```bash
awk '/^>/ {if (len != 0) print int(len/1000)*1000+1000; \
    len = 0; next} {len += length($0)}' sequences.fasta | \
    sort | uniq -c | sort -rn
```
