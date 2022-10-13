function reach_align_result(reachTimes, camTimes, curdir, session, mouse_num)

reachResults = reachTimes{1,1};
reachTimes = reachTimes{2,1};
f = interp1(camTimes, camTimes, reachTimes,'nearest', 'extrap')
count = length(reachTimes);
reachFrames = NaN(count,1)

for i = 1:count
    reachFrames(i) = find(camTimes==f(i))
end

reachTimes = {reachResults; reachTimes; reachFrames};

expname = [curdir, '\', session , '_' , mouse_num , '_reachTimes.xlsx'];

writecell(reachTimes, expname)

end