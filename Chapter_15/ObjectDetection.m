% Input image
I = imread("horse.jpg");
% Load pretrained YOLOV4 trained on COCO dataset
detector = yolov4ObjectDetector("csp-darknet53-coco");
% Object detection
[bboxes, scores, labels] = detect(detector, I, "Threshold", 0.5);
% Display results (bounding boxes with labels and scores)
Iout = insertObjectAnnotation(I, "rectangle", bboxes, ...
    compose("%s: %.2f", labels, scores), ...
    "FontSize", 36, ...
    "LineWidth", 4);
imshow(Iout)          
