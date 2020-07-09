# SCOUT
SCOUT (Single-Cell SpatiOtemporal LongitUdinal Tracking) is an end to end system for the preprocessing, extraction, and cell tracking of multi-session neural activity extracted from optical recordings. 

## Installation
Download or clone the repository, and add to the matlab path. To add to the path, navigate to the base SCOUT directory, and run 
    addpath(genpath('.')).

## Modules
SCOUT is composed of 2 modules:

Extraction - Built on CNMF-E for 1-photon recordings, and CNMF for 2-photon recordings, SCOUT imposes an additional spatial filter proven to signficantly reduce false detection rates while retaining a comparable number of neurons to the base algorithm.

Cell Tracking - SCOUT uses an ensemble of predictors to assign identification probabilities for neurons between sessions, followed by a corrector which forces each neuron to appear in exactly one column of the cell register (the matrix of cell identifications across sessions). This method has outperformed cellReg on simulated and in vivo data.

SCOUT also includes motion correction using NoRMCorre, and a framework for global session registration prior to extraction (see demos)
## Demos
SCOUT currently contains six demos, demonstrating each module, as well as the full pipeline (see SCOUT/Demos). 

## File Format
Currently, most SCOUT modules accept '.avi', '.mat', '.tif/.tiff' file formats for recordings.

## Output
Output of both cell extraction and cell tracking is in the form of the Sources2D (CNMF for 2p) class. The following fields are of primary importance

C: Neural temporal signal  
S: Neural spike events  
A: Neuron spatial footprints  

With additional fields for cell tracking

probabilities: Neuron identification probabilities  
cell_register: Matrix of cell identifications across session  
A_per_session: spatial footprints of detected neurons in each session

## Requirements 
MATLAB >2018a (untested for previous versions)  
MATLAB C++ compiler  
Tested on CentOS 7 and Windows

## Pipeline
1. Motion correct via NoRMCorre (demo_preprocessing.m demo)
2. Perform session alignment (Session_Registration_Demo.m demo)
3. Extract and Track Neurons (cell_Tracking_Demo.m)

The current full_pipeline_demo.m does not include session alignment code (as this code is interactive).   
Either use the individual demos, or perform session registration as an intermediate step inside full_pipeline_demo.m

## Troubleshooting
1. What if I am extracting too few neurons?  
Answer: raise the spatial_filter threshold if too many neurons are being deleted, 
or lower the initialization parameters if too few neurons are initialized. Both operations can be controlled with extraction_options.

2. What if I am tracking too few neurons? Check the automated post processing session alignment, or turn it off altogether. 
Lower min_prob or chain_prob parameters. Try increasing the session overlap. These parameters can be controlled with cell_tracking_options.






















