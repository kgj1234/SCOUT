# HPC
## Overview
1) HPC code is designed to work with Son of Grid Engine (SGE) HPC scheduler

2) Matlab code must be compiled before use. Compiled code is not included due to size restrictions

3) full_pipeline_hpc.sh contains the job info, where you can specify the folder name of the directory containing videos, the number of cores and which nodes to run on

4) Run_Extraction_Remotely.m contains functionality to perform most HPC processes from a matlab instance. Simply edit the local directory to the recordings and the SCOUT folder location and run the script. 

5) Retrieve_Extracted_Files.m contains contains functionality for retrieving extracted files from the HPC. Simply load job information (automatically saved by Run_Extraction_Remotely.m) and run the script.

6) Recordings must have the following properties: size-[m,n,T] (no full color), format-'.mat' containing variable Y. Run_Extraction_Remotely.m attempts to convert .avi and .mat files to this form.

7) Retrieval of files on PC requires Putty (https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html)

8) SCOUT must be placed at base folder ('~') on the host server due to several hard coded file paths

## Options

1) options are located in './full_pipeline/full_pipeline_hpc.options

2) Most options are duplicated from non-HPC code with the following exceptions

motion_correct (bool) indicates whether to motion correct videos  
background_subtract (bool) indicates whether to background subtract videos using min1pipe.  
from_filtered (bool) indicates whether to use background subtracted videos for extraction. This can reduce accuracy in certain instances.  
register_sessions (bool) indicates whether to perform automatic session registration  
extract_videos (bool) indicates whether to perform video extraction  


## Currently Available Code

full_pipeline: takes in folder containing video files, optionally background subtracts, motion corrects, and aligns videos, then extracts each video and cell tracks the result


## Notes

If compiling the source code, do not run additional instances concurrently

Deleting the .git folder on the host can speed up compilation

After extraction, on the new directory tree, the variable neurons contains the individual recording extractions, and SCOUT_neuron contains the cell tracking results.
 
## Operations on Host

To operate directly on the host server, you must do the following

1) change video location folder on host (full_pipeline_hpc.sh)

2) Adjust extraction options (full_pipeline_options.txt). This file should then be placed in the video location folder

3) submit job (qsub full_pipeline_hpc.sh) or compile (bash compile_full_pipeline.sh)

