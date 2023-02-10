%% run TTL output in background NI-Daq 6001

d_1 = daq("ni");
ch_o0 = addoutput(d_1, 'Dev2', 'ao0', 'Voltage');

d_2 = daq('ni');
ch_o1 = addoutput(d_2,'Dev2', 'port1/line3', 'Digital');

%% Hz in seconds
dq.Rate = 100;


data0 = repmat([0, 1], 1, 250);
%%
stop(d_1)
flush(d_1)
preload(d_1, transpose(data0));

%
start(d_1, "repeatoutput")
tic
d_1.Running
if d_1.Running
    disp('Dev3 running')
toc
else
    disp('Dev3 did not start')
    
end
write(d_2, [1])
disp('y')

%%
stop(d_1)
toc
flush(d_1)



