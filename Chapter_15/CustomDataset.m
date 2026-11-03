% Paths
sourceDir = fullfile(pwd, 'Deer');  % Folder with all images
trainDir  = fullfile(pwd, 'DeerDataset', 'images', 'train'); % /DeerDataset/images/train
valDir    = fullfile(pwd, 'DeerDataset', 'images', 'val'); % /DeerDataset/images/val
% Create folders if they don't exist
if ~exist(trainDir, 'dir'), mkdir(trainDir); end
if ~exist(valDir, 'dir'), mkdir(valDir); end
% Get image list
imgExt = {'*.jpg','*.jpeg','*.png'};
imageFiles = [];
for i = 1:numel(imgExt)
    imageFiles = [imageFiles; dir(fullfile(sourceDir, imgExt{i}))];
end
numImages = numel(imageFiles);
idx = randperm(numImages);
% 80/20 split
numTrain = round(0.8 * numImages);
trainIdx = idx(1:numTrain);
valIdx   = idx(numTrain+1:end);
% Copy training images
for k = 1:numTrain
    i = trainIdx(k);
    [~,~,ext] = fileparts(imageFiles(i).name);
    newName = sprintf('train_%05d%s', k, ext);
    copyfile(fullfile(sourceDir, imageFiles(i).name), fullfile(trainDir, newName), 'f');
end
% Copy validation images
for k = 1:numel(valIdx)
    i = valIdx(k);
    [~,~,ext] = fileparts(imageFiles(i).name);
    newName = sprintf('val_%05d%s', k, ext);
    copyfile(fullfile(sourceDir, imageFiles(i).name), fullfile(valDir, newName), 'f');
end
fprintf('Done!\nTrain images: %d\nVal images: %d\n',numTrain, numImages - numTrain);
