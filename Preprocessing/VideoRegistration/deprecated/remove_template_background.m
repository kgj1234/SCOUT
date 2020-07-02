function template=remove_template_background(template)
se=strel('disk',10);
background = imopen(double(template),se);
template=template-background;

%template=adapthisteq(template);


