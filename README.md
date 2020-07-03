# SCOUT
SCOUT (Single-Cell SpatiOtemporal LongitUdinal Tracking) is an end to end system for the preprocessing, extraction, and cell tracking of multi-session neural activity extracted from optical recordings. 

## Installation
Download or clone the repository, and add to the matlab path.

## Modules
SCOUT is composed of 3 modules:

Preprocessing - Contains code for motion correction (NorMCorre), and initial session registration (both rigid and non-rigid).

Extraction - Built on CNMF-E for 1-photon recordings, and CNMF for 2-photon recordings, SCOUT imposes an additional spatial filter proven to signficantly reduce false detection rates while retaining a comparable number of neurons to the base algorithm.

Cell Tracking - SCOUT uses an ensemble of predictors to assign identification probabilities for neurons between sessions, followed by a corrector which forces each neuron to appear in exactly one column of the cell register (the matrix of cell identifications across sessions). This method has outperformed cellReg on simulated and in vivo data.

## Demos
SCOUT currently contains five demos, demonstrating each module, as well as the full pipeline (see SCOUT/Demos). 

## File Format
Currently, SCOUT requires a specific format for recordings. Recordings must be saved with extension '.mat', and must contain variable Y (3 dimensional grayscale recording), and Ysiz (3 dimensional vector, size(Y)).

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

