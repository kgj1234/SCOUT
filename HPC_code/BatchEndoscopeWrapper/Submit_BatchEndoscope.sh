




module load MATLAB
mcc ~/SCOUT/HPC_code/BatchEndoscopeWrapper/BatchEndoscopeWrapper_HPC.m -m -v -d ~/SCOUT/HPC_code/BatchEndoscopeWrapper/ -a ~/SCOUT/CNMF_E -a ~/SCOUT/background_subtraction -a ~/SCOUT/Correlation -a ~/SCOUT/Misc -a ~/SCOUT/Preprocessing -a ~/SCOUT/SCOUT_CellTracking -a ~/SCOUT/SCOUT_templatefilter -I ~/SCOUT/HPC_code/ -I ~/SCOUT/
	
qsub ~/SCOUT/HPC_code/BatchEndoscopeWrapper/BatchEndoscopeWrapper_HPC.sh


