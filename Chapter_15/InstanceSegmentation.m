% Input image
I = imread("input.jpg");
% Load pretrained Mask R-CNN (COCO)
detector = maskrcnn("resnet50-coco");
% Instance segmentation
[masks, labels, scores, bboxes] = segmentObjects(detector, I, ...
    "Threshold", 0.5);
% Keep only horses
isHorse = (labels == "horse");
% Combine all horse instance masks
horseMask = any(masks(:,:,isHorse), 3);
% Overlay color
overlay = labeloverlay(I, horseMask, "Transparency", 0.5);
% Display results
figure;
subplot(1,3,1); imshow(I);         title("Original");
subplot(1,3,2); imshow(horseMask); title("Horse Mask");
subplot(1,3,3); imshow(overlay);   title("Segmented Horses");
