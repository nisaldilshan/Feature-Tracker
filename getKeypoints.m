function [keyXs, keyYs] = getKeypoints(im,tau)
sigma = 3;
k = 0.06;

gaussian = fspecial('gaussian',ceil(6*sigma),sigma);
im = imfilter(im,gaussian);

%%Find Ix and Iy with smoothing
dx =[-1 0 1   ; -1 0 1 ; -1 0 1];
dy =[-1 -1 -1 ; 0 0 0  ; 1 1 1 ];

Ix = imfilter(im,dx);
Iy = imfilter(im,dy);

%%finding gaussian filtered Ixx Iyy and Ixy
Ixx = imfilter(Ix.*Ix,gaussian);
Iyy = imfilter(Iy.*Iy,gaussian);
Ixy = imfilter(Ix.*Iy,gaussian);

%Corner response function
R= (Ixx.*Iyy - Ixy.^2) - k*(Ixx + Iyy).^2;

%compute the local maxima of R above a threshold 5-by-5 windows
corners = ordfilt2(R, 25, ones(5));
mask = (R == corners) & (R > tau) ;
corners = mask.*R;

[keyYs, keyXs] = find(corners>0);

figure;
imshow(im); hold on
plot(keyXs,keyYs,'g*', 'MarkerSize',3);title('DetectedCorners');
saveas(gcf,'output/DetectedCorners.jpg');
end