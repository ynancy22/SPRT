function reach_save_train(data, pdir, xlsFile, sheet_num)
% log [session, data] to next row in selected excel file

% load excel log for the batch
% [log_name,path]= uigetfile([pdir,'\save.xls'],'File Selector')
% write new log in next row of previous log
% addpath(path)
log_name = [pdir+"\"+xlsFile];
% log_row = size(readcell(log_name),1)+1;
% write session day to first column
% D = cell(size(reach_data,1),1);
% D(:) = {session};
% xlswrite(log_name, data, 'Sheet1',["A"+log_row]);

writecell(data, log_name, 'Sheet', sheet_num, 'WriteMode','append');

% write training results 
% xlswrite(log_name, data, 'Sheet1',["B"+log_row]);
end
