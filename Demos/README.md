## Demos

Demos have been tested on Linux and Windows

extraction_wrapper_demo.m requires a '.mat' file. Motion correction saves
the result as '.mat', and accepts avi, tif, mat extensions. 

full_pipeline_demo works with avi, tif, mat extensions

## Available Demos

demo_preprocessing.m: This demonstrates the code for motion correction using NorMCorre. A folder is created and motion corrected recordings are saved in the folder. 

Session_Registration_Demo.m: This demonstrates session registration as a preprocessing step. Recordings are saved in the base directory with the extension '_registered.mat'. (These should be deleted are moved before testing other demos)

extraction_1p_demo.m: Demonstrates code for 1-photon recording extraction. The output is neuron (Sources2D object)

extraction_2p_demo.m: (This does not have a spatial filter yet)

extraction_wrapper_demo.m: Demonstrates the extraction wrapper, which allows specification of fewer variables, and is easy to use. Output is neuron (Sources2D object)

Cell_Tracking_Demo.m: Demonstrates cell tracking on recordings in the current directory. Saves neuron (Sources2D) object containing neural tracking data, as SCOUT_neuron.mat in the extraction folder.

full_pipeline_demo.m: Demonstrates full data processing pipeline (excluding interactive session registration). Saves neuron (Sources2D) object containing neural tracking data as SCOUT_neuron.mat in the extraction folder.





