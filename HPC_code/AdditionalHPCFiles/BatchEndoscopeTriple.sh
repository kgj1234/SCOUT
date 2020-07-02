
#!/bin/bash 
#$ -S /bin/bash 
#$ -N endotriple 
#$ -q free72i

#$ -ckpt restart
#$ -cwd 
#$ -pe one-node-mpi 12
 module load MATLAB

./BatchEndoscopeWrapper $'/pub/kgjohnst/mouse0/' $'8' $'2' $'3' $'10000'


