

#!/bin/bash 
#$ -S /bin/bash 
#$ -N batchendoscope 
#$ -q mathskin
#$ -ckpt restart

#$ -cwd 
#$ -pe one-node-mpi 48
 module load MATLAB

./individual_extraction_hpc
