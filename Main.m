close all;
clc;
%%Read First Frame
initial_frame = imread('images/hotel.seq0.png');
initial_frame = im2double(initial_frame);
tau=0.000005;

%%Detecting Features
[keyXs, keyYs] = getKeypoints(initial_frame,tau);

%%Select Random Key Points
pts = randperm(size(keyYs,1));
pts = pts(1:20);

keyXs_rand = keyXs(pts);
keyYs_rand = keyYs(pts);

%%Tracking Features
imagefiles = dir('images/*.png'); 
old_frame = initial_frame;
oldXs =keyXs_rand;
oldYs =keyYs_rand;

tracked_X =keyXs_rand;
tracked_Y =keyYs_rand;

for i=1:length(imagefiles)
    
    new_frame= imread(strcat('images/hotel.seq',num2str(i-1),'.png'));
    new_frame = im2double(new_frame);
    [newXs, newYs] = predictTranslation(oldXs,oldYs,old_frame,new_frame);
    
    tracked_X =[tracked_X newXs];
    tracked_Y =[tracked_Y newYs];

    oldXs =newXs;
    oldYs =newYs;
    old_frame = new_frame;
end

tracked_X = tracked_X';
tracked_Y = tracked_Y';

%%Plotting Moved Points
moved_points = find(min(tracked_X)==-1);
figure;
imshow(initial_frame);
hold on;
plot(tracked_X(1,moved_points),tracked_Y(1,moved_points),'r*', 'MarkerSize',10);title('Moved out points');
saveas(gcf,'output/Movedout.jpg');

%%Plotting Tracked Points
tracked_points =find(min(tracked_X>0));
figure;
imshow(initial_frame);
hold on;
plot(tracked_X(:,tracked_points),tracked_Y(:,tracked_points),'y-','LineWidth',2);title('Tracked Points');
saveas(gcf,'output/TrackedPoints.jpg');