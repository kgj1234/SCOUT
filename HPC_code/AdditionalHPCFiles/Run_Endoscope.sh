#!/bin/bash
#$ -S /bin/bash
#$ -N endoscope
#$ -q math
#$ -ckpt restart

#$ -cwd
#$ -pe one-node-mpi 36
 module load MATLAB

./Run_Demo_Endoscope $'/pub/kgjohnst/mouse0/' $'31' $'41'

