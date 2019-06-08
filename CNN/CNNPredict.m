Directory = uigetdir('C:\');
imds = imageDatastore(Directory,'IncludeSubfolders',true);
inputSize = [256 256 3];
augimds = augmentedImageDatastore(inputSize(1:2),imds);
YPred = predict(net,augimds)