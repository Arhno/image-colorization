function [ V] = LDA( features, classes )

features = reshape(features,[],size(features,3),1);
classes = classes(:);

[classes, c_order] = sort(classes);
features = features(c_order,:);

% Renumber the classes to be from 1 to the number of classes
Nclasses = 1;
cur_class = 1;
for k=2:length(classes);
    if classes(k)>classes(k-1)
        Nclasses = Nclasses+1;
        classes(k-1) = cur_class;
        cur_class = cur_class+1;
    else
        classes(k-1) = cur_class;
    end
end
classes(end) = cur_class;
max(classes)

Nfeatures = size(features,2);


if min(classes)==0
    classes = classes+1; 
end

%compute means
classMeans = zeros(Nclasses, Nfeatures);
for i = 1:Nclasses
   classMeans(i,:) = mean(features(classes ==i,:));
end

%compute global covariance
m = [];
for i =1:Nclasses
   m = [m; ones(sum(classes ==i),1)*classMeans(i,:)];
end

globalCov = cov(features-m);

% compute inter class covariance
classCov = zeros(size(features,2));

for i = 1:Nclasses
    classCov = classCov + (classMeans(i,:)-mean(classMeans))'*(classMeans(i,:)-mean(classMeans));
end

classCov = classCov/Nclasses;

[U,~,V] = svd(pinv(globalCov)*classCov);

%columns of V are the eigenvectors
V = V(:,1:(2*Nclasses));


% %test with PCA
% [~,~,V] = svd(cov(features));
% V = V(:,1:15);

end

