
#!/bin/bash 
#$ -S /bin/bash 
#$ -N batchendoscope 
#$ -q math
#$ -ckpt restart

#$ -cwd 
#$ -pe one-node-mpi 12
 module load MATLAB

~/SCOUT/HPC_code/BatchEndoscopeWrapper/BatchEndoscopeWrapper_HPC 