

#!/bin/bash 
#$ -S /bin/bash 
#$ -N batchendoscope 
#$ -q mathskin
#$ -ckpt restart

#$ -cwd 
#$ -pe one-node-mpi 48
 module load MATLAB

../individual_extraction_main $'/pub/kgjohnst/mouseC/motion_corrected/vids1_motion_corrected.mat' $'25' $'1p' $'350' $'.1' $'true' $'[]' $'8' %.11


