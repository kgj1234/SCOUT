function [image1_ROI,image2_ROI]=manual_ROI_selection(image1,image2)
image1_ROI=logical(zeros(size(image1)));
image2_ROI=logical(zeros(size(image2)));
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
image1_ROI={};
image2_ROI={};

while true
    subplot(1,2,1)
    h = imfreehand();
    wait(h);
    image1_ROI{end+1}=createMask(h);
    %vert=uint64(getVertices(h));
    %vert=sub2ind(size(image1),vert(:,2),vert(:,1));
    %image1(vert)=max(max(image1));
    %image1=max(image1,max(image1,[],'all')*double(createMask(h))+20);
    imagesc(image1);
    daspect([1,1,1])
    colormap gray
    subplot(1,2,2)
    h = imfreehand();
    wait(h)
    image2_ROI{end+1}=createMask(h);
    %vert=uint64(getVertices(h));
    %vert=sub2ind(size(image2),vert(:,2),vert(:,1));
    %image2(vert)=max(max(image2));
    %image2=max(image2,max(image2,[],'all')*double(createMask(h))+20);
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
    
    