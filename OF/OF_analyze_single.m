%% Motion tracker for mouse in open field
% Modified from code from Dr. Jones Parker
% Load video//generate BG//subtract BG for each frame//Analyze
% blob//compute moving speed/trace


%% Load video from file
function analyze_OF()
%% close all

[filename, path] = uigetfile("*.mp4");
addpath(path)
filename = [path+"\"+filename]
vid = VideoReader(filename);
frames = vid.NumFrames;
Fs = vid.FrameRate;
time = frames/Fs;
dimx = vid.Width;
dimy = vid.Height;
% of_trace = nan(frames,8);
% % timestamp, time diff, x(px), y(px), dist(px), dist(mm), speed (mm/sec)
% % ratio = evalin('base','ratio');
% 
% %
% of_trace(:,1) = [1: frames]/Fs;
% of_trace(:,2) = 1/Fs;

%% generate max projection for background substraction
% bg = imread([filetime+ "_behavBG.tiff"]);
n = 150;

bg = zeros(dimy,dimx);
for i = 1:n
    frame = double(rgb2gray(read(vid,i)));
    bg = bg + frame ;
end

bg = uint8(bg./n);
imshow(bg)
% %% Define cage size (by points)
% figure(3);
% bg2 = edge(bg,'log');
% imshow(bg2)
% %
% mydlg = warndlg('Define left top corner', 'Press OK when done');
% h1 = impoint();
% waitfor(mydlg);
% mydlg = warndlg('Define right bottom corner', 'Press OK when done');
% h2 = impoint();
% waitfor(mydlg);
% 
% corner1 = h1.getPosition;
% corner2 = h2.getPosition;
% %
% close(gcf)
% delete(h1)
% delete(h2)
% %
% side = pdist([corner1;corner2],'euclidean')
% realside = 310; % mm
% 
% 
% disp("Calibration factor: (mm/px)")
% ratio = realside/side % mm/px

% %% Define cage size (by line)
% figure(3);
% bg2 = edge(bg,'log');
% imshow(bg2)
% mydlg = warndlg('Draw Diagnal in cage', 'Press OK when done');
% h = imdistline();
% waitfor(mydlg);
% 
% side = h.getDistance;
% cage_area = round(h.getPosition,0);
% 
% close(gcf)
% delete(h)
% realside = 310; % mm
% disp("Calibration factor: (mm/px)")
% ratio = realside/side % mm/px

%% Define cage size (by rectangle)
close(gcf)
figure(3);
bg2 = edge(bg,'log');
imshow(bg2)
mydlg = warndlg('Draw CAGE area', 'Press OK when done');
h = imrect();
waitfor(mydlg);

% side = h.getDistance;
cage_area = round(h.getPosition,0);

close(gcf)
delete(h)
side = mean(cage_area(3:4));
realside = input("average side?(mm) "); % mm
disp("Calibration factor: (mm/px)")
ratio = realside/side % mm/px

%% Define size threshold

figure(3);
bg2 = read(vid,round(frames/2, 0));
imshow(bg2)
mydlg = warndlg('Draw minimum size', 'Press OK when done');
h = imfreehand();
waitfor(mydlg);
size_img = h.createMask();
size_min = regionprops(size_img,  'area').Area
close(gcf)
delete(h)

%% calculate frame rate
% frametime = readtable([filetime+"_frametime.txt"]);
% trace(:,1) = seconds(frametime.Var1);
% trace(2:frames,2) = diff(trace(:,1));


%% Define Start time

implay(filename)

%% subtract bg 
bg_crop = imcrop(bg,cage_area);
ws = 5;
disp("Detect mouse")
tic
for i = 1:frames
    
    if rem(i,1800)==0
    disp("1 min done")
    toc
    end
    
% disp(i)

frame = read(vid,i);

frame_crop = imcrop(frame,cage_area);
frame_crop = rgb2gray(frame_crop);
%subplot(2,2,3);title("Curr frame")
% imshow(frame)
%frame = rgb2gray(frame);


%
% frame_sub = rgb2gray(frame_crop);
%figure()
% imshow(frame_sub)

frame_sub = imsubtract(bg_crop,frame_crop);
%subplot(2,2,4);title("Sub frame")
% imshow(frame_sub)
%hold off

%
%frame_bw = im2bw(medfilt2(frame_sub,[ws ws]));
T = graythresh(frame_sub);
frame_bw = imbinarize(frame_sub,T*1.1);
frame_bw0 = imfill(frame_bw, 'holes');
%bw0 = imclearborder(bw0);

% Erode mask with disk
radius = 8;
decomposition = 0;
se = strel('ball', radius, decomposition);
frame_bw1 = imerode(frame_bw0, se);

% Dilate mask with disk
radius = 5;
decomposition = 0;
se = strel('ball', radius, decomposition);
frame_bw2 = imdilate(frame_bw1, se);

%bw=im2bw(mIM);
%bw=imcomplement(bw);
% % 
% figure(2);
% subplot(2,2,1); imshow(frame_sub)
% subplot(2,2,2); imshow(frame_bw0)
% subplot(2,2,3); imshow(frame_bw1)
% subplot(2,2,4); imshow(frame_bw2)

%
blobs = regionprops(frame_bw, 'centroid', 'area');
xy = vertcat(blobs.Centroid);
area = vertcat(blobs.Area);
if max(area)>size_min
    idx = find(area == max(area));
    of_trace(i,3:5) = [area(idx) xy(idx,:)];
    if i~=1
        of_trace(i,6) = sqrt((of_trace(i, 4) - of_trace(i-1,4))^2+...
            (of_trace(i,5)-of_trace(i-1,5))^2);
    else
    end
else
end

end

%%

of_trace(:,7) = of_trace(:,6)*ratio; % mm/frame
of_trace(:,8) = of_trace(:,7)./of_trace(:,2);

% toc

%% plot detected trace on BG img
figure(4);

imshow(bg_crop)
hold on

% scatter(of_trace(:,4),of_trace(:,5))

% scatter(of_trace(:,4),of_trace(:,5),of_trace(:,3)/50,[1:frames],'o','filled',...
%     'MarkerFaceAlpha', 0.2,'MarkerEdgeAlpha', 0.2)
% colormap(gca,'parula')
% c = colorbar('southoutside');
% c.Label.String = 'frame #';
% xlim([0 dimx]);ylim([0 dimy]);
% hold on
plot(of_trace(:,4),of_trace(:,5),'k','lineWidth',1)
% xlim([0 dimx]);ylim([0 dimy]);
% title("Location in view")
hold off
%% Here we will split the data into three types: 
%1) raw 20 Hz, 
%2) 1-s median-filtered 20 Hz, and 
%3) 1-s median-filtered 5 Hz. 
disp("Process speed data(filter)")
tic
    Fs_in = 30;
    Fs_out = 5;
    
    %1)
    Behavior_distance_raw = of_trace(:,8);

    
    %2) Now filter using 1-s median filter
    Behavior_filterFactor = Fs_in;
    Behavior_distance_filter = medfilt1(Behavior_distance_raw, Behavior_filterFactor,'omitnan','truncate');
    of_trace(:,9) = Behavior_distance_filter;
    
    %3)Now downsample to 5Hz    
    Behavior_speed_filter = Behavior_distance_filter;%*Fs_in;
    
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
    of_trace(1:time*downsampledRate,10) = speedTrace;
toc    
%% plot filtered speed
timex = cumsum(of_trace(:,2));

figure(5)
subplot(3,1,1)
title("Raw data")
plot(timex, Behavior_distance_raw)
xlim([0 max(timex)])

subplot(3,1,2)
title("1 sec median filtered")
plot(timex, Behavior_distance_filter)
xlim([0 max(timex)])
ylabel("Mouse speed (mm/sec)")

subplot(3,1,3)
title("1 sec median filtered @ 5 Hz")
plot(linspace(1/5,time,length(speedTrace)),speedTrace)
xlabel("Time (sec)")
%% save result 
filetime = filename(1:8);
xlsname = [path,filetime,'_tracking.xlsx'];
writematrix(of_trace, xlsname)
% save figures: bg, trace, speed plots
%saveas(figure(3), [filetime+"_bg.svg"]);
% saveas(figure(4),[path,filetime,'_trace.svg']);
saveas(figure(5), [path,filetime,'_speed.svg']);
end
