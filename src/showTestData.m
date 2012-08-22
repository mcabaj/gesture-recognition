figure;
load('learnData.mat');
load('targetData.mat');

for i=1:15
    name='';
    if(Target(1,i) == 1)
        name = 'Fist';
    elseif(Target(2,i) == 1)
        name = 'Open hand';
    else
        name = 'Scissors';
    end
    subplot(3,5,i); imshow(Img(:,:,i)); title(name); 
end