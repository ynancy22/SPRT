function reach_save_xls(reach_data, session, pdir)
% load excel log for the batch
[log_name,path]= uigetfile([pdir,'\save.xls'],'File Selector')
% write new log in next row of previous log
addpath(path)
log_name = [path+"\"+log_name];
log_row = size(readcell(log_name),1)+1;

% write session day to first column
D = cell(size(reach_data,1),1);
D(:) = {session};
xlswrite(log_name, D, 'Sheet1',["A"+log_row]);

% write training results 
xlswrite(log_name, reach_data, 'Sheet1',["B"+log_row]);
end
