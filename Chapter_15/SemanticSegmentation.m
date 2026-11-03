% Thresholds
minPixels = 1e4;  topK = 4; 
% Input image
I = imread("person.jpg");
% Load pretrained BiSeNet V2
[net, allClasses] = bisenetv2();
netInput = net.Layers(1).InputSize(1:2);
% Semantic segmentation 
labels = imresize( semanticseg(imresize(I,netInput), net, Classes=allClasses), size(I,[1 2]), "nearest");
classNames  = categories(removecats(labels));
pixelCounts = cellfun(@(c) nnz(labels==c), classNames);
% Sorting classes with highest pixels (largest categories) and selecting top K
idx = find(pixelCounts >= minPixels); 
[~,ord] = sort(pixelCounts(idx), "descend");
idx = idx(ord(1:min(topK,numel(ord))));
% Extracting number of classes, their names, and corresponding pixel counts
classNames = classNames(idx);  pixelCounts = pixelCounts(idx); numClasses = numel(classNames);
% Overlay color
classIndexImage = zeros(size(labels),"uint16");
for k = 1:numClasses, classIndexImage(labels == classNames{k}) = k; end
overlay = labeloverlay(I, classIndexImage, Colormap = lines(numClasses));
% Display results
figure("Color","w"); imshow(overlay); title("Semantic Segmentation"); hold on
h = gobjects(numClasses,1);
classColors = lines(max(numClasses,1));
for k=1:numClasses
    h(k)=plot(nan,nan,'s','MarkerSize',10,'MarkerFaceColor',classColors(k,:),'MarkerEdgeColor','k');
end
legend(h, strcat(classNames," (",string(pixelCounts)," px)"), Location="bestoutside");

