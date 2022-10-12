%%  Batch
basedir = 'G:\My Drive\1-Contractor Lab\6_Behavior\SPRT';
pdir = uigetdir(basedir, 'Select batch folder') ;
addpath(pdir)

log_name = [pdir,'\',input("Batch day? ","s"),'_review.xlsx']
if exist(log_name)~=2
header = ["Day","Start Time", "Mouse#", "1st attempt","Success", "Total", "Rate %", "Raw Data"];
writematrix(header, log_name, 'Sheet',1);
end

reach_data = [] 

%% Day

session = input('Which day? ','s');

%% Mouse

mouse_num = input("Mouse num? ");
reach_data= reach_precision_mouse(reach_data, session, Inf, mouse_num, log_name);



