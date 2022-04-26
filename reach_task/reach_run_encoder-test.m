%% Run once on Shaping day1
reach_init_batch()


%%
info = imaqhwinfo('winvideo');

format = info.DeviceInfo.SupportedFormats'
%% initiate cameras
[cam, behavCam, behavCam2, dq] = reach_init_system(...
    'webCam_name', 'winvideo', 'webCam_devicenum', 1, 'webCam_imgformat', 'MJPG_1280x720', ...    
    'behavCam_name', 'winvideo', 'behavCam_devicenum', 2, 'behavCam_imgformat', format(10), ...
    'behavCam2_name', 'off', 'behavCam2_devicenum', 0, 'behavCam2_imgformat', 'Y800_320x240')
%    'DAQ', 'ni');
% imaqtool


%% y16 _1440x1080
% 
% src_behav=getselectedsource(behavCam);
% src_behav.FrameRate = '160.0000';
% 
% src_behav.Brightness = 500;
% src_behav.ExposureMode = 'manual';
% src_behav.Exposure = -10;
% src_behav.Gain = 100;

% src.HorizontalFlip = 'off';
% src.VerticalFlip = 'off';
% src.Contrast = 0;

%% behavCam setting 
% Y800_1280x960, zoom in max
src_behav=getselectedsource(behavCam);
src_behav.Brightness = 500;
src_behav.ExposureMode = 'manual';
src_behav.Exposure = -13;
src_behav.Gain = 260;
src_behav.FrameRate =  '238.3052';

%% cam setting
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

%%
% src_behav2=getselectedsource(behavCam2);
% src_behav2.FrameRate = '120.0005';

%%
basedir = "C:\Users\nyl6494\Documents\FLRT";
pdir = uigetdir(basedir) ;
addpath(pdir)
winopen(pdir);

%%
maxNumCompThreads(2)
%create parallel pool with two workers
p = parpool(2);
% winopen(pdir)
%% Run 10 sec rec test
reach_test_sys(cam, behavCam, 0, pdir)

%% Create folder for each day
[reach_data, session, curdir] = reach_init_day(pdir);

%% Run this for reach records only (shaping days)
% timer_gui(600)
reach_data = reach_train_mouse(reach_data,10);

%% Set training time (sec)
clc;
sweepTime = 30 ;

%% Training days
disp("=============")
stop(cam); stop(behavCam);
disp('Run trial')
disp(['Start time: ' , datestr(now,'HH:MM:SS')])
% mouseNum = input("Mouse#: ");
    
f1 = parfeval(@singleCamAcquisitionDiskLoggingTimed, 1, behavCam, 1, sweepTime, curdir, 1, 240);
% f2 = parfeval(@singleCamAcquisitionDiskLoggingTimed, 1, cam, 2, sweepTime, curdir, 1, 30);
% f3 = parfeval(@singleCamAcquisitionDiskLoggingTimed, 1, behavCam2, 2, sweepTime, pdir, 1, src_behav2.FrameRate, src_behav2);

% reach_data = reach_train_mouse(reach_data,10, mouseNum)

[outputState_cam] = fetchOutputs(f1);
% [outputState_pCam] = fetchOutputs(f2);
% [outputState_pCam2] = fetchOutputs(f3)
disp("Trial DONE")
disp(['Finish time: ' , datestr(now,'HH:MM:SS')])
disp("=============")
%% Save new data to excel, 
reach_save_xls(reach_data, session, pdir)

%% Shut down system
cam = imaqfind; delete(cam);
delete(gcp('nocreate'))
