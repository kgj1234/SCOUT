
#!/bin/bash 
#$ -S /bin/bash 
#$ -N endodouble 
#$ -q math

#$ -ckpt restart
#$ -cwd 
#$ -pe one-node-mpi 18
 module load MATLAB

./BatchEndoscopeWrapper $'/pub/kgjohnst/mouse0/' $'8' $'2' $'2' $'10000'


