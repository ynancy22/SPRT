function [all_data, reachTimes] = reach_precision_mouse_TTL(all_data, session, mouse_num, sweepTime, output_xls, dq)
% log *mouseNum* mouse to *reach_data* with unlimited reach
% data ouput:
% mouseNum, [reach trials], success count, total count, success rate
startTime = datestr(now,'HHMMSS');
disp(['Start time: ' , startTime])
% mouse_data = [0:trialN];
% mouse_data(1) = mouseNum;
stop(d_1)
d_1 = dq(1);
d_2 = dq(2);
d_1.Rate = 100;
% delete('stopSign.mat')
stop(d_1)
flush(d_1)
preload(d_1, transpose(repmat([0, 1], 1, 250)));

%
start(d_1, "repeatoutput")
disp("Shaping: R=1/L=3/other=2")
disp("Training: Success=1/Fail=0")
disp("Other: Time&pellet=7/Finish=9")
 %%   
trials = [];
reachTimes = [];

if count(session,"S")
    pellet_num = 10;
    out_col = [1:5];
    sheet_num = 2;
elseif count(session,"T")
    pellet_num = 20;
    out_col = [1:8];
    sheet_num = 1;
else
    pellet_num = inf;
end

tic

while toc < sweepTime  & nnz(trials)<pellet_num
    reach = [];
    while isempty(reach)
        reach = input("Next reach: ");
    end
    
    if reach == 9
        %         save('stopSign.mat','reach');
        break;
    elseif reach == 7
        disp([num2str(toc), ' sec, ',num2str(nnz(trials)),' pellets'])
    elseif reach < 4
        write(d_2, [1])
        trials = [trials, reach];
        reachTimes = [reachTimes; datetime('now', 'format', 'HH:mm:ss.SSS')];
        write(d_2, [0])
    end
    
end

stop(d_1)
flush(d_1)


%% 
if count(session,"S") % Shaping: 1=Left/3=Right
    single_data = {session, startTime, mouse_num, round(mean(trials),2) , trials};

else % Training: 2=1st attempt/1=succes/0=fail
    single_data = {session, startTime, mouse_num, ...
        size(strfind(trials,"2"),2), nnz(trials), length(trials), ...
        nnz(trials)/length(trials), num2str(trials), reachTimes'};
    reachTimes = {trials',reachTimes};
    
end

%%
if output_xls == "off";
    disp("Result not saved")
else
    writecell(single_data(1,out_col), output_xls, 'Sheet', sheet_num, 'WriteMode','append');
end
disp(['Finished: ',num2str(toc), ' sec, ',num2str(nnz(trials)),' pellets retrieved'])

all_data = [all_data; single_data]
end