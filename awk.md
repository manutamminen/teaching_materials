---
title: "Introducing Awk"
date: 2015-12-15T12:08:24+03:00
---

In this entry I'm going to explain the very basics of a little programming language called Awk. The primary reason why I'm advocating the use of Awk (and not for instance Perl or Python) is that Awk is absolutely great for writing very short programs, or one-liners. In fact, in my opinion Awk should never be used for anything longer than one-liners - if your task appears to demand a longer piece of code, it will probably be wiser to choose Perl or Python instead. Combined with the brevity of [Unix pipes and process substitution](/posts/process_subst/), the concise syntax of Awk permits extremely powerful one-liners. The first example in this entry describes constructing a stability file for Mothur, described [here](http://www.mothur.org/wiki/MiSeq_SOP#Getting_started). You can test everything described in this entry using [this example data set](http://www.mothur.org/w/images/d/d6/MiSeqSOPData.zip). After uncompressing the data set, check the fastq files in the directory using `ls *.fastq`. You should see the following:

```bash
F3D0_S188_L001_R1_001.fastq
F3D0_S188_L001_R2_001.fastq
F3D141_S207_L001_R1_001.fastq
F3D141_S207_L001_R2_001.fastq
F3D142_S208_L001_R1_001.fastq
F3D142_S208_L001_R2_001.fastq
F3D143_S209_L001_R1_001.fastq
F3D143_S209_L001_R2_001.fastq
F3D144_S210_L001_R1_001.fastq
F3D144_S210_L001_R2_001.fastq
F3D145_S211_L001_R1_001.fastq
F3D145_S211_L001_R2_001.fastq
...
```

Each fastq file is present in two flavors: **R1** in the name indicates a forward read from Illumina MiSeq and **R2** a reverse read. Mothur has a built-in functionality to join these reads into single contigs - however for that it needs something called a *stability file*. A stability file is a tab-separated table containing the sample names and the associated forward and reverse read file names. Mothur tutorial provides such file but does not describe how it can be constructed.

```bash
F3D0 F3D0_S188_L001_R1_001.fastq F3D0_S188_L001_R2_001.fastq 
F3D141 F3D141_S207_L001_R1_001.fastq F3D141_S207_L001_R2_001.fastq 
F3D142 F3D142_S208_L001_R1_001.fastq F3D142_S208_L001_R2_001.fastq
F3D143 F3D143_S209_L001_R1_001.fastq F3D143_S209_L001_R2_001.fastq 
F3D144 F3D144_S210_L001_R1_001.fastq F3D144_S210_L001_R2_001.fastq 
...
```

Columns two and three of a stability file correspond to the forward and reverse read file names, respectively, and column one corresponds to the beginning of the file name that in this example is also the sample name. Extracting the sample names from the file names is a task for which we need Awk. To cut the chase, here's how it's done:

```bash
paste <(ls *R1*.fastq | awk -F_ '{print $1}') <(ls *R1*.fastq) <(ls *R2*.fastq)
```

If you've read the [previous entry](/posts/process_subst/), you might recognize the process substitution syntax - that is, the `<( ... )` -structures that are feeding stuff to the *paste* command. Please review the [previous entry](/posts/process_subst/) if you're not familiar with process substitution. Awk can be used for a lot of things but one of the most common uses is splitting lines at particular characters. The `-F` switch specifies the character by which the line is to be chopped. The resulting pieces can be accessed using variables `$1`, `$2`, `$3` etc. The entire non-chopped line is also available under variable `$0`. Armed with this information, let's take apart the first process substitution part of the command pipeline above: 

```bash
ls *R1*.fastq | awk -F_ '{print $1}'
```

What's happening here is that we're first getting a list of files that have letters **R1** in their name and a suffix *fastq* , and piping this to Awk where it's processed line by line. First we're telling Awk to split the lines at each occurrence of `_` by providing the `-F_` switch. Next comes the actual Awk program - that is the part specified inside the '-characters. For reasons that I will not discuss here, all print statements in Awk must be surrounded by curly brackets. By specifying variable $1 for the print statement, the first part of the splitted line gets printed. Experiment by yourself and see what happens if you choose `$2`, `$3` or `$0` instead. You can also add your own text to the Awk print statement, for instance 

```bash
ls *R1*.fastq | awk -F_ '{print "I am sample " $1}' 
```

In this example it really makes no sense but in other cases can be very useful. One simple example is converting a *fastq* to a *fasta*. This is done simply by taking the two first lines of each *fastq* entry and prepending the first line by `>`-character. Here's how it goes: 

```bash
cat file.fastq | paste -d, - - - - | awk -F, '{print ">" $1 "\n" $2 "\n"}' > file.fasta 
```


What's going on here is that the four successive lines of a *fastq* are concatenated into a single line separated by commas. This functionality is provided by the `paste -d, - - - -` construct, where the `-d,` switch tells *paste* to use comma as a line separator, and the four `-`-characters inform *paste* to read in four consecutive lines at a time. The output from *paste* - the four concatenated lines - is piped to Awk. Awk is told to use comma as line splitting character - this is how we parse the concatenated lines of *fastq* back into separate lines, available in variables `$1`, `$2`, `$3` and `$4`. We only need variables `$1` and `$2` here since they contain the fasta ID line and the DNA sequence, respectively. We need to add `>` before the ID line and provide newline characters `\n` between the ID and sequence lines. Please examine the print statement to get the idea of how it works and experiment by adding your own text. Any of the *fastq* files in the [example data set](http://www.mothur.org/w/images/d/d6/MiSeqSOPData.zip) can be used for experimenting. 

Awk is an extremely versatile and powerful tool and I have only scratched the surface of its uses here. I will cover more examples in future posts - if you're feeling curious in the meantime, check my [Unix tricks](/posts/unix_tricks/) page!

