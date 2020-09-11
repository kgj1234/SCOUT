
#!/bin/bash 
#$ -S /bin/bash 
#$ -N batchendoscope 
<<<<<<< HEAD
#$ -q math
#$ -ckpt restart

#$ -cwd 
#$ -pe one-node-mpi 12
 module load MATLAB

~/SCOUT/HPC_code/BatchEndoscopeWrapper/BatchEndoscopeWrapper_HPC 
=======
#$ -q mathskin
#$ -ckpt restart

#$ -cwd 
#$ -pe one-node-mpi 48
 module load MATLAB

./BatchEndoscopeWrapper_HPC 
>>>>>>> 4a675d56d800eaf546e62ea1fa2ceccc319852d2
