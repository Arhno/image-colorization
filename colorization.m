%Just have to call colorization(Yresized,modes) after the main has been
%executed and change the two images.img is the reference image and img2 is the grayscale image.

function [] = colorization(Yresized, modes)
    
    img = imread('rsz_2baby2.png');
    img2 = imread('Baby.png');
    imgGray = rgb2gray(img);
    imgGray2 = rgb2gray(img2);
    [n,m,p] = size(img);

    %Extracting Image Features
    RGB_features = get_features(imgGray);
    gray_features = get_features(imgGray2);
    [n2,m2,k] = size(gray_features);

    %Segmentation of the image using Mean Shift
    [fimg labels modes2 regsize grad conf] = edison_wrapper(img,@RGB2Luv,...
           'SpatialBandWidth',8,'RangeBandWidth',4,...
           'MinimumRegionArea',10000); 

    %I am using yresized and modes from the main   
    labels2 = cellfun(@str2num,Yresized);
    labels2 = int32(labels2);
    [num1 num] = size(modes);

    regsize2 = zeros(1,num); 
    for i=1:1:n2
        for j=1:1:m2
            regsize2(labels2(i,j)+1)  = regsize2(labels2(i,j)+1) + 1;
        end
    end

    tic
    %Sorting the RGB image features based on segments
    number_segments = size(regsize,2);
    RGB_sorted_features = zeros(number_segments,max(regsize),k+2);
    count = ones(1,number_segments);
    count = int32(count);
    for i=1:1:n
        for j=1:1:m
            RGB_sorted_features(labels(i,j)+1,count(labels(i,j)+1),1:k) = RGB_features(i,j,1:k); 
            RGB_sorted_features(labels(i,j)+1,count(labels(i,j)+1),k+1) = i;
            RGB_sorted_features(labels(i,j)+1,count(labels(i,j)+1),k+2) = j;
            count(labels(i,j)+1) = count(labels(i,j)+1) + 1;
        end
    end

    regsize2 = int32(regsize2);
    number_segments = size(regsize2,2);
    gray_sorted_features = zeros(number_segments,max(regsize2),k+2);
    count1 = ones(1,number_segments);
    count1 = int32(count1);
    for i=1:1:n2
        for j=1:1:m2
            gray_sorted_features(labels2(i,j)+1,count1(labels2(i,j)+1),1:k) = gray_features(i,j,1:k); 
            gray_sorted_features(labels2(i,j)+1,count1(labels2(i,j)+1),k+1) = i;
            gray_sorted_features(labels2(i,j)+1,count1(labels2(i,j)+1),k+2) = j;
            count1(labels2(i,j)+1) = count1(labels2(i,j)+1) + 1;
        end
    end

    %Calculation of nearest neighbours
    nearest_neigh = zeros(n2,m2,3);
    nearest_neigh(:,:,3) = bitmax;
    [size1 size2] = size(regsize2);

    for i=1:1:size2
        disp(i);
        count = regsize2(i);
        limit = ceil(0.01*count);
        r = randi([1 count],1,limit);
        for j=1:1:limit
            r1 = gray_sorted_features(i,r(j),k+1);
            r2 = gray_sorted_features(i,r(j),k+2);
            if r1~=0 && r2~=0
                label = labels2(r1,r2) + 1;
                number = regsize(label);
                distance = zeros(1,number);

                A = zeros(1,k);
                A(1:k) = gray_features(r1,r2,1:k);
                B = repmat(A,number,1);
                C(1:number,1:k) = RGB_sorted_features(label,1:number,1:k);

                distance(1:number) = sum((B(1:number,1:k) - C(1:number,1:k)).*(B(1:number,1:k) - C(1:number,1:k)),2);
                [distance, ind] = sort(distance, 'ascend');

                nearest_neigh(r1,r2,1) = RGB_sorted_features(label,ind(1),k+1);
                nearest_neigh(r1,r2,2) = RGB_sorted_features(label,ind(1),k+2);
                nearest_neigh(r1,r2,3) = distance(1);  
            end
        end
    end

    %Calculation of weights
    weights = zeros(n2,m2);
    for i=4:1:(n2-3)
        for j=4:1:(m2-3)
           a = exp(-double(nearest_neigh(i,j,3)));
           b = ((sum(sum(exp(-nearest_neigh(i-3:i+3,j-3:j+3,3)),1),2)));
           if b~=0
                weights(i,j) = double(a)/b;
           else
               weights(i,j) = double(0);
           end
        end
    end

    for i=1:1:n2
        for j=1:1:m2
            if(nearest_neigh(i,j,1)==0)
                nearest_neigh(i,j,1) = 20;
                nearest_neigh(i,j,2) = 20;
                nearest_neigh(i,j,3) = -20;
            end
        end
    end

    %Transferring Color to the Image
    N = length(imgGray2(:));

    imgGrayR = rgb2gray(img2);
    imgGrayG = imgGrayR;
    imgGrayB = imgGrayR;

    for i=4:1:(n2-4)
        for j=4:1:(m2-4)
            label = labels2(i,j) + 1;
            label = repmat(label,1,7);

            a = nearest_neigh(i-3:1:i+3,j-3:1:j+3,1);
            b = nearest_neigh(i-3:1:i+3,j-3:1:j+3,2);
            c = double(~bsxfun(@eq,nearest_neigh(i-3:1:i+3,j-3:1:j+3,3),-20));
            d = zeros(7,7,3);
            for X=1:1:7
                for Y=1:1:7
                    if a(X,Y)>(X-4) && b(X,Y)>(Y-4) && a(X,Y)-(X-4)<n2 && b(X,Y)-(Y-4)<m2
                        d(X,Y,:) = img(a(X,Y)-(X-4),b(X,Y)-(Y-4),:);
                    end
                end
            end
            imgGrayR(i,j) = sum(sum(c.*double(bsxfun(@eq,labels2(i-3:1:i+3,j-3:1:j+3),label-1)).*double(weights(i-3:1:i+3,j-3:1:j+3)).*double(d(1:1:7,1:1:7,1)),1),2);
            imgGrayG(i,j) = sum(sum(c.*double(bsxfun(@eq,labels2(i-3:1:i+3,j-3:1:j+3),label-1)).*double(weights(i-3:1:i+3,j-3:1:j+3)).*double(d(1:1:7,1:1:7,2)),1),2);
            imgGrayB(i,j) = sum(sum(c.*double(bsxfun(@eq,labels2(i-3:1:i+3,j-3:1:j+3),label-1)).*double(weights(i-3:1:i+3,j-3:1:j+3)).*double(d(1:1:7,1:1:7,3)),1),2);

            if (imgGrayR(i,j)==0 || imgGrayG(i,j)==0 || imgGrayB(i,j)==0)
                imgGrayR(i,j) = imgGray2(i,j);
                imgGrayG(i,j) = imgGray2(i,j);
                imgGrayB(i,j) = imgGray2(i,j);
            end
        end
    end

    %Levin Algorithm
    %Have to modify this imgLabel in order to colorize the image
    imgGray = double(cat(3, imgGray2, imgGray2, imgGray2))/255;
    imgLabel = double(cat(3, imgGrayR, imgGrayG, imgGrayB))/255;
    colorized = colorizeFun(imgGray, imgLabel);
    figure
    imshow(colorized);
    toc;
    
end

