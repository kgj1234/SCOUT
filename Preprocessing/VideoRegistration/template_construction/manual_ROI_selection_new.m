function [x1,y1,x2,y2]=manual_ROI_selection_new(image1,image2)

close all
imagesc(image1)
colormap gray
figure()
imagesc(image2)
colormap gray
im=figure();
subplot(1,2,1)
imagesc(image1)
daspect([1,1,1])
colormap gray
subplot(1,2,2)
imagesc(image2)
daspect([1,1,1])
colormap gray

x1=[];
y1=[];
x2=[];
y2=[];
while true
    subplot(1,2,1)
    [x1,y1] = ginput(8);
    
    imagesc(image1);
    daspect([1,1,1])
    colormap gray
    subplot(1,2,2)
    [x2,y2]=ginput(8);
    imagesc(image2)
    daspect([1,1,1])
    colormap gray
    done=input('Select Another Feature: y/n ','s');
    if isequal(done,'n')
        break
    end
end
close all


end
    
    