frames = read(vid, [29001,29100]);

for i = 1: 100
    imshow(frames(:,:,:,i));
    text(50,50, num2str(i))
end

%%
a= [];
b = [];
for i = 1:5
    a = [a,datetime('now', 'format', 'HH:mm:ss.SSS')];
    pause(randi(100,1)/100)
    b = [b,datetime('now', 'format', 'HH:mm:ss.SSS')];
    pause(randi(100,1)/100)
end
%%

%%
reachResults = reachTimes{1,1};
reachTimes = reachTimes{2,1};
f = interp1(camTimes, camTimes, reachTimes,'nearest', 'extrap')
count = length(reachTimes);
reachFrames = NaN(count,1)

for i = 1:count
    reachFrames(i) = find(camTimes==f(i))
end

reachTimes = {reachResults; reachTimes; reachFrames};


%%
e = [1,2,4,1,1,2,4,2,1,2];
f = {b;a}

%%
writecell(c,'re.csv')
