
module load MATLAB
<<<<<<< HEAD
mcc ~/SCOUT/HPC_code/individual_extraction/individual_extraction_hpc.m -m -v -d ~/SCOUT/HPC_code/individual_extraction/ -a ~/SCOUT/CNMF_E -a ~/SCOUT/background_subtraction -a ~/SCOUT/Correlation -a ~/SCOUT/Misc -a ~/SCOUT/Preprocessing -a ~/SCOUT/SCOUT_CellTracking -a ~/SCOUT/SCOUT_templatefilter -I ~/SCOUT/HPC_code/ -I ~/SCOUT/ -a ~/SCOUT/Preprocessing -I ~/SCOUT/HPC_code/ 
	
qsub ~/SCOUT/HPC_code/individual_extraction/individual_extraction_hpc.sh

=======
mcc ./individual_extraction_hpc.m -m -v -a ../../CNMF_E/ -a ../../Correlation/ -a ../../Misc/ -a ../../Preprocessing/ -a ../../SCOUT_CellTracking/ -a ../../SCOUT_templatefilter/ -I ../../ -I ../ -I ../../background_subtraction
	
qsub individual_extraction_hpc.sh
>>>>>>> 4a675d56d800eaf546e62ea1fa2ceccc319852d2

