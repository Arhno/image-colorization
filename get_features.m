function [ features ] = get_features( luminance_img )
%get_features Compute texture features for each pixels
%   return h x w x k matrix where [h,w] = size(luminance_img) and k is the
%   number of features.
    
    luminance_img = im2double(luminance_img);
    [h,w] = size(luminance_img);
    
    % LM filter bank
    filters = makeLMfilters();
    nb_filters = size(filters,3)
    
    % size of the DCT window
    K = 5;
    
    % Initialize the feature matrix
    features = zeros(h,w,nb_filters+K*K);
    
    % Compute the LM
    for k=1:nb_filters
        features(:,:,k) = ...
            imfilter(luminance_img, filters(:,:,k), 'symmetric');
    end
    
%     % Compute the DCT feature
%     r = floor(K/2);
%     % create border
%     extended = zeros(h+2*r, w+2*r);
%     extended((r+1):(end-r), (r+1):(end-r)) = luminance_img;
%     for k=1:r
%         extended(k, :) = extended(K-k+1, :);
%         extended(end+1-k, :) = extended(end+1-(K-k+1), :);
%     end
%     for k=1:r
%         extended(:, k) = extended(:, K-k+1);
%         extended(:, end+1-k) = extended(:, end+1-(K-k+1));
%     end
%     % actual computation
%     for i=1:h
%         for j=1:w
%             x = j+r;
%             y = i+r;
%             roi = extended((y-r):(y+r),(x-r):(x+r));
%             dct_coeff = dct2(roi);
%             features(i,j,(nb_filters+1):end) = dct_coeff(:)';
%         end
%     end
end

