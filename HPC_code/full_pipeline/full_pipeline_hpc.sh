<<<<<<< HEAD
#!/bin/bash 
#$ -S /bin/bash 
#$ -N batchendoscope 
#$ -q free64
#$ -ckpt restart
#$ -cwd 
#$ -pe one-node-mpi 12
 module load MATLAB
~/SCOUT/HPC_code/full_pipeline/full_pipeline_hpc $'/pub/kgjohnst/Desktop/Hai_EA/mouse_01_1sttest/layer4'
=======


#!/bin/bash 
#$ -S /bin/bash 
#$ -N batchendoscope 
#$ -q mathskin
#$ -ckpt restart

#$ -cwd 
#$ -pe one-node-mpi 12
 module load MATLAB

~/SCOUT/HPC_code/full_pipeline/full_pipeline_hpc
>>>>>>> 1b79ac8f015244c3f87d381b6f04f384c54ab5aa
