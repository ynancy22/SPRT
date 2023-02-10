function [session, curdir] = reach_init_day(pdir)
% create new dir with date_session in pdir
% create empty reach_data for trial records (run reach_train_mouse)

%%
% pdir = cd;
date = datestr(now,'yyyymmdd');
session = input("Training day? (S01/T01...) ",'s');
training_day = [date,'_',session];

%%
mkdir(pdir,training_day)
curdir = [pdir,training_day];
addpath(curdir)
% winopen([pdir,'\',training_day])

if exist("reach_data")==1
    
else
    reach_data = [];
    assignin('base', 'reach_data', reach_data)
end
end