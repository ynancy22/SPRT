function reach_align_result(reachTimes, behavCamTimes, camTimes, curdir, session, mouseNum)
% match manual input result with camera timestamp 
% save as reachTimes.xlsx

%% Load data
reachResult = reachTimes{1,1};
reachTimestamp = reachTimes{1,2};
behavcamTimestamp = unique(behavCamTimes);
camTimestamp = unique(camTimes);
%% find the matching timestamp 
t1 = interp1(behavcamTimestamp, behavcamTimestamp, reachTimestamp, 'nearest', 'extrap');
t2 = interp1(camTimestamp, camTimestamp, reachTimestamp, 'nearest', 'extrap');
count = length(reachTimestamp);
reachFrame = NaN(count,2);
%% extract frame number for matched timestamps
for i = 1:count
    reachFrame(i,1) = find(behavCamTimes==t1(i),1);
    reachFrame(i,2) = find(camTimes==t2(i),1);
end

%% Save result
filetime = datestr(datetime,'yyyymmdd-HH-MM-SS');
log_name = [curdir,'\', filetime, '_',session , '_', num2str(mouseNum), '_reachTimes.xlsx'];

out = timetable(reachTimestamp, reachResult, reachFrame,'VariableNames', {'reach','frame'});
writetimetable(out, log_name)

disp("Frame aligned")
%%
% reachOutput = {reachResult, reachTimestamp, reachFrame};

% writematrix(reachResult, log_name, 'range', 'A1')
% writematrix(reachTimestamp, log_name, 'range', 'B1')
% writematrix(reachFrame, log_name, 'range', 'C1')

end