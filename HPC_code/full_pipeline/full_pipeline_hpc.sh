#!/bin/bash 
#$ -S /bin/bash 
#$ -N batchendoscope 
#$ -q free64
#$ -ckpt restart
#$ -cwd 
#$ -pe one-node-mpi 24
 module load MATLAB
~/SCOUT/HPC_code/full_pipeline/full_pipeline_hpc $'/pub/kgjohnst/data/KevinStuff_08272020/SCOUT/Demos'
