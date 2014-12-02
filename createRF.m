function [ RF, knn, V ] = createRF( imgFeatures, labels, NTrees )

%reshaping featureImage into a 2D array:
featureVector = reshape(imgFeatures,[],size(imgFeatures,3),1);
labels = labels(:);

V = LDA( imgFeatures, labels );

newFeat = featureVector*V;
featuresSubSample = newFeat(1:1:end, :);
labelsSubSample = labels(1:1:end);

RF = TreeBagger(NTrees, featuresSubSample, labelsSubSample,'OOBPred','On',  'NPrint', 1);
%RF = ClassificationTree.fit(featuresSubSample, labelsSubSample);
%RF = fitensemble(featuresSubSample, labelsSubSample, 'AdaBoostM2',NTrees,'Tree');
knn = ClassificationKNN.fit(featuresSubSample,labelsSubSample,'NumNeighbors', 11);
figure
oobErrorBaggedEnsemble = oobError(RF);
plot(oobErrorBaggedEnsemble)
xlabel 'Number of grown trees';
ylabel 'Out-of-bag classification error';

end

