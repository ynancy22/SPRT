function [pulseTimes] = syncPhotometry(mouseNum, session, sweepTime, curdir)

dq = daq('ni');

%Dev 1 should be "National Instruments(TM) USB-6009"

addoutput(dq, "Dev1", 'port1/line3', 'Digital');
% dq.addDigitalChannel('Dev1', 'port1/line3', 'OutputOnly');
write(dq,0)

%% write to digital output channel of NI DAQ

% create session
%dq = daq.createSession('ni');

% add single digital output channel

%ch=dq.addDigitalChannel('Dev1', 'port1/line3', 'OutputOnly');
filetime = datestr(datetime,'yyyymmdd-HH-MM-SS');
% loop to trigger TTL
% sweepTimeSeconds = 20 ;
startTime = datetime('now','format','HH:mm:ss.SSS');
currentTime = datetime('now', 'format', 'HH:mm:ss.SSS');
pulseTimes = datetime('now', 'format', 'HH:mm:ss.SSS');
tic
while seconds(currentTime-startTime) < sweepTime
    
    % turn on digital out
    write(dq, [1]);
    % time stamp
    % DAQ_times(i,1)= datetime('now', 'format', 'HH:mm:ss.SSS');
    pulseTimes = [pulseTimes ; datetime('now', 'format', 'HH:mm:ss.SSS')];
    % pause before turning off
    java.lang.Thread.sleep(50);
    %     currentTime = datetime('now', 'format', 'HH:mm:ss.SSS');
    
    % turn off
    
    write(dq, [0])

    java.lang.Thread.sleep(50);
    % update time
    
    currentTime = datetime('now', 'format', 'HH:mm:ss.SSS');
    
    if round(rem(toc, 30)) == 0 & exist('stopSign.mat','file')==2
       break;
    end
    
    
end

log_name = [curdir+"\"+ filetime+"_"+ session+"-"+ num2str(mouseNum)+  ...
    "_pulseTime.csv"];
writematrix(pulseTimes, log_name);

delete(dq)
outputStatus='done';


end


