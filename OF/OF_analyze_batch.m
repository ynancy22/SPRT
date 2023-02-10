%% Motion tracker for mouse in open field
% Modified from code from Dr. Jones Parker
% Load video//generate BG//subtract BG for each frame//Analyze
% blob//compute moving speed/trace


%% Load video from file
function OF_analyze_batch(path, filename, bg, ratio, cage_area, size_min, time)
%% Define Start time
disp(['Process ',filename])
vid = VideoReader([path,filename]);
vid_frames = vid.NumFrames;
vid_fs = vid.FrameRate;
vid_time = vid_frames/vid_fs;
vid_dimx = vid.Width;
vid_dimy = vid.Height;

if vid_time>600
    vid_time=time;
end

%% crop bg
bg_crop = imcrop(bg,cage_area);
% bg_crop = rgb2gray(bg_crop);
ws = 5;
of_trace = [];
disp("Detect mouse")
tic

%%
for i = 1:vid_fs*vid_time
    
    if rem(i,vid_fs*60)==0
        disp([filename,' ', num2str(i) ,' frame done in ', num2str(toc),' secs'])
        %         toc
    end
    
    disp(i)
    
    frame = read(vid,i);
    frame = rgb2gray(frame);
    frame_crop = imcrop(frame,cage_area);
    %     frame_crop = rgb2gray(frame_crop);
    %subplot(2,2,3);title("Curr frame")
    % imshow(frame)
    
    
    
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
    frame_bw = imbinarize(frame_sub,T);
    frame_bw = imfill(frame_bw, 'holes');
    %bw0 = imclearborder(bw0);
    
    % Erode mask with disk
    radius = 8;
    decomposition = 0;
    se = strel('ball', radius, decomposition);
    frame_bw = imerode(frame_bw, se);
    
    % Dilate mask with disk
    radius = 5;
    decomposition = 0;
    se = strel('ball', radius, decomposition);
    frame_bw = imdilate(frame_bw, se);
    
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
        if length(idx)>1
            rel = abs(sum(xy(idx,:)-of_trace(i-1,4:5),2));
            idx = idx(find(rel == min(rel)));
        end
        
        of_trace(i,3:5) = [area(idx) xy(idx,:)];
        if i~=1
            of_trace(i,6) = norm((of_trace(i, 4:5)-(of_trace(i-1, 4:5));
            %             of_trace(i,6) = sqrt((of_trace(i, 4) - of_trace(i-1,4))^2+...
            %                 (of_trace(i,5)-of_trace(i-1,5))^2);
        else
        end
    else
    end
    
end

of_trace(:,1) = 1/vid_fs;
of_trace(:,2) = cumsum(of_trace(:,1));

of_trace(of_trace==0) = NaN;

%%

of_trace(:,7) = of_trace(:,6)*ratio; % mm/frame
% of_trace(:,8) = of_trace(:,7)./of_trace(:,2);
of_trace(:,8) = of_trace(:,7)*vid_fs;
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
of_trace(1:length(speedTrace),10) = speedTrace;
toc
%% plot filtered speed
% timex = cumsum(of_trace(:,2));
timex = [1/vid_fs:1/vid_fs:vid_time]';
%
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
plot(linspace(1/5,vid_time,length(speedTrace)),speedTrace)
xlabel("Time (sec)")
%% save result
[~,filename,~] = fileparts(filename);
xlsname = [path,filename,'_tracking.xlsx'];
writematrix(of_trace, xlsname)
% save figures: bg, trace, speed plots
% saveas(figure(3), [path,filename,"_bg2.svg"]);
saveas(figure(4),[path,filename,'_trace2.svg']);
saveas(figure(5), [path,filename,'_speed2.svg']);
end
