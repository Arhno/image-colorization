function [ V] = LDA( features, classes )

features = reshape(features,[],size(features,3),1);
classes = classes(:);

Nclasses = max(classes)-min(classes)+1;
Nfeatures = size(features,2);


if min(classes)==0
    classes = classes+1; 
end


[classes, c_order] = sort(classes);
features = features(c_order,:);



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
V = V(:,1:Nclasses-1);

end

