function [A1_comp,A2_comp]=construct_comparison_footprint_ellipse_old(A1,centroid,data_shape)
    A1=reshape(A1,data_shape);
    bw=A1>0;
    CC=bwconncomp(bw);
    stats=CC.PixelIdxList;
    curr_rem_ind=[];
    num_elements=[];
    for l=1:length(stats)
        num_elements(l)=length(stats{l});
    end
    for l=1:length(stats)
        if length(stats{l})~=max(num_elements)
            curr_rem_ind=[curr_rem_ind;stats{l}];
        end
    end
    A2=A1;
    A2(curr_rem_ind)=0;
    bw=A2>0;
    stats= regionprops(full(bw),'MajorAxisLength','MinorAxisLength','Orientation');
    MajorAxisLength=stats.MajorAxisLength;
    
    MinorAxisLength=stats.MinorAxisLength;
   
    Orientation=stats.Orientation;
   
    %Estimate appropriate power to use
    x=round(MajorAxisLength*cos(Orientation*pi/180));
    y=round(MajorAxisLength*sin(Orientation*pi/180));
    edge_vec=centroid+[x,y];
    x_coord=[centroid(1),edge_vec(1)];
    y_coord=[centroid(2),edge_vec(2)];
    c = improfile(A1,x_coord,y_coord);
    
    c=c/max(c);
    c(c==0)=[];
    c(isnan(c))=[];
    x=2;
    try
        val=c(3);
    
    
        n=log(val)/(log(1-x/(length(c)-1)));
        n=real(n);
    catch
        n=0;
    end
    if n>.99
        n=.99;
    elseif n<.3
        n=.3;
    end
    
    A1_comp=plot_ellipse((MajorAxisLength/2),(MinorAxisLength/2),n,Orientation*pi/180,centroid,data_shape);
    A2_comp=plot_ellipse((MajorAxisLength/2),(MinorAxisLength/2),n,Orientation*pi/180+pi/2,centroid,data_shape);
    