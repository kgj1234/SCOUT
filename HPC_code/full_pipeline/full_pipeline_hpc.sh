#!/bin/bash 
#$ -S /bin/bash 
#$ -N batchendoscope 
#$ -q mathskin
#$ -ckpt restart
#$ -cwd 
#$ -pe one-node-mpi 12
 module load MATLAB
~/SCOUT/HPC_code/full_pipeline/full_pipeline_hpc $'/pub/kgjohnst/Desktop/Hai_EA/mouse_01_1sttest/layer3'
