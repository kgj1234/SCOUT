
module load MATLAB
mcc ./individual_extraction_hpc.m -m -v -a ../../CNMF_E/ -a ../../Correlation/ -a ../../Misc/ -a ../../Preprocessing/ -a ../../SCOUT_CellTracking/ -a ../../SCOUT_templatefilter/ -I ../../ -I ../ -I ../../background_subtraction
	
qsub individual_extraction_hpc.sh

