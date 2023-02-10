%% Run once on Shaping day1
reach_init_batch()

%% initiate cameras
imaqreset
[cam, behavCam, behavCam2, dq] = reach_init_system(...
    'webCam_name', 'winvideo', 'webCam_devicenum',1, 'webCam_imgformat', 'MJPG_1280x720', ...
    'behavCam_name', 'winvideo', 'behavCam_devicenum', 2, 'behavCam_imgformat', 'RGB24_720x540', ...
    'behavCam2_name', 'off', 'behavCam2_devicenum', 4, 'behavCam2_imgformat', 'Y800_720x540')
%    'DAQ', 'ni');
% imaqtool

%% Cam setting
% behavCam, RGB24_720x540, zoom with focus
src_behav=getselectedsource(behavCam);
src_behav.Brightness = 2000;
src_behav.ExposureMode = 'manual';
src_behav.Exposure = -12;
src_behav.Gain = 200;
src_behav.FrameRate = '300.0030';
src_behav.Gamma = 250;

% webcam, MJPG_1280x720
src_cam=getselectedsource(cam);
src_cam.FrameRate = '30.0000';
src_cam.ExposureMode = 'manual';
src_cam.Brightness = 150;
src_cam.Contrast = 150;
src_cam.Exposure = -10;
src_cam.FocusMode = 'manual';
src_cam.Focus = 20;
src_cam.Gain = 200;

% preview both cams
preview(cam)
preview(behavCam)

%% Environment configuration: folders and files
closepreview
% Load previous batch folder and excel file
basedir = 'C:\Users\nyl6494\Documents\SPRT\';
[log_name,pdir]= uigetfile([basedir,'save.xlsx'], 'Select log excel');
log_name = [pdir,log_name];
addpath(pdir)

% Create folder for today's session
[session, curdir] = reach_init_day(pdir)
% winopen(curdir);

% create empty log for today
if exist('reach_data')==0
    reach_data = [];
end

% set session time (sec)
sweepTime = 600;

%% Shaping days: reach data only
mouseNum = input("Mouse num? ");

reach_data= reach_precision_mouse(reach_data, session, mouseNum, sweepTime, log_name);
% reach data for each trial is auto saved in log_name

%% Start 2 parallel pools
delete(gcp('nocreate'));
maxNumCompThreads(2);
% create parallel pool with two workers
p = parpool(2);
winopen([pdir,'test'])
%% Test cam: 60 sec rec with two cams
close all;delete('stopSign.mat');
if java.io.File(curdir).getFreeSpace/(1024^3) < 6
    error("Disc space full")
end

reach_test_sys(cam, behavCam, 60, pdir, 150, 30)

%% Training days: reach data with timestamped videos
% disp("=============")
if java.io.File(curdir).getFreeSpace/(1024^3) < 10
    error("Disc space full");end

stop(cam); stop(behavCam);delete ('stopSign.mat');
disp('Run trial')
mouseNum = input("Mouse num? ");

f1 = parfeval(@singleCamAcquisitionDiskLoggingTimed, 2, behavCam, mouseNum, session, sweepTime, curdir, 120);
f2 = parfeval(@singleCamAcquisitionDiskLoggingTimed, 2, cam, mouseNum, session, sweepTime, curdir, 30);
% f3 = parfeval(@singleCamAcquisitionDiskLoggingTimed, 1,behavCam2, 2, sweepTime, pdir, 1, src_behav2.FrameRate, src_behav2);

[reach_data, reachTimes] = reach_precision_mouse(reach_data, session, mouseNum, sweepTime, log_name);
save('stopSign.mat','session')

% [vidFPS_cam_behavCam] = [fetchOutputs(f1), fetchOutputs(f2)]
[behavFPS, behavCamTimes] = fetchOutputs(f1);
[camFPS, camTimes] = fetchOutputs(f2);
[camFPS, behavFPS]

% align reach time in behavCam time
reach_align_result(reachTimes, behavCamTimes, camTimes, curdir, session, mouseNum);

disp("Trial DONE")
disp("=============")

% Save new data to excel ** new function has auto-save builtin
% reach_save_xls(reach_data, session, pdir)
% reach_save_trial(reach_data, session, pdir);


%% Shut down system
save([curdir,'\result.mat'],'reach_data')
cam = imaqfind; delete(cam);
delete(gcp('nocreate'));delete('stopSign.mat');
disp("system shut down DONE")
exit