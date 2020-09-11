

#!/bin/bash 
#$ -S /bin/bash 
#$ -N batchendoscope 
#$ -q mathskin
#$ -ckpt restart

#$ -cwd 
#$ -pe one-node-mpi 12
 module load MATLAB

~/SCOUT/HPC_code/Motion_Correction/motion_correction_hpc
