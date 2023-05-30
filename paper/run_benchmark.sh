#!/bin/bash
#SBATCH --job-name=zoomerjoin_benchmark
#SBATCH --output=zoomerjoin_benchmark.out
#SBATCH --error=zoomerjoin_benchmark.err
#SBATCH --time=1-00:00:00     ### Wall clock time limit in Days-HH:MM:SS
#SBATCH --nodes=1             ### Node count required for the job
#SBATCH --ntasks-per-node=1   ### Number of tasks to be launched per Node
#SBATCH --mem=100GB
#SBATCH --cpus-per-task=30
#SBATCH --partition=day
#SBATCH --mail-user=beniamino.green@yale.edu
#SBATCH --mail-type=ALL

module add R/4.3.0-foss-2020b

Rscript benchmark.R
