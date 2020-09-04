function del_ind=create_neuron_figure(neuron);
%% Contour image
fig1=figure();
temp=neuron.copy();
temp.A=neuron.A(:,end:-1:1);
temp.C=neuron.C(end:-1:1,:);
try
    plot_contours_07202020(temp.A,max(reshape(temp.A,neuron.imageSize(1),neuron.imageSize(2),[]),[],3),[],1,[],[], [], []);
end
%% Create figure



screensize=get(0,'ScreenSize');
screensize(1)=screensize(1)+round(.1*screensize(3));
screensize(2)=screensize(2)+round(.1*screensize(4));

screensize(3)=screensize(3)-round(.2*screensize(3));
screensize(4)=screensize(4)-round(.2*screensize(4));
fig=uifigure('Position',screensize+[0,0,0,screensize(4)*.03],'Name','Select Bad Neurons');
screensize(4)=screensize(4)-30;
%% Get Checkbox Size
dpi = java.awt.Toolkit.getDefaultToolkit().getScreenResolution();
if dpi < 120
  h = 15;
elseif dpi < 144
  h = 18;
else
  h = 22;
end


%% Subdivide figure

num_neurons=size(neuron.C,1);
num_gaps=num_neurons+1;
vert_gap_height=screensize(4)/(num_gaps+3*num_neurons);
vert_button_offset=round(3*vert_gap_height/2-h/2);

horz_gap=.025*screensize(3);
button_width=round(.05*screensize(3));
spatial_width=vert_gap_height*3;
signal_width=screensize(3)-horz_gap*7-button_width;
horz_button_offset=round(button_width/2-h/2);


for k=1:num_neurons
    uilabel(fig,'Text',num2str(num_neurons-k+1),'FontSize',12,'Position',[horz_gap,...
        screensize(4)*.06+vert_gap_height+vert_button_offset+(k-1)*4*vert_gap_height,h,h])
    cbx(k)=uicheckbox(fig, 'Text','','Value', 0,'Position',[horz_button_offset+horz_gap,...
        screensize(4)*.06+vert_gap_height+vert_button_offset+(k-1)*4*vert_gap_height,h,h]);
   
    ax = uiaxes(fig,'Position',[horz_gap*2+button_width,screensize(4)*.06+vert_gap_height+4*(k-1)*vert_gap_height,...
        signal_width, 3*vert_gap_height]);
    plot(ax, neuron.C(k,:))
    ax.XTick=[];
    ax.YTick=[];
    box(ax,'off')
    
    
    ax=uiaxes(fig,'Position',[horz_gap*3+button_width+signal_width,...
        screensize(4)*.06+vert_gap_height+4*(k-1)*vert_gap_height, spatial_width, 3*vert_gap_height]);
    A1=reshape(neuron.A(:,k),neuron.imageSize(1),neuron.imageSize(2));
  
    [a,b]=find(A1>0);
    min_y=max(1,min(a)-5);
    max_y=min(size(A1,1),max(a)+5);
    
    min_x=max(1,min(b)-5);
    max_x=min(size(A1,2),max(b)+5);
    
    
    imagesc(A1(min_y:max_y,min_x:max_x),'Parent',ax);
    %ax.DataAspectRatio=[1,1,1];
    ax.XTick=[];
    ax.YTick=[];
    box(ax,'off')
    set(ax,'visible','off');
    
end
submit_y=.03*screensize(4);
submit_x=horz_gap;
btn=uibutton(fig,'push','Text', 'Submit','Position',[submit_x,submit_y,60,.04*screensize(4)],...
    'ButtonPushedFcn',{@Submit,fig});
uiwait(fig);

del_ind=[];
for k=1:num_neurons
    if cbx(k).Value==1
        del_ind(end+1)=k;
    end
end
close(fig)
close(fig1)
end

function Submit(btn,EventData,fig)
    uiresume(fig);
end




