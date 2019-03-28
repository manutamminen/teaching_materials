#!/bin/bash -l
#SBATCH -J pair_merging_job
#SBATCH -o pair_merging_job_out_%j.txt
#SBATCH -e pair_merging_job_err_%j.txt
#SBATCH -t 02:00:00
#SBATCH --mem-per-cpu=2000
#SBATCH --array=1-6
#SBATCH -n 6

# move to the directory where the data files are located
cd /homeappl/home/matammi/teaching_materials

# set input file to be processed
name=$(sed -n "$SLURM_ARRAY_TASK_ID"p fastq_files.list)
forward_read=$(echo $name | awk '{print $1}')
reverse_read=$(echo $name | awk '{print $2}')
out_name=$(echo $forward_read | awk -F'_' '{print $1 "_merged.fastq"}')

# run the analysis command
vsearch --threads 6 --fastq_mergepairs $forward_read --reverse $reverse_read --fastq_minovlen 50 --fastq_maxdiffs 15 --fastqout $out_name --fastq_eeout
