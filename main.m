clc ; close all ; clear ;

originalImage = 'Lake.jpg';

img = imread(originalImage);

figure
imshow(img)

[fimg labels modes regsize grad conf] = edison_wrapper(img,@RGB2Luv,...
       'SpatialBandWidth',8,'RangeBandWidth',4,...
       'MinimumRegionArea',10000);

figure
imshow(Luv2RGB(fimg));

imgGray = rgb2gray(img);
figure
imshow(imgGray)

N = length(imgGray(:));

imgGray = double(cat(3, imgGray, imgGray, imgGray))/255;

labels = randi(N, 1, ceil(0.01*N));

imgGrayR = rgb2gray(img);
imgGrayG = imgGrayR;
imgGrayB = imgGrayR;

R = img(:,:,1);
G = img(:,:,2);
B = img(:,:,3);
imgGrayR(labels) = R(labels);
imgGrayG(labels) = G(labels);
imgGrayB(labels) = B(labels);

imgLabel = double(cat(3, imgGrayR, imgGrayG, imgGrayB))/255;

colorized = colorizeFun(imgGray, imgLabel);

figure
imshow(colorized);