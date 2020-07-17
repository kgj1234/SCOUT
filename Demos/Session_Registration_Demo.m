%% Preprocessing Session Registration Demo

% Allows for interactive session registration using several methods
%Aligns all video files in the current folder (requires '.mat' extension)

%n-no y-yes m-manual

%inputs
%use_non_rigid (boo) use non-rigid session registration
%base_index (int) state which recording forms the base reference image
%projection_type (str) options 'max','correlation'

use_non_rigid=true;
base_index=2;
projection_type='max';

video_registration_main(use_non_rigid,base_index,projection_type);

%Resulting videos are saved with extension '_registered.mat'
