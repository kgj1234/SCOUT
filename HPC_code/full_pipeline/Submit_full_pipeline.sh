
module load MATLAB
mcc ~/SCOUT/HPC_code/full_pipeline/full_pipeline_hpc.m -m -v -d ~/SCOUT/HPC_code/full_pipeline/ -a ~/SCOUT/CNMF_E -a ~/SCOUT/background_subtraction -a ~/SCOUT/Correlation -a ~/SCOUT/Misc -a ~/SCOUT/Preprocessing -a ~/SCOUT/SCOUT_CellTracking -a ~/SCOUT/SCOUT_templatefilter -I ~/SCOUT/HPC_code/ -I ~/SCOUT/ -a ~/SCOUT/Preprocessing -I ~/SCOUT/HPC_code/ 
	
qsub ~/SCOUT/HPC_code/full_pipeline/full_pipeline_hpc.sh

