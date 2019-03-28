#!/bin/bash -l
#SBATCH -J filtering_job
#SBATCH -o filtering_job_out_%j.txt
#SBATCH -e filtering_job_err_%j.txt
#SBATCH -t 02:00:00
#SBATCH --mem-per-cpu=2000
#SBATCH --array=1-3
#SBATCH -n 3

# move to the directory where the data files are located
cd /homeappl/home/matammi/teaching_materials

# set input file to be processed
name=$(sed -n "$SLURM_ARRAY_TASK_ID"p merged.list)
out_name=$(echo $name | awk -F'_' '{print $1"_filtered.fastq"}')

# run the analysis command
vsearch --threads 6 --fastq_filter $name --fastq_maxee 1 --fastq_minlen 200 --fastq_maxlen 600 --fastq_maxns 0 --fastaout $out_name --fasta_width 0
