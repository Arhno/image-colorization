clc ; close all ; clear ;

% originalImage = 'Elephant_toColor2.jpg';
% 
% img = imread(originalImage);
% 
% figure
% imshow(img)
% 
% [fimg, flabels, modes, regsize, grad, conf] = edison_wrapper(img,@RGB2Luv,...
%        'SpatialBandWidth',8,'RangeBandWidth',4,...
%        'MinimumRegionArea',20000);
% 
% figure
% imshow(Luv2RGB(fimg));

load('ReferenceGerman');

flabels = double(flabels);

gx = flabels(1:end-1, 1:end-1) - flabels(1:end-1, 2:end);
gy = flabels(1:end-1, 1:end-1) - flabels(2:end, 1:end-1);
g = gx.^2+gy.^2;

segmentation = g>0;
segmentation = imdilate(segmentation,strel('square', 3));

imgSeg = ref_img;

imgSeg(1:end-1,1:end-1,1) = imgSeg(1:end-1,1:end-1,1) + uint8(255*(segmentation));

figure
imshow(imgSeg)

gr = rgb2gray(ref_img);
tic;
imgFeatures = get_features(gr);
toc

NTrees = 200;
[RF, knn, V] = createRF( imgFeatures, flabels, NTrees);

featureToPlot = reshape(imgFeatures,[],size(imgFeatures,3),1);
classes = flabels(:);
[classes, c_order] = sort(classes);
featureToPlot = featureToPlot(c_order,:);
cur_class = 1;
for k=2:length(classes);
    if classes(k)>classes(k-1)
        classes(k-1) = cur_class;
        cur_class = cur_class+1;
    else
        classes(k-1) = cur_class;
    end
end
classes(end) = cur_class;

%test with PCA
[~,~,V2] = svd(cov(featureToPlot));
V2 = V2(:,1:2);

featureToPlot = featureToPlot*V2;

figure
color = {'rx', 'bx', 'gx', 'kx', 'yx', 'cx'};
for k=1:max(classes)
    hold on
    plot(featureToPlot(classes==k,1), featureToPlot(classes==k,2), color{k});
end

%TEST ON GRAY IMAGE
aaaaaaa = 1
imgTest = imread('german_shepherd_1.jpg');
imgTest = rgb2gray(imgTest);
figure;
imshow(imgTest)
title('image to be colorized')

imgFeaturesTest = get_features(imgTest);

tic;
Y = testRF( RF, imgFeaturesTest, V );
toc
% tic
% Yknn = testKnn( knn, imgFeaturesTest );
% toc

Yresized = reshape(Y,size(imgTest));
Yimg = zeros([size(imgTest,1) size(imgTest,2) 3]);

for i =1:size(imgTest,1)
   for j = 1:size(imgTest,2)
       Yimg(i,j, :) = modes(:,str2num(Yresized{i,j})+1);
       %Yimg(i,j, :) = modes(:,Yresized(i,j)+1);
   end
end


figure
imshow(Luv2RGB(Yimg));

% 
% Yresized = reshape(Yknn,size(imgTest));
% Yimg = zeros(size(fimg));
% 
% for i =1:size(imgTest,1)
%    for j = 1:size(imgTest,2)
%        Yimg(i,j, :) = modes(:,Yresized(i,j)+1);
%    end
% end
% 
% 
% figure
% imshow(Luv2RGB(Yimg));



% figure
% imshow(conf, [0,1])
% 
% imgGray = rgb2gray(img);
% figure
% imshow(imgGray)
% 
% N = length(imgGray(:));
% 
% imgGray = double(cat(3, imgGray, imgGray, imgGray))/255;
% 
% labels = randi(N, 1, ceil(0.01*N));
% 
% imgGrayR = rgb2gray(img);
% imgGrayG = imgGrayR;
% imgGrayB = imgGrayR;
% 
% R = img(:,:,1);
% G = img(:,:,2);
% B = img(:,:,3);
% imgGrayR(labels) = R(labels);
% imgGrayG(labels) = G(labels);
% imgGrayB(labels) = B(labels);
% 
% imgLabel = double(cat(3, imgGrayR, imgGrayG, imgGrayB))/255;
% 
% colorized = colorizeFun(imgGray, imgLabel);
% 
% figure
% imshow(colorized);