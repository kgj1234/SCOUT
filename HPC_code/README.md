# HPC
## Overview
HPC code is designed to work with Son of Grid Engine (SGE) HPC scheduler

Matlab code must be compiled before use. Compiled code is not included due to size restrictions

<<<<<<< HEAD
Compile code by running bash compile_full_.pipeline.sh

Otherwise, you can schedule your job with qsub full_pipeline_hpc.sh

full_pipeline_hpc.sh contains the job info, where you can specify the folder name of the directory containing videos, the number of cores and which nodes to run on

You must provide a link to a folder containing recordings in full_pipeline_hpc.sh.

Recordings must have the following properties: size-[m,n,T] (no full color), format-'.mat' containing variable Y

Run_Extraction_Remotely.m contains functionality to perform most HPC processes from a matlab instance. Simply edit the local directory to the recordings and the SCOUT folder location and run the script. Reload the parameters and run the second section of the script to retrieve extracted videos.

Retrieval of files on PC requires Putty (https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html)

## Options

options are located in './full_pipeline/full_pipeline_hpc.options

Most options are duplicated from non-HPC code with the following exceptions

motion_correct (bool) indicates whether to motion correct videos
background_subtract (bool) indicates whether to background subtract videos using min1pipe. You should probably use 2p extraction on the result. 
from_filtered (bool) indicates whether to use background subtracted videos for extraction. This can reduce accuracy in certain instances.
register_sessions (bool) indicates whether to perform automatic session registration
extract_videos (bool) indicates whether to perform video extraction

=======
SCOUT must be placed at base folder ('~') on the remote server unless new paths are specified

Compile code by running bash Submit_[code_name].hpc

Otherwise, you can schedule your job with qsub [code_name]_hpc.sh

[code_name]_hpc.sh contains the job info, where you can specify the number of cores and which nodes to run on

Options, including filename locations are located in the [code_name]_options.txt files

## Currently Available Code

Motion Correction: takes in files for motion correction and outputs motion corrected files

individual_extraction: takes in files for signal extraction

BatchEndoscopeWrapper: takes in folder containing video files, extracts and cell tracks the results. Does not include session alignment at the present time


full_pipeline: takes in folder containing video files, optionally background subtracts, motion corrects, and aligns videos, then extracts each video and cell tracks the result
>>>>>>> 1b79ac8f015244c3f87d381b6f04f384c54ab5aa


## Notes

<<<<<<< HEAD
If compiling the source code, do not run additional instances concurrently

Deleting the .git folder on the host can speed up compilation

After extraction, on the new directory tree, the variable neurons contains the individual recording extractions, and SCOUT_neuron contains the cell tracking results.
 
=======
Currently, background_subtract must be set to false for motion_correction

Due to required manual input, BatchEndoscopeWrapper can only be run if no other extractions exist in the video directory

While you can include multiple files for individual extraction, this may not use HPC resources effectively, code will run faster if you send individual jobs for each video, or a batch job.

Deleting the .git folder can speed up compilation if you need to recompile the code
>>>>>>> 1b79ac8f015244c3f87d381b6f04f384c54ab5aa
