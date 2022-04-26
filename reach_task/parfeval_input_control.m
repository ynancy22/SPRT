% f1 = parfeval(fcn...);
%     
% send(queue, finish);
% 
% 
% fcn:
% while finish ~= 1
%     
%     
%     
% end

%%
% delete(gcp('nocreate'));
% maxNumCompThreads(2);
% %create parallel pool with two workers
% p = parpool(2);
% % winopen(pdir)
%%

time =30;
stop = 0;


f1 = parfeval(@simu,1,time, 2)
f2 = parfeval(@simu,1,time, 10)
tic
while stop ~= 9 
    stop = input("input? ");
    toc
end
save('stopSign.mat','stop')
disp("stopped")
stop
pause(1)
    
end1 = fetchOutputs(f1)
end2 = fetchOutputs(f2)
delete ('stopSign.mat')
%%
function out = simu(a,b)
tic
while toc < a   & exist('stopSign.mat','file')~=2
    randi(1000,1000)
    out = toc
    pause(0.1)
end

end