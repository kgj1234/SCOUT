%Demo for background subtraction
%If required, this should generally be the first step in a pipeline

%Background subtraction can interfere with neural signals (at least on the simulated data),
%so we urge caution when using this procedure.

m=background_subtraction(fullfile('background_subtraction_data','vid1.mat'));

%Subtracted files are located in './background_subtraction_data/vid1_reg.mat'

%Background subtracted data can be used either to stabilize motion
%correction

load('./background_subtraction_data/vid1_reg.mat')
%background subtracted video
reg=uint8(reg*255/max(reg(:)));
%Original Video
orig=uint8(orig*255/max(max(max(orig))));
%motion correct background subtracted video, apply to original video
Y=runrigid3(reg,orig);
Ysiz=size(Y);
mkdir('./background_subtraction_data/motion_correction')
save('./background_subtraction_data/motion_correction/stabilized_vid1.mat','Y','Ysiz','-v7.3')



%Or you can use the background subtracted data in your analysis
load('./background_subtraction_data/vid1_reg.mat')
reg=uint8(reg*255/max(reg(:)));
Y=runrigid2(reg);
save('./background_subtraction_data/motion_correction/motion_corrected_nobg_vid1.mat','Y','Ysiz','-v7.3')

%Deleting the original background subtracted files saves space
delete('./background_subtraction_data/vid1_reg.mat','./background_subtraction_data/vid1_frame_all.mat');
