function [outputStatus] = singleCamAcquisitionDiskLoggingTimed(inputCam, mouseNum, session, sweepTimeSeconds, curdir, freq)

%% init
triggerconfig(inputCam, 'manual');
inputCam.FramesPerTrigger = 1;
inputCam.TriggerRepeat = Inf;

% src=getselectedsource(inputCam);
% src.FrameRate = freq;
% disp(src.FrameRate)

%%
filetime = datestr(datetime,'yyyymmdd-HH-MM-SS');
addpath(curdir);
vidfileName = [curdir, '\', filetime,'_', session, '-', num2str(mouseNum),  ...
    '_', imaqhwinfo(inputCam).DeviceName(1:4)]

%%
vidfile = VideoWriter(vidfileName);
vidfile.FrameRate = freq;
inputCam.LoggingMode = 'disk';
inputCam.DiskLogger = vidfile;

open(vidfile);
start(inputCam);

%get current time
% startTime = datetime('now', 'format', 'HH:mm:ss.SSS');
% currentTime = datetime('now', 'format', 'HH:mm:ss.SSS');

%frameTimes = datetime(zeros(frames,1), 0, 0, 'format', 'HH:mm:ss.SSS');
frameTimes = datetime('now', 'format', 'HH:mm:ss.SSS');
tic
while toc< sweepTimeSeconds
    %for i = 1:frames
    
    if islogging(inputCam)== 0
        trigger(inputCam) ;
        frameTimes = [frameTimes ; datetime('now', 'format', 'HH:mm:ss.SSS')];
    else
        %         disp('waiting for disk writing');
        while islogging(inputCam)== 1
            %             java.lang.Thread.sleep(1);
            pause(0.001)
        end
    end
    
    
    %     disp('frames acquired from stream');
    %     disp(inputCam.FramesAcquired);
    %     disp('frames logged to disk');
    %     disp(inputCam.DiskLoggerFrameCount);
    
    %     currentTime = datetime('now', 'format', 'HH:mm:ss.SSS');
    if round(rem(toc, 30)) == 0 & exist('stopSign.mat','file')==2
        break;
    end
    
end



%wait for final frame
if inputCam.DiskLoggerFrameCount~=inputCam.FramesAcquired
    %     java.lang.Thread.sleep(1);
    pause(0.001);
end

outputStatus = inputCam.DiskLoggerFrameCount/toc

expname = [curdir, '\', filetime,'_', session, '-', num2str(mouseNum),  ...
    '_', imaqhwinfo(inputCam).DeviceName(1:4) , '_time.csv'];
writematrix(frameTimes, expname);
%
disp('frames acquired from stream');
disp(inputCam.FramesAcquired);
disp('frames logged to disk');
disp(inputCam.DiskLoggerFrameCount);
close(vidfile) ;
stop(inputCam) ;
delete(vidfile) ;
clear vidfile ;
%end
disp('Done') ;



% outputStatus='done';


%disp(['finished'+outputStatus]);
end



