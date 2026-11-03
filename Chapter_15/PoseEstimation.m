% Input image
I = imread("person.png");
% Step 1: Human detection -> Load pretrained YOLO model
yd = yolov4ObjectDetector("csp-darknet53-coco"); % COCO: includes "person"
[b, scores, l] = detect(yd, I, "Threshold", 0.10); % detect boxes + scores + labels
b = b(string(l)=="person",:);        % keep only "person" boxes
[~, k] = max(b(:,3).*b(:,4));        % pick largest box (area)
bb = b(k,:);
% Step 2: Human pose estimation using HRNet for key point detection
kd = hrnetObjectKeypointDetector("human-full-body-w48");
[K,S] = detect(kd, I, bb);
P = K(:,:,1);
Sc = S(:,:,1);
thr = 0.5; % score threshold
ok = (Sc >= thr);
% Display results
imshow(I); hold on;
% Edges skipping face (6-17 based on COCO-17)
E = [6 7; 6 8; 8 10; 7 9; 9 11; 6 12; 7 13; 12 13; 12 14; 14 16; 13 15; 15 17];
for i = 1:size(E,1)
    a = E(i,1); b2 = E(i,2);
    if ok(a) && ok(b2) % only if both points are good
        plot(P([a b2],1), P([a b2],2), "-", "LineWidth", 3); % draw line
    end
end
for j = 6:17
    if ok(j)
        scatter(P(j,1), P(j,2), 40, "w", "filled", ... % draw dot
            "MarkerEdgeColor","k", "LineWidth", 2);
    end
end
hold off;        