function reach_data = reach_train_mouse(reach_data, trialNum, mouseNum)
% log new mouse to *reach_data* with *trialN* reach

disp(['Start time: ' , datestr(now,'HH:MM:SS')])
mouse_data =zeros(1,trialNum);

disp("Shaping: R=1/L=3/other=2")
disp("Training: Success=1/Fail=0")
%%
for trial = [1:trialNum]
    reach = [];
    while isempty(reach)
        reach = input([trial+" reach: "]); 
    end
    mouse_data(trial) = reach;
end
%%

reach_data = [reach_data; mouseNum, mouse_data];

end