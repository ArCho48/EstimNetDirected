#!/bin/bash

#SBATCH --job-name="ifd_EstimNetDirected_mpi"
#SBATCH --ntasks=8
#SBATCH --time=0-0:30:00

echo -n "started at: "; date

ROOT=..

module load R/3.2.1-vlsci_intel-2015.08.25

time srun ${ROOT}/src/EstimNetDirected_mpi config_example_ifd.txt

time Rscript ${ROOT}/scripts/computeEstimNetDirectedCovariance.R theta_ifd_sim_n1000_sample dzA_ifd_sim_n1000_sample
time Rscript ${ROOT}/scripts/plotEstimNetDirectedResults.R theta_ifd_sim_n1000_sample dzA_ifd_sim_n1000_sample

echo -n "ended at: "; date
