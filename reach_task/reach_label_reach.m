basedir = 'G:\My Drive\1-Contractor Lab\6_Behavior\SPRT';
[vid,path] = uigetfile([basedir,'\*.avi']);

%%
close all
fig = implay([path,vid]);
vidplay = fig.DataSource.Controls;


%%
play(vidplay)

a = input("wait to pause")
pause(vidplay)
a = input("wait to play")
%%
play(vidplay)



 k = waitforbuttonpress;
        % 28 leftarrow
        % 29 rightarrow
        % 30 uparrow
        % 31 downarrow
        accept = double(get(gcf,'CurrentCharacter')) ;
        % accept = input("accept trajectory?" );
        if accept == 29;
            %     traj = [traj,w]
            trajx = [trajx,currx];
            trajy = [trajy,curry];
            
            %             plot(trajx,trajy)
        end
        
        
while 1==1
    reach = [];
    while isempty(reach)
        reach = input("Next reach: ");
    end
    
    if reach == 9
        
        break;
    elseif reach < 4
        pause(vidplay)
        CurFrameN = fig.DataSource.Controls.CurrentFrame;
        % log CurFrameN to result
        trials = [CurFrameN, reach];
        pause(0.001)
        play(vidplay);
        
    end
    
end


%%
pause(vidplay)
CurFrameN = fig.DataSource.Controls.CurrentFrame
% log CurFrameN to result
play(vidplay);