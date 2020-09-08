
module load MATLAB
mcc ./motion_correction_hpc.m -m -v -a ../../CNMF_E/ -a ../../Correlation/ -a ../../Misc/ -a ../../Preprocessing/ -a ../../SCOUT_CellTracking/ -a ../../SCOUT_templatefilter/ -I ../../ -I ../ -a ../../background_subtraction
	
qsub motion_correction_hpc.sh

