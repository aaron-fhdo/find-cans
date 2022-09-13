function [P_camera] = depthEstCans(imLeftRect, imRightRect, reprojectionMatrix, bboxes, certainty, show)
% Depth Estimation From Stereo Images

disparityMap = disparitySGM(rgb2gray(imLeftRect), rgb2gray(imRightRect));
points3D = reconstructScene(disparityMap, reprojectionMatrix);

% Threshold point cloud to remove noise
th = [-1000 1000;-500 500;0 2000];
points3D = thresholdPC(points3D,th);

% Convert to meters and create a pointCloud object
points3D = points3D ./ 1000;

% Find the centroids of detected people.
centroids = [round(bboxes(:, 1) + bboxes(:, 3) / 2), ...
    round(bboxes(:, 2) + bboxes(:, 4) / 2)];

% Find the 3-D world coordinates of the centroids.
centroidsIdx = sub2ind(size(disparityMap), centroids(:, 2), centroids(:, 1));
X = points3D(:, :, 1);
Y = points3D(:, :, 2);
Z = points3D(:, :, 3);

centroids3D = [X(centroidsIdx)'; Y(centroidsIdx)'; Z(centroidsIdx)'];
[min_centroid i] = min(centroids3D(3,:));
centroids3D = centroids3D(:,i);

P_camera = [X(centroidsIdx)'; Z(centroidsIdx)'; -Y(centroidsIdx)'];
[min_obj i] = min(P_camera(2,:));
P_camera = P_camera(:,i);
bboxes = bboxes(i,:);
certainty = certainty(i);

% Heterogeneous Transformation Matrix for Camera and Robot
T_camera = transl(0,0,0);
T_robot = transl(0,-0.306,0);
P_robot = h2e(inv(T_robot)*e2h(P_camera))

% Find the distances from the camera in meters.
dists = sqrt(sum(centroids3D .^ 2));
    
% Display the detected can and the distance.
labels = cell(1, numel(dists));
for i = 1:numel(dists)
    labels{i} = sprintf('%0.2f m (%0.2f, %0.2f, %0.2f) %0.2f%%', dists(i), P_robot(1,i), P_robot(2,i), P_robot(3,i), certainty);
end

% create mask
size_im = size(imLeftRect);
depthTol = 0.5;
tol = 0;
x1 = [bboxes(1,1)+tol bboxes(1,1)+bboxes(1,3)-tol bboxes(1,1)+bboxes(1,3)-tol bboxes(1,1)+tol bboxes(1,1)+tol];
y1 = [bboxes(1,2)+tol bboxes(1,2)+tol bboxes(1,2)+bboxes(1,4)-tol bboxes(1,2)+bboxes(1,4)-tol bboxes(1,2)+tol];
bw = poly2mask(x1,y1,size_im(1),size_im(2));
zlow1 = P_camera(2, 1) - depthTol;
zhigh1 = P_camera(2, 1) + depthTol;
idx = (Z > zlow1 & Z < zhigh1) & bw;

% apply mask
mask = repmat(idx,[1 1 3]);
I = imLeftRect;
I(~mask) = 0;

if show
    
    figure
    imshow(disparityMap, [0, 64])
    title('Disparity Map')
    colormap jet
    colorbar
    
    figure
    pcshow(points3D, imLeftRect)
    view([0 -90])
    xlabel('x')
    ylabel('y')
    zlabel('z')
    title('Point Cloud')
    
    figure
    imshow(insertObjectAnnotation(imLeftRect, 'rectangle', bboxes, labels));
    title('Detected Can')
    
    figure
    imshow(idx)
    title('Binary Mask')
    
    figure
    imshow(I)
    title('Extraction based on depth')

    figure
    points3D(:, :, 2) = Z;
    points3D(:, :, 3) = -Y;
    pcshow(points3D, imLeftRect)
    hold on
    trplot(T_camera,'frame','C','color','b')
    hold on
    trplot(T_robot,'frame','R','color','r')
    axis equal; axis([-1 1 -0.5 2 -0.5 0.5])
    view([5 30])
    hold on
    plot3(P_camera(1,:), P_camera(2,:), P_camera(3,:),'yx')
    title('Coordinate Frames')

end
end