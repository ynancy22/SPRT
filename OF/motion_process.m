%% Motion tracker for mouse in open field
% Modified from code from Dr. Jones Parker
% Load video//generate BG//subtract BG for each frame//Analyze
% blob//compute moving speed/trace

%% Load video from file
clear;close all;
vidinput = uigetfile('*.avi')
vid = VideoReader(vidinput);
frames = vid.NumFrames;
Fs = vid.FrameRate;
time = frames/Fs;
dimx = vid.Width;
dimy = vid.Height;
trace = zeros(frames,8);
% timestamp, time diff, x(px), y(px), dist(px), dist(mm), speed (mm/sec)



%% generate max projection for background substraction
% tic
% disp('Process BG');
% bg = read(vid,1);
% 
% for i = 1:400 % max z-projection from first 400 frames
%     frame = read(vid,i);
%     bg = max(bg,frame);
% end
% 
% figure(1)
% hold on
% imshowpair(frame, bg,'montage')
% title("Background generated from video")
% toc

%% Define cage size
figure(2);
imshow(bg)
mydlg = warndlg('Draw line on side', 'Press OK when done');
h = imdistline();
waitfor(mydlg);
side = h.getDistance;
close(gcf)
delete(h)
realside = 420; % mm
disp("Calibration factor: (mm/px)")
ratio = realside/side % mm/px

%% calculate frame rate
frametime = readtable([vidinput(1:14)+"frametime.txt"]);
trace(:,1) = seconds(frametime.Var1);
trace(2:frames,2) = diff(trace(:,1));

%% subtract bg 

ws = 5;
disp("Detect mouse")
tic
for i =1:frames

frame = read(vid,i);
%subplot(2,2,3);title("Curr frame")
%imshow(frame)
%frame = rgb2gray(frame);

frame_sub = imsubtract(bg,frame);
%subplot(2,2,4);title("Sub frame")
%imshow(frame_sub)
%hold off

%
frame_sub = rgb2gray(frame_sub);
%figure()
%imshow(frame_sub)

%
%frame_bw = im2bw(medfilt2(frame_sub,[ws ws]));
T = graythresh(frame_sub);
frame_bw = imbinarize(frame_sub,T);
frame_bw0 = imfill(frame_bw, 'holes');
%bw0 = imclearborder(bw0);

% Erode mask with disk
radius = 5;
decomposition = 0;
se = strel('ball', radius, decomposition);
frame_bw1 = imerode(frame_bw, se);

% Dilate mask with disk
radius = 3;
decomposition = 0;
se = strel('ball', radius, decomposition);
frame_bw2 = imdilate(frame_bw, se);

%bw=im2bw(mIM);
%bw=imcomplement(bw);

figure(2);
subplot(2,2,1); imshow(frame_bw)
subplot(2,2,2); imshow(frame_bw0)
subplot(2,2,3); imshow(frame_bw1)
subplot(2,2,4); imshow(frame_bw2)

%
%
blobs = regionprops(frame_bw, 'centroid', 'area');
xy = vertcat(blobs.Centroid);
area = vertcat(blobs.Area);
idx = find(area == max(area));
trace(i,3:5) = [area(idx) xy(idx,:)];
if i~=1
    trace(i,6) = sqrt((trace(i, 4) - trace(i-1,4))^2+...
        (trace(i,5)-trace(i-1,5))^2);
else
end
end
%%
trace(:,7) = trace(:,6)*ratio; % mm/frame
trace(:,8) = trace(:,7)./trace(:,2);

toc

%% plot detected trace on BG img
figure(3);
imshow(bg)
hold on
scatter(trace(:,4),trace(:,5),trace(:,3)/50,[1:frames],'o','filled',...
    'MarkerFaceAlpha', 0.2,'MarkerEdgeAlpha', 0.2)
colormap(gca,'parula')
c = colorbar('southoutside');
c.Label.String = 'frame #';
title("Location in view")
xlim([0 dimx]);ylim([0 dimy]);
hold on

plot(trace(:,4),trace(:,5),'k','lineWidth',1)
xlim([0 dimx]);ylim([0 dimy]);
%% Here we will split the data into three types: 
%1) raw 20 Hz, 
%2) 1-s median-filtered 20 Hz, and 
%3) 1-s median-filtered 5 Hz. 
Fs = 30;
disp("Process speed data(filter)")
tic
    Fs_in = Fs;
    Fs_out = 5;
    
    %% 1)
    Behavior_distance_raw = of_trace(:,8);

    
    %% 2) Now filter using 1-s median filter
    Behavior_filterFactor = Fs_in;
    Behavior_distance_filter = medfilt1(Behavior_distance_raw, Behavior_filterFactor,'omitnan','truncate');

    
    %3)Now downsample to 5Hz    
    Behavior_speed_filter = Behavior_distance_filter*Fs_in;
    
    %compute downsample factors for the two movies (to make them 5 Hz)
    downsampledRate = Fs_out;%define the target downsample rate
    Behavior_frameRate = Fs_in;
    Behavior_downsampleFactor = round(Behavior_frameRate/downsampledRate);
    
    if Behavior_downsampleFactor > 1
    
    Behavior_speed_filter = mean(reshape([Behavior_speed_filter(:); ...
        nan(mod(-numel(Behavior_speed_filter),Behavior_downsampleFactor),1)],...
        Behavior_downsampleFactor,[]),'omitnan');
    
    end
%   Behavior_distance_filter20 = nansum(reshape([Behavior_distance_filter(:); nan(mod(-numel(Behavior_distance_filter),Behavior_downsampleFactor),1)],Behavior_downsampleFactor,[]));
%   Behavior_distance_filter20 = Behavior_distance_filter20';%transpose the distance traces
%   speedTrace = Behavior_distance_filter20*Fs_out;
    speedTrace = Behavior_speed_filter';
toc    
%% plot filtered speed
timex = cumsum(of_trace(:,2));

figure(4)
subplot(3,1,1)
plot(timex, Behavior_distance_raw)
xlim([0 max(timex)])

subplot(3,1,2)
plot(timex, Behavior_distance_filter)
xlim([0 max(timex)])
%
subplot(3,1,3)
plot(speedTrace)

%% read file from excel
[filename, path] = uigetfile('*.xlsx')
of_trace = readmatrix([path,filename],'range','A1:H18000');