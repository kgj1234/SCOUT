
#!/bin/bash 
#$ -S /bin/bash 
#$ -N batchendoscope 
#$ -q mathskin
#$ -ckpt restart

#$ -cwd 
#$ -pe one-node-mpi 48
 module load MATLAB

./BatchEndoscopeWrapper $'/pub/kgjohnst/mouse0/' $'8' $'2' $'8' $'10000'


