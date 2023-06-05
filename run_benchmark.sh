#!/bin/bash
#SBATCH --job-name=zoomerjoin_benchmark
#SBATCH --output=zoomerjoin_benchmark.out
#SBATCH --error=zoomerjoin_benchmark.err
#SBATCH --time=5-00:00:00     ### Wall clock time limit in Days-HH:MM:SS
#SBATCH --nodes=1             ### Node count required for the job
#SBATCH --ntasks-per-node=1   ### Number of tasks to be launched per Node
#SBATCH --mem=20GB
#SBATCH --cpus-per-task=8

Rscript benchmark.R
