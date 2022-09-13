%% Color based image segmentation using LAB colorspace

function [BBOX, ProbabilityMatrix] = colorSegmentation(imLeft,dispFlag)
% 
% location = 'D:\Masters\2nd sem\CV\labtest_images';    % Load images   
% ds = imageDatastore(location);
BBOX = [];
ProbabilityMatrix = [];
centroids = [];
% while hasdata(ds)
    thisBBMain = [];
    Probability = [];
    i= imLeft;
    %figure, imshow(i);      
  
% Thresholding green image
     %Histogram Equalization
     % G=histeq(i);
   % Convert RGB image to chosen color space
      I = rgb2lab(i);

   % Define thresholds for channel 1 based on histogram settings
     channel1Min_g = 0.000;
     channel1Max_g = 91.607;

   % Define thresholds for channel 2 based on histogram settings
     channel2Min_g = -42.821;
     channel2Max_g = -12.425;

   % Define thresholds for channel 3 based on histogram settings
     channel3Min_g = -35.194;
     channel3Max_g = 35.045;

   % Create mask based on chosen histogram thresholds
   sliderBW_g = (I(:,:,1) >= channel1Min_g ) & (I(:,:,1) <= channel1Max_g) & ...
    (I(:,:,2) >= channel2Min_g ) & (I(:,:,2) <= channel2Max_g) & ...
    (I(:,:,3) >= channel3Min_g ) & (I(:,:,3) <= channel3Max_g);
   BW_g = sliderBW_g;
   %figure, imshow(BW_g);

   % Remove green image disturbances
     diskElem = strel('disk',5);
     out_g = imopen(BW_g,diskElem);
     out2_g= imfill(out_g,'holes');
     Ibwopen_g= bwmorph(out2_g,'dilate',7);
     %figure, imshow(Ibwopen_g);


% Thresholding red image

  % Define thresholds for channel 1 based on histogram settings
    channel1Min_r = 0.118;
    channel1Max_r = 90.095;

  % Define thresholds for channel 2 based on histogram settings
    channel2Min_r = 27.113;
    channel2Max_r = 52.285;

  % Define thresholds for channel 3 based on histogram settings
    channel3Min_r = -12.704;
    channel3Max_r = 48.219;

  % Create mask based on chosen histogram thresholds
    sliderBW_r = (I(:,:,1) >= channel1Min_r ) & (I(:,:,1) <= channel1Max_r) & ...
    (I(:,:,2) >= channel2Min_r ) & (I(:,:,2) <= channel2Max_r) & ...
    (I(:,:,3) >= channel3Min_r ) & (I(:,:,3) <= channel3Max_r);
     BW_r = sliderBW_r;
     %figure, imshow(BW_r);

  % Remove red image disturbances
    diskElem = strel('disk',3);
    out_r = imopen(BW_r,diskElem);
    out2_r= imfill(out_r,'holes');
    Ibwopen_r= bwmorph(out2_r,'dilate',7);
    %figure, imshow(Ibwopen_r);

% Cascading red and green images
    comb = i;
    abs_comb = i;
    combined = imsubtract(Ibwopen_r,Ibwopen_g);
    abs_c = abs(imsubtract(Ibwopen_r,Ibwopen_g));
    %figure, imshow(abs_c);

% Blob analysis
  f_image = logical(abs_c);
 bw_img=f_image;
 [bwLabel,num]=bwlabel(bw_img,8);
 num;
 s=regionprops(bw_img,'BoundingBox','Centroid','Area','Perimeter');
 if(dispFlag)
    figure, imshow(i);
    title('Detected Cans')
 end
 hold on;
 for k=1:num
     if s(k).Area>450
            thisBB = s(k).BoundingBox;
            P= s(k).Area/18;
            Probability = [Probability;P];
            cc= s(k).Centroid;
            area = s(k).Area;
            thisBBMain = [thisBBMain; thisBB];
            rectangle('Position',thisBB);
            centroids=s(k).Centroid;
            xCentroids = centroids(1:2:end);
            yCentroids = centroids(2:2:end);
            if(dispFlag)
                plot(xCentroids,yCentroids,'b*');
            end
    else
     end
 end
 BBOX = [BBOX; thisBBMain];
 ProbabilityMatrix = [ProbabilityMatrix; Probability];
 %centroids = centroids;
 %BBOX
hold off;
end
% end




    














