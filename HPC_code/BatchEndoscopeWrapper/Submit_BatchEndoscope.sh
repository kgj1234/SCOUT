




module load MATLAB
<<<<<<< HEAD
mcc ~/SCOUT/HPC_code/BatchEndoscopeWrapper/BatchEndoscopeWrapper_HPC.m -m -v -d ~/SCOUT/HPC_code/BatchEndoscopeWrapper/ -a ~/SCOUT/CNMF_E -a ~/SCOUT/background_subtraction -a ~/SCOUT/Correlation -a ~/SCOUT/Misc -a ~/SCOUT/Preprocessing -a ~/SCOUT/SCOUT_CellTracking -a ~/SCOUT/SCOUT_templatefilter -I ~/SCOUT/HPC_code/ -I ~/SCOUT/
	
qsub ~/SCOUT/HPC_code/BatchEndoscopeWrapper/BatchEndoscopeWrapper_HPC.sh
=======
mcc BatchEndoscopeWrapper_HPC.m -m -v -a ../../CNMF_E -a ../../background_subtraction -a ../../Correlation -a ../../Misc -a ../../Preprocessing -a ../../SCOUT_CellTracking -a ../../SCOUT_templatefilter -I ../ -I ../../
	
qsub BatchEndoscopeWrapper_HPC.sh
>>>>>>> 4a675d56d800eaf546e62ea1fa2ceccc319852d2


