frames = read(vid, [29001,29100]);

for i = 1: 100
    imshow(frames(:,:,:,i));
    text(50,50, num2str(i))
end

%%
a= [];
for i = 1:10
    a = [a,datetime('now', 'format', 'HH:mm:ss.SSS')];

end


%%
all = {[1,2,4,1,3],a}