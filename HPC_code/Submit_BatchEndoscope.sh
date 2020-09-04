




module load MATLAB
mcc BatchEndoscopeWrapper.m -m -v -I ../ -I ../CNMF_E -I ../CNMF_E/ca_source_extraction/ -I ../CNMF_E/scripts/ -I ../CNMF_E/deconvolveCa/ -I ../CNMF_E/ca_source_extraction/endoscope/ -I ../CNMF_E/ca_source_extraction/utilities/ -I ../CNMF_E/ca_source_extraction/utilities/memmap/ -I ../CNMF_E/deconvolveCa/packages/constrained-foopsi/ -I ../CNMF_E/deconvolveCa/functions/ -I ../CNMF_E/deconvolveCa/packages/MCMC/ -I ../CNMF_E/deconvolveCa/packages/oasis/ -I ../CNMF_E/deconvolveCa/packages/oasis_kernel/ -I ../SCOUT_CellTracking/ -I ../SCOUT_CellTracking/CellTracking -I ../Misc/calculate_footprints -I ../SCOUT_templatefilter -I ../SCOUT_templatefilter/dependencies  -I ../Misc  -I ../SCOUT_templatefilter/dependencies/ProbabilityDistribution -I ../Correlation

	
qsub BatchEndoscopeAutoHPC.sh


