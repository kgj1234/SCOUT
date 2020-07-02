
rm batchendoscope*
rm endosingle*
rm endodouble*
rm endotriple*




module load MATLAB
mcc BatchEndoscopeWrapper.m -m -v -I ../ -I ../ca_source_extraction/ -I ../cnmfe_scripts/ -I ../deconvolveCa/ -I ../ca_source_extraction/endoscope/ -I ../ca_source_extraction/utilities/ -I ../ca_source_extraction/utilities/memmap/ -I ../deconvolveCa/constrained-foopsi/ -I ../deconvolveCa/functions/ -I ../deconvolveCa/MCMC/ -I ../deconvolveCa/oasis/ -I ../deconvolveCa/oasis_kernel/ -I ../BatchAlignmentCode -I ../calculate_footprints -I ../CNMF_E-adjusted_code -I ../Distance_and_Correlation -I ../Filtering -I ../Misc  -I ../BatchAlignmentCode/pathbetweennodes-pkg-master -I ../BatchAlignmentCode/pathbetweennodes-pkg-master/pathbetweennodes

qsub BatchEndoscopeAutoHPC.sh
qsub BatchEndoscopeSingle.sh
qsub BatchEndoscopeDouble.sh
qsub BatchEndoscopeTriple.sh

