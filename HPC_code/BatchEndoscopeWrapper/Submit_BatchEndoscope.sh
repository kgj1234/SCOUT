




module load MATLAB
mcc BatchEndoscopeWrapper_HPC.m -m -v -a ../../CNMF_E -a ../../background_subtraction -a ../../Correlation -a ../../Misc -a ../../Preprocessing -a ../../SCOUT_CellTracking -a ../../SCOUT_templatefilter -I ../ -I ../../
	
qsub BatchEndoscopeWrapper_HPC.sh


