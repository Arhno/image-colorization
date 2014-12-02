clc ; close all ; clear ;

originalImage = 'Elephant_toColor.jpg';

ref_img = imread(originalImage);

figure
imshow(ref_img)

[fimg, flabels, modes, regsize, grad, conf] = edison_wrapper(ref_img,@RGB2Luv,...
       'SpatialBandWidth',8,'RangeBandWidth',1,...
       'MinimumRegionArea',5000);

segmented_img = fimg;
figure(2)
imshow(Luv2RGB(segmented_img));
    
again = true;

while again
    h = impoly();

    to_merge = round(wait(h));

    merge_to_label = flabels(to_merge(1, 2), to_merge(1, 1));

    for k=1:length(to_merge)
        flabels(...
            flabels == flabels(to_merge(k, 2), to_merge(k, 1))) = ...
            merge_to_label;
    end

    for i =1:size(segmented_img,1)
       for j = 1:size(segmented_img,2)
           segmented_img(i,j, :) = modes(:,flabels(i,j)+1);
       end
    end

    figure(2)
    imshow(Luv2RGB(segmented_img));
    
    choice = questdlg('Again?', ...
	'Again', ...
	'Yes','No','Yes');

    again = strcmp(choice,'Yes');
end

save('Reference', 'ref_img', 'flabels', 'modes');