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

%% y16 _1440x1080
% src_behav=getselectedsource(behavCam);
% src_behav.FrameRate = '160.0000';
% src_behav.Brightness = 500;
% src_behav.ExposureMode = 'manual';
% src_behav.Exposure = -10;
% src_behav.Gain = 100;

% src.HorizontalFlip = 'off';
% src.VerticalFlip = 'off';
% src.Contrast = 0;

% Y800_1280x960, zoom in max
% src_behav=getselectedsource(behavCam);
% src_behav.Brightness = 500;
% src_behav.ExposureMode = 'manual';
% src_behav.Exposure = -12;
% src_behav.Gain = 260;
% src_behav.FrameRate = '200.0000';

% Y800_720x540, zoom with focus
% src_behav=getselectedsource(behavCam);
% src_behav.Brightness = 2000;
% src_behav.ExposureMode = 'manual';
% src_behav.Exposure = -12;
% src_behav.Gain = 200;
% src_behav.FrameRate = '300.0030';
% src_behav.Gamma = 250;

%% Cam setting 

% RGB24_720x540, zoom with focus
src_behav=getselectedsource(behavCam);
src_behav.Brightness = 2000;
src_behav.ExposureMode = 'manual';
src_behav.Exposure = -12;
src_behav.Gain = 200;
src_behav.FrameRate = '300.0030';
src_behav.Gamma = 250;

% MJPG_1280x720
src_cam=getselectedsource(cam);
src_cam.FrameRate = '30.0000';
src_cam.ExposureMode = 'manual';
src_cam.Brightness = 150;
src_cam.Contrast = 150;
src_cam.Exposure = -10;
src_cam.FocusMode = 'manual';
src_cam.Focus = 30;
src_cam.Gain = 200;

% preview both cams
preview(cam)
preview(behavCam)

%% Environment configuration: folders and pools

% Load previous batch folder and excel file
basedir = 'C:\Users\nyl6494\Documents\SPRT';
% pdir = uigetdir(basedir, 'Select batch folder') ;

[log_name,pdir]= uigetfile([basedir,'\save.xlsx'], 'Select log excel');
addpath(pdir)
log_name = [pdir,'\',log_name];

% Create folder for today's session
[reach_data, session, curdir] = reach_init_day(pdir);
winopen(pdir);

%% Start 2 parallel pools
delete(gcp('nocreate'));
maxNumCompThreads(2);
%create parallel pool with twoT workers
p = parpool(2);
% winopen(pdir)
%% Run 60 sec rec test with two cams
close all
if java.io.File(curdir).getFreeSpace/(1024^3) < 6
    error("Disc space full")
end   
    
reach_test_sys(cam, behavCam, 60, pdir, 30,150);

%% Shaping days: reach data only
% timer_gui(600)

mouseNum = input("Mouse num? ");
reach_data= reach_precision_mouse(reach_data, session, mouseNum, log_name);
% auto save reach data for each trial

% reach_data = reach_train_mouse(reach_data, 10, mouse_num);
% reach_save_train(mouse_data, pdir, log_name, 2)

%% Set training time (sec)
clc;
sweepTime =600;

%% Training days: reach data with timestamped videos
% disp("=============")
% check disc space
if java.io.File(curdir).getFreeSpace/(1024^3) < 10
    error("Disc space full")
end   
    
stop(cam); stop(behavCam);
delete('stopSign.mat')
disp('Run trial')
mouseNum = input("Mouse num? ");

f1 = parfeval(@singleCamAcquisitionDiskLoggingTimed, 1, cam, mouseNum, session, sweepTime, curdir, 30);
f2 = parfeval(@singleCamAcquisitionDiskLoggingTimed, 1, behavCam, mouseNum, session, sweepTime, curdir, 150);
% f3 = parfeval(@singleCamAcquisitionDiskLoggingTimed,244 1, behavCam2, 2, sweepTime, pdir, 1, src_behav2.FrameRate, src_behav2);

reach_data= reach_precision_mouse(reach_data, session, mouseNum, sweepTime, log_name);
% reach_save_train(mouse_data, pdir, log_name, 1)
save('stopSign.mat','mouseNum')

% [vidFPS_cam] = fetchOutputs(f1)
% [vidFPS_pCam] = fetchOutputs(f2)
[vidFPS_cam_behavCam] = [fetchOutputs(f1), fetchOutputs(f2)]
% [outputState_pCam2] = fetchOutputs(f3)
% delete ('stopSign.mat')

disp("Trial DONE")
disp("=============")
%% Save new data to excel ** new function has auto-save builtin
% reach_save_xls(reach_data, session, pdir)
reach_save_trial(reach_data, session, pdir)
%% Shut down system
cam = imaqfind; delete(cam);
delete(gcp('nocreate'))
delete('stopSign.mat')