clc ; close all ; clear ;

originalImage = 'Lake.jpg';

img = imread(originalImage);

figure
imshow(img)

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