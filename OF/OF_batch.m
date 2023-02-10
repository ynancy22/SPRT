[filename, path] = uigetfile("*.mp4");
vid_list = dir(fullfile(path, '*.mp4'));
addpath(path)

%% Define batch background
vid = VideoReader(filename);
n = 0;



bg = zeros(vid.Height,vid.Width);
for i = [1:6:600]
    frame = double(rgb2gray(read(vid,i)));
    bg = bg + frame ;
    n=n+1;
end
bg = uint8(bg./n);
imshow(bg)

%% Load bg from mat file
bg = imread(uigetfile(path));
imshow(bg)

%% Define cage size (by line)
figure(1);

% bg2 = edge(bg,'log');
imshow(bg)
mydlg = warndlg('Draw CAGE area', 'Press OK when done');
h = imrect();
waitfor(mydlg);

side = h.getDistance;
cage_area_line = round(h.getPosition,0);
%
boxx = input("box height?(mm) ");
boxy = input("box length?(mm) ");

realside = sqrt(boxx^2+boxy^2); % mm
disp("Calibration factor: (mm/px)")
ratio = realside/side % mm/px

%% Calibrate cage size
close(gcf)
figure(1);

imshow(bg)
mydlg = warndlg('Draw CAGE area', 'Press OK when done');

roi = drawrectangle;
waitfor(mydlg);

cage_area = roi.Position;

cage_size = [input("cage x dim?(cm) "), input("cage y dim?(cm) ")];

ratio = sum(cage_size)*10/sum(cage_area(3:4)); %mm/px
delete(roi)
%% Define mouse size min
imshow(bg)
mydlg = warndlg('Draw minimum size', 'Press OK when done');
% h = imfreehand();
roi = drawfreehand;

waitfor(mydlg);
size_min = roi.createMask();
size_min = regionprops(size_min, 'area').Area;
close(gcf)
delete(roi)

%% single file
filename = vid_list(1).name;
OF_analyze_batch(path, filename, bg, ratio, cage_area, size_min, 10)

%% Run all videos in path
vid_list = dir(fullfile(path, '*.mp4'));
n = [4,5,6,7,9,10];

for v = 1:length(n)
    m = n(v);
    filename = vid_list(m).name;
    OF_analyze_batch(path, filename, bg, ratio, cage_area, size_min,600);
    
end

%% Run iin parallel pool
delete(gcp('nocreate'));
maxNumCompThreads(8);
%create parallel pool with twoT workers
p = parpool(8);
% winopen(pdir)

%% run in parpool up to 8 job - same bg
% use same bg for all vid in folder
fileN = [1]; % modify this for each folder


f=[]; e=f; d=e; c=d; b=c; a=b; g=f; h=g;
jobs = {a,b,c,d,e,f,g,h};

for v =  1:length(fileN)%length(vid_list)
    m = fileN(v);
    filename = vid_list(m).name
    jobs{v} = parfeval(@OF_analyze_batch, 0, path, filename, bg, ratio, cage_area, size_min, 600)
end

%% run in parpool up to 8 job - individual bg
% select files to run (# in vid_list)
fileN = [1]; % modify this for each folder

f=[]; e=f; d=e; c=d; b=c; a=b; g=f; h=g;
jobs = {a,b,c,d,e,f,g,h};

for v =  1:length(fileN)%length(vid_list)
    m = fileN(v);
    filename = vid_list(m).name
    
    % define bg and box area for each video
    vid = VideoReader(filename);
    bg_f = 0;
    
    bg = zeros(vid.Height,vid.Width);
    for i = [1:6:600]
        frame = double(rgb2gray(read(vid,i)));
        bg = bg + frame ;
        bg_f=bg_f+1;
    end
    bg = uint8(bg./bg_f);
    imshow(bg)
    %
    mydlg = warndlg('Draw CAGE area', 'Press OK when done');
    
    roi = drawrectangle;
    waitfor(mydlg);
    
    cage_area = roi.Position;
    
    close(gcf)
    
    jobs{v} = parfeval(@OF_analyze_batch, 0, path, filename, bg, ratio, cage_area, size_min, 600)
end
