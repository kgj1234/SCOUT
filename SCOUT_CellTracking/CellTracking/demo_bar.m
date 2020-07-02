function []=demo();
display_progress_bar('demo',false);

for i=1:10
    a=2^i+1-10;
    display_progress_bar(i/10*100,false);
end
display_progress_bar('Completed',false);