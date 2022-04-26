function reach_init_batch()
% create folder for batch
% create new result log excel with title

basedir = 'C:\Users\nyl6494\Documents\SPRT';

%% create batch dir
basedir = uigetdir(basedir);
% addpath(pdir)
date = datestr(now,'yyyymmdd');
batch_name = [date+"_"+input("mouse#? ",'s')];

mkdir(basedir,batch_name)
pdir = [basedir+"\"+batch_name];
addpath(pdir)

%% create test dir
mkdir(pdir,'test')

% create empty training log excel file
header = ["Day","Start Time", "Mouse#", "Preffered", "Raw data"];
writematrix(header, [pdir+"\"+batch_name+".xlsx"], 'Sheet',2);

header = ["Day","Start Time", "Mouse#", "1st attempt","Success", "Total", "Rate %", "Raw Data"];
writematrix(header, [pdir+"\"+batch_name+".xlsx"], 'Sheet',1);

end
