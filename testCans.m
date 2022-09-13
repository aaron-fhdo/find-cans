
load zedParameters
show = 1;
certainty = 85;
im = imread('im2obj.png');

im_size = size(im);
imLeft = im(:,1:im_size(2)/2,:);
imRight = im(:,im_size(2)/2+1:im_size(2),:);

[imLeftRect, imRightRect, reprojectionMatrix] = ...
    rectifyStereoImages(imLeft, imRight, stereoParams);

figure
imshow(stereoAnaglyph(imLeftRect, imRightRect))
title('Rectified Images')

% Detect cans
bboxes = colorSegmentation(imLeftRect, 1);

P_robot = depthEstCans(imLeftRect, imRightRect, reprojectionMatrix, bboxes, certainty, show);