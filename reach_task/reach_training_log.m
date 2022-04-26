%% create batch folder with "date_mouse#"
function reach_init_batch()
% create folder for batch
pdir = uigetdir
cd(pdir)
date = datestr(now,'yyyymmdd');
batch_name = [date+"_"+input("mouse#? ",'s')];
mkdir(batch_name)
cd(batch_name)
pdir = cd;
mkdir('test')
% create empty training log excel file
header = ["Day", "mouse#", "R1", "R2", "R3", "R4", "R5", "R6", "R7", "R8", "R9", "R10"];
writematrix(header, [batch_name+".xls"], 'Sheet',1);

end


%% run test
function reach_test_sys(cam, behavCam, sweepTime)
%
pdir = cd;
cd('test')
%
f1 = parfeval(@disk_log_cam, 1, behavCam, 1, sweepTime, pdir, 300);
f2 = parfeval(@disk_log_cam, 1, cam, 0, sweepTime, pdir, 60);

[outputState_cam] = fetchOutputs(f1);
[outputState_pCam] = fetchOutputs(f2);

% show recorded file
cd(pdir)
winopen([pdir '\test'])
disp('Test done')
end

%% run training day
function [reach_data, session] = reach_init_day()
%
pdir = cd;
date = datestr(now,'yyyymmdd');
session = input("Training day? (S01/T01...) ",'s');
training_day = [date+"_"+session];
mkdir(pdir,training_day)
cd(training_day)
winopen(cd);

% prelocate header for data log
reach_data = [];
end

%% Run for each mouse
% run f1/f2 in pool
function reach_data = reach_train_mouse(reach_data)
%
mouse_data = [0:10];
mouse_data(1) = input("Next mouse#: ");
disp("Shaping: L=1/R=3/other=2")
disp("Training: Success=1/Fail=0")
for trial = [1:10]
    reach = [];
    while isempty(reach)
        reach = input([trial+" reach: "]); 
    end
    mouse_data(trial+1) = reach;
end

reach_data = [reach_data; mouse_data];

end
% fetch output from pool
% disp done

function reach_save_xls(reach_data, session, pdir)
% load excel log for the batch
cd(pdir)
log_name= uigetfile('*.xls','File Selector')
% write new log in next row of previous log
log_row = size(readcell(log_name),1)+1;

% write session day to first column
D = cell(size(reach_data,1),1);
D(:) = {session};
xlswrite(log_name, D, 'Sheet1',["A"+log_row]);

% write training results 
xlswrite(log_name, reach_data, 'Sheet1',["B"+log_row]);
end
