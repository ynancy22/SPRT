%% initiate DAQ and cameras
function [cam, behavCam, behavCam2, dq] = reach_init_system(options)
%% specify optional arguments depending on which components to use
% e.g. for FLIR camera 
% cam = videoinput('pointgrey', 1,'F7_Mono8_1920x1200_Mode0');
% cam = videoinput('winvideo', 2,'RGB24_744x480');
% behavCam = videoinput('winvideo', 1, 'MJPG_1024x576');
% close EVERYTHING!
    arguments
        options.webCam_name (1,1) string = 'off';
        options.webCam_devicenum (1,1)  double = 0;
        options.webCam_imgformat (1,1)  string = 'off';
        options.behavCam_name (1,1) string = 'off';
        options.behavCam_devicenum (1,1)  double = 0;
        options.behavCam_imgformat (1,1)  string = 'off';
        options.behavCam2_name (1,1) string = 'off';
        options.behavCam2_devicenum (1,1)  double = 0;
        options.behavCam2_imgformat (1,1)  string = 'off';
        options.DAQ (1,1) string = 'off'; 
    end
%% config DAQ and FLIR
% close EVERYTHING!
prev_cam = imaqfind; delete(prev_cam); %clear all; close all; 
%delete(gcp('nocreate'));

%% FLIR camera config
% create video input object
% conifgure video object for manual triggering 

if strcmp(options.webCam_name,'off')==0
    cam = videoinput(options.webCam_name, options.webCam_devicenum, options.webCam_imgformat);
    triggerconfig(cam, 'manual');
    cam.FramesPerTrigger = 1;
    cam.TriggerRepeat = Inf;
 
else strcmp(options.webCam_name,'off')
    cam = 'off';
end
%% behavCam

if strcmp(options.behavCam_name,'off')==0
    behavCam = videoinput(options.behavCam_name, options.behavCam_devicenum, options.behavCam_imgformat);
    triggerconfig(behavCam, 'manual');
    behavCam.FramesPerTrigger = 1;
    behavCam.TriggerRepeat = Inf;
    
else strcmp(options.behavCam_name,'off')
    behavCam='off';
end 

%% behavCam 2

if strcmp(options.behavCam2_name,'off')==0
    behavCam2 = videoinput(options.behavCam2_name, options.behavCam2_devicenum, options.behavCam2_imgformat);
    triggerconfig(behavCam2, 'manual');
    behavCam2.FramesPerTrigger = 1;
    behavCam2.TriggerRepeat = Inf;
    
else strcmp(options.behavCam2_name,'off')
    behavCam2='off';
end 

%% DAQ config
if strcmp(options.DAQ, 'ni')
    dq = daq.createSession('ni');
    %pre 2020a code 
    %ch=dq.addAnalogOutputChannel('Dev1',0:1,'Voltage');
    %all off 
    %outputSingleScan(dq,[0 0])
    %post 2020a code
    %addoutput(dq, "Dev1", 'ao0', 'Voltage');
    %addoutput(dq, "Dev1", 'ao1', 'Voltage');
    % no freqeuncy control funciton for NI USB-6009
    % execute trigger frequency by external code in the loop
    %write(dq, [0 0]);    % set DAQ channels off
    %assignin('base','dq',dq);
    disp("DAQ done");
else strcmp(options.DAQ, 'off')
    dq = 'off'; 
end 
end

