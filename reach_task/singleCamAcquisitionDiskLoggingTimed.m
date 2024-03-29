function [finalFPS, frameTimes] = singleCamAcquisitionDiskLoggingTimed(inputCam, mouseNum, session, sweepTimeSeconds, curdir, freq)

%% init
triggerconfig(inputCam, 'manual')
inputCam.FramesPerTrigger = 1
inputCam.TriggerRepeat = Inf

% src=getselectedsource(inputCam);
% src.FrameRate = freq;
% disp(src.FrameRate)

%%
filetime = datestr(datetime,'yyyymmdd-HH-MM-SS')
addpath(curdir)
vidfileName = [curdir+"\"+ filetime+"_"+ session+ "-"+ num2str(mouseNum)+  ...
    "_"+strtrim(imaqhwinfo(inputCam).DeviceName(1:4))];

vidfile = VideoWriter(vidfileName);
vidfile.FrameRate = freq;
% vidfile.Quality = 75;
inputCam.LoggingMode = 'disk';
inputCam.DiskLogger = vidfile;
%%
open(vidfile);
start(inputCam);

% get current time
% startTime = datetime('now', 'format', 'HH:mm:ss.SSS');
% currentTime = datetime('now', 'format', 'HH:mm:ss.SSS');

frameTimes = [];
%%
tic
while toc< sweepTimeSeconds
    %for i = 1:frames

    if islogging(inputCam) == 0
        trigger(inputCam) ;
        frameTimes = [frameTimes ; datetime('now', 'format', 'yyyy-MM-DD HH:mm:ss.SSS')];
    else
        %         disp('waiting for disk writing');
        while islogging(inputCam)== 1
            %             java.lang.Thread.sleep(1);
            pause(0.001)
        end
    end
    
    
        disp('frames acquired from stream');
        disp(inputCam.FramesAcquired);
        disp('frames logged to disk');
        disp(inputCam.DiskLoggerFrameCount);
    
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

finalFPS = inputCam.DiskLoggerFrameCount/toc
%%
log_name = [curdir+"\"+ filetime+"_"+ session+"-"+ num2str(mouseNum)+  ...
    "_"+ strtrim(imaqhwinfo(inputCam).DeviceName(1:4))+ "_time.csv"];
writematrix(frameTimes, log_name);
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



