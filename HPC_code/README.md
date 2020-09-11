# HPC
## Overview
HPC code is designed to work with Son of Grid Engine (SGE) HPC scheduler

Matlab code must be compiled before use. Compiled code is not included due to size restrictions

<<<<<<< HEAD
SCOUT must be placed at base folder ('~') on the remote server unless new paths are specified

=======
>>>>>>> 4a675d56d800eaf546e62ea1fa2ceccc319852d2
Compile code by running bash Submit_[code_name].hpc

Otherwise, you can schedule your job with qsub [code_name]_hpc.sh

[code_name]_hpc.sh contains the job info, where you can specify the number of cores and which nodes to run on

Options, including filename locations are located in the [code_name]_options.txt files

## Currently Available Code

Motion Correction: takes in files for motion correction and outputs motion corrected files

individual_extraction: takes in files for signal extraction

BatchEndoscopeWrapper: takes in folder containing video files, extracts and cell tracks the results. Does not include session alignment at the present time

<<<<<<< HEAD
full_pipeline: takes in folder containing video files, optionally background subtracts, motion corrects, and aligns videos, then extracts each video and cell tracks the result
=======
>>>>>>> 4a675d56d800eaf546e62ea1fa2ceccc319852d2

## Notes

Currently, background_subtract must be set to false for motion_correction

Due to required manual input, BatchEndoscopeWrapper can only be run if no other extractions exist in the video directory

While you can include multiple files for individual extraction, this may not use HPC resources effectively, code will run faster if you send individual jobs for each video, or a batch job.

Deleting the .git folder can speed up compilation if you need to recompile the code