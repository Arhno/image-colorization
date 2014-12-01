clear all
close all
clc

segmentedImage = zeros(1080, 2500);
featureImage = zeros(1080, 2500, 50);

segmentedImage = [1,1,1,1;2,2,2,2];
featureImage = zeros(2,4,10);

featureImage(1,1,:) = 1*ones(1,10);
featureImage(1,2,:) = 0.5*ones(1,10);
featureImage(1,3,:) = 2*ones(1,10);
featureImage(1,4,:) = 1.5*ones(1,10);
featureImage(2,1,:) = 7*ones(1,10);
featureImage(2,2,:) = 8.5*ones(1,10);
featureImage(2,3,:) = 8*ones(1,10);
featureImage(2,4,:) = 7.5*ones(1,10);

%reshaping featureImage into a 2D array:
featureVector = reshape(featureImage,[],size(featureImage,3),1);

NTrees = 100;
RF = TreeBagger(NTrees, featureVector, segmentedImage(:),'OOBPred','On');

oobErrorBaggedEnsemble = oobError(RF);
plot(oobErrorBaggedEnsemble)
xlabel 'Number of grown trees';
ylabel 'Out-of-bag classification error';


test = zeros(3,10);
test(1,:) = 9*ones(1,10);
test(2,:) = 3*ones(1,10);
test(3,:) = 0*ones(1,10);

Y = predict(RF,test)