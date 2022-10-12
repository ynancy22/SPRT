clc;close all
cur_dir = 'R:\Basic_Sciences\Phys\ContractorLab\Projects\NY\6_Behavior\SPRT';
cur_dir = uigetdir(cur_dir, 'Select a folder');
csv_list = dir(fullfile(cur_dir, '*DMKDLC*.csv'));
avi_list = dir(fullfile(cur_dir, '*DMK*.avi'));

% create peaks for login result
if exist([cur_dir,'\peaks.mat']) == 2
    peaks = load([cur_dir,'\peaks.mat']).peaks;
    disp('load previous result')
elseif exist('peaks','var') == 1
    disp('result log existed')
else
    peaks = [];
    disp('create new')
end

%% batch analysis (all csv in folder)
xdata=[];ydata=[]; xvar=[]; yvar=[];
for csv_n=1:length(csv_n)
    [xdata, ydata, xvar, yvar] = sprt_analysis(csv_n, csv_n, xdata, ydata, xvar, yvar);
end

%% Batch filter traj

% start from specified file in list
start = input("file number to start from? ");
if isempty(start)
    start = 1 ;
end

for csv_n= start:length(csv_list)
    
    peak = sprt_analysis_peaks(csv_list, csv_n);
    
    % options
    next = input("Continue?(Quit/Redo) ",'s');
    if next == 'q'  % quit the loop        
        peaks = [peaks;peak];
        disp(['Finish at ',num2str(csv_list(csv_n).name(19:25))])
        disp([num2str(start),' to ', num2str(csv_n), ' from the list'])
        break
    elseif next == 'r'  % redo last file
        peak = sprt_analysis_peaks(csv_list, csv_n);
    end
    
    % combine result
    peaks = [peaks;peak];
end
% save result as mat (cell format)
save([cur_dir,'\peaks.mat'],'peaks')

%% Batch sort traj

% start from specified file in list
start = input("file number to start from? ");
if isempty(start)
    start = 1 ;
end

for avi = start:csv_n
    peaks_vid = sprt_analysis_sort(avi_list, avi, peaks)
    
    % options
    next = input("Continue?(Quit/Redo) ",'s');
    if next == 'q'  % quit the loop
        disp(['Finish at ',num2str(avi_list(avi).name(19:25))])
        disp([num2str(start),' to ', num2str(avi), ' from the list'])
        break
    elseif next == 'r'  % redo last file
        
    end
end

%% single file analysis (load individual csv)
[trajx, trajy]=sprt_analysis_single();




%% Functions
function [xdata, ydata, xvar, yvar]=sprt_analysis(files, f,xdata, ydata, xvar, yvar)
close all
%% load csv cellfile
% csv_dir = 'G:\My Drive\1-Contractor Lab\DLC\20220630_analyze';
% [file, path] = uigetfile([csv_dir,'\*.csv']);
% addpath(path)
% %
path = files(f).folder;
file = files(f).name;

data = readmatrix([path,'\',file]);

window = [50,50];
%
% rf = data(:, 2:4);
% rw = data(:, 5:7);
% lf = data(:, 8:10);
% lw = data(:, 11:13);
% nose = data(:, 14:16);

%%
paws = readtable("G:\My Drive\1-Contractor Lab\6_Behavior\SPRT\Paw list.xlsx");
mouse_num = str2num(file(23:25));
day = str2num(file(20:21));
disp([file(23:25),' on day ',file(20:21)])
%%
paw = paws.side(find(paws.mouse==str2num(file(23:25))));
if isempty(paw)
    disp("mouse paw not defined")
    paw = input("which side? (L/R) ",'s');
else
    paw = paw{1,1};
end
% specify data to process
if paw == "L"||paw == "l"
    xy = data(:, 11:13);
elseif paw == "R"||paw == "r"
    xy = data(:, 5:7);
end

%% plot accurate tracked points
figure(1)
hold on
xy_filt = xy;
xy_filt(xy(:,3)<0.9,:) = NaN; % filter out inaccurate points
c = linspace(1,10,length(xy_filt));
scatter(xy(:,1),xy(:,2), 2, 'k+')
scatter(xy_filt(:,1),xy_filt(:,2), 5, c, 'filled');
legend('all data', 'p>0.9')
title('tracked point')
hold off
% xdim = xlim; ydim = ylim;
%% find peaks in reaching (x-axis)
% figure(2)
[~,locs] = findpeaks(xy(:,1),'MinPeakHeight', 510,'MinPeakDistance', 300 );
% plot(xy(:,1))
% hold on
% plot(locs,xy_filt(locs, 1),'*')
%
% figure(3)
% hold on
% scatter(xy_filt(:,1),xy_filt(:,2), 2,'k', 'filled');
% scatter(xy(locs,1),xy(locs,2), 10, 'ro');
%
%%
trajx = [];
trajy = [];
traj_num = 0;
for w = 1:length(locs)
    if locs(w)>750 && locs(w)<length(xy)-window(2)
        trajx = [trajx,xy_filt(locs(w)-window(1):locs(w)+window(2),1)];
        trajy = [trajy,xy_filt(locs(w)-window(1):locs(w)+window(2),2)];
        %         plot(trajx,trajy)
        traj_num = traj_num+1;
    end
end

if isempty(trajx)==0
    varx = [day;mouse_num;var(trajx,0,2,'omitnan')];
    vary = [day;mouse_num;var(trajy,0,2,'omitnan')];
    trajx = [day;mouse_num;mean(trajx,2,'omitnan')];
    trajy = [day;mouse_num;mean(trajy,2,'omitnan')];
    %
    xdata = [xdata,trajx];
    ydata = [ydata,trajy];
    xvar = [xvar,varx];
    yvar = [yvar,vary];
end
%%
% figure()
% img = imread('G:\My Drive\1-Contractor Lab\6_Behavior\SPRT\POV.bmp');
% imshow(img)
% hold on
% plot(trajx(3:end), trajy(3:end), 'r-')

%%
% legend()
% img = imread('R:\Basic_Sciences\Phys\ContractorLab\Projects\NY\6_Behavior\SPRT\POV.bmp');
% imshow(img)
% hold on

% plot(trajs(:,1),trajs(:,2));xlim(x); ylim(y);
end

function [trajx, trajy]=sprt_analysis_single()
close all
%% load csv cellfile
csv_dir = 'G:\My Drive\1-Contractor Lab\DLC\20220630_analyze';
[file, path] = uigetfile([csv_dir,'\*.csv']);
addpath(path)
%
% path = files(f).folder;
% file = files(f).name;

data = readmatrix([path,'\',file]);

window = [50,50];
%
% rf = data(:, 2:4);
% rw = data(:, 5:7);
% lf = data(:, 8:10);
% lw = data(:, 11:13);
% nose = data(:, 14:16);

%%
paws = readtable("G:\My Drive\1-Contractor Lab\6_Behavior\SPRT\Paw list.xlsx");
mouse_num = str2num(file(23:25));
day = str2num(file(20:21));
disp([file(23:25),' on day ',file(20:21)])

paw = paws.side(find(paws.mouse==str2num(file(23:25))));
if isempty(paw)
    disp("mouse paw not defined")
    paw = input("which side? (L/R) ",'s');
else
    paw = paw{1,1};
end
% specify data to process
if paw == "L"||paw == "l"
    xy = data(:, 11:13);
elseif paw == "R"||paw == "r"
    xy = data(:, 5:7);
end

%% plot accurate tracked points
figure(1)
hold on
xy_filt = xy;
xy_filt(xy(:,3)<0.9,:) = NaN; % filter out p<0.9 points
c = linspace(1,10,length(xy_filt));
scatter(xy(:,1),xy(:,2), 2, 'k+')
scatter(xy_filt(:,1),xy_filt(:,2), 5, c, 'filled');
legend('all data', 'p>0.9')
title('tracked point')
hold off
% xdim = xlim; ydim = ylim;
%% find peaks in reaching (x-axis)
% figure(2)
[~,locs] = findpeaks(xy(:,1),'MinPeakHeight', 510,'MinPeakDistance', 300 );
% plot(xy(:,1))
% hold on
% plot(locs,xy_filt(locs, 1),'*')
%
% figure(3)
% hold on
% scatter(xy_filt(:,1),xy_filt(:,2), 2,'k', 'filled');
% scatter(xy(locs,1),xy(locs,2), 10, 'ro');
%
%%
trajx = [];
trajy = [];

disp("Pick trajecttory (right=accept)")

for w = 1:length(locs)
    if locs(w)>750 & locs(w)<length(xy)-window(2)
        currx= [xy_filt(locs(w)-window(1):locs(w)+window(2),1)];
        curry = [xy_filt(locs(w)-window(1):locs(w)+window(2),2)];
        plot(currx,curry)
        xlim([300 600]); ylim([200 500]);
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
    end
end
traj_num = size(trajx,2);


figure(4)
img = imread('G:\My Drive\1-Contractor Lab\6_Behavior\SPRT\POV_T03.bmp');
imshow(img)
hold on
title(file(20:25))
for w = 1:traj_num;
    plot(trajx,trajy)
end
plot(mean(trajx,2,'omitnan'), mean(trajy,2,'omitnan'),'r-','LineWidth', 3)
hold off

save = input("Save results (excel and plot?(y/n) ",'s');
if save == 'y' && isempty(trajx)==0
    log_name = [path+"\"+file(1:25)+"_traj.xlsx"];
    %     outputdata = [trajx;trajy];
    %     writematrix(outputdata, log_name)
    writematrix( trajx,log_name);
    writematrix( [0],log_name,'WriteMode', 'append');
    writematrix( trajy,log_name,'WriteMode', 'append');
    saveas(figure(4), [path,file(1:25),'_trajFiltered.svg']);
end



% save = input("Save results as excel?(y/n) ",'s');
% if save == 'y' && isempty(trajx)==0
%     log_name = [path+"\"+file(1:25)+"_traj.xlsx"];
%     xlswrite(log_name, trajx);
%     xlswrite(log_name, trajy, 1, ["A"+num2str(length(trajx)+2)]);
%
%
% else
% end
% %
% if isempty(trajx)==0
%     varx = [var(trajx,0,2,'omitnan')];
%     vary = [var(trajy,0,2,'omitnan')];
%     trajx = [mean(trajx,2,'omitnan')];
%     trajy = [mean(trajy,2,'omitnan')];
%     %
%     xdata = [xdata,trajx];
%     ydata = [ydata,trajy];
%     xvar = [xvar,varx];
%     yvar = [yvar,vary];
% end
%%
% legend()
% img = imread('R:\Basic_Sciences\Phys\ContractorLab\Projects\NY\6_Behavior\SPRT\POV.bmp');
% imshow(img)
% hold on

% plot(trajs(:,1),trajs(:,2));xlim(x); ylim(y);
end

function peak=sprt_analysis_peaks(csv_list, list_num)
%% load csv cellfile
path = csv_list(list_num).folder;
file = csv_list(list_num).name;
data = readmatrix([path,'\',file]);

win = [50,50];

%% Get preferred paw
paws = readtable("R:\Basic_Sciences\Phys\ContractorLab\Projects\NY\6_Behavior\SPRT\Paw list.xlsx");
mouse_num = str2num(file(23:25));
day = str2num(file(20:21));


paw = paws.side(find(paws.mouse==str2num(file(23:25))));
if isempty(paw)
    disp("mouse paw not defined")
    paw = input("which side? (L/R) ",'s');
else
    paw = paw{1,1};
end
% specify data to process
if paw == "L"||paw == "l"
    xy = data(:, 11:13);
elseif paw == "R"||paw == "r"
    xy = data(:, 5:7);
end

%% filter data and find furthest reach
xy_filt = xy;
xy_filt(xy(:,3)<0.9,:) = NaN; % filter out p<0.9 points

[~,peak] = findpeaks(xy(:,1),'MinPeakHeight', 510,'MinPeakDistance', 300 );

disp([file(19:25), ' with ', num2str(length(peak)), ' peaks'])
%%

figure(1)
%     disp("Pick trajecttory (right=accept)")

for w = 1:length(peak)
    frame = peak(w);
    if frame>750 & frame<length(xy)-win(2)
        plot(xy_filt(frame-win(1):frame+win(2),1),...
            xy_filt(frame-win(1):frame+win(2),2))
        xlim([300 600]); ylim([200 500]);
        legend(num2str(frame))
        k = waitforbuttonpress;
        % 28 leftarrow
        % 29 rightarrow
        % 30 uparrow
        % 31 downarrow
        accept = double(get(gcf,'CurrentCharacter')) ;
        if accept == 29;
            peak(w,2) = 1;
        else
            peak(w,2) = 0;
        end
    end
end
peak = {file(1:29), peak};
% peaks = [peaks;peak];
%     disp("Next file...")
end

function peak_vid = sprt_analysis_sort(avi_list, list_num, peaks)
path = avi_list(list_num).folder;
avi = avi_list(list_num).name;
csv = [peaks{list_num, 1},'.avi'];
% csv = [csv,'.avi'];

if avi ~= csv
    disp("list name not match")
    return
else disp("matched file")
end

vid = VideoReader([path, '\', avi]);

%%
peak = peaks{list_num,2};
peak_num = length(peak);

for p = 1:peak_num
    if peak(p,2) == 1
        frame = peak(p,1);
        frames = read(vid, [frame-20,frame+300]);
        sort = [];
        
        while isempty(sort)
            for i = 1:101
                imshow(frames(200:500,300:600,1,i));
            end
            
            %             for f = frame-50: frame+50
            %                 img = read(vid,f);
            %                 imshow(img)
            %             end
            sort = input([num2str(frame)+" frame result? (2=suc/1=fail) "]);
            
        end
        
        if sort < 5
            peak(p,3) = sort;
        elseif sort == 9
            break
        end
    end
    
end

peak_vid = {peaks{list_num, 1}, peak}


end

%     %%
%     fig = implay([path,'\',avi]);
%     h = fig.DataSource.Controls;
%
%
%     %%
%     play(h)
%
%     a = input("wait to pause");
%     pause(h)
%     a = input("wait to play");
%     %%
%     play(h)
%
%     k = waitforbuttonpress;
%     % 28 leftarrow
%     % 29 rightarrow
%     % 30 uparrow
%     % 31 downarrow
%     accept = double(get(gcf,'CurrentCharacter')) ;
%     % accept = input("accept trajectory?" );
%     if accept == 29;
%         %     traj = [traj,w]
%         trajx = [trajx,currx];
%         trajy = [trajy,curry];
%
%         %             plot(trajx,trajy)
%     end
%
%
%     while 1==1
%         reach = [];
%         while isempty(reach)
%             reach = input("Next reach: ");
%         end
%
%         if reach == 9
%
%             break;
%         elseif reach < 4
%             pause(h)
%             CurFrameN = h.CurrentFrame;
%             % log CurFrameN to result
%             trials = [CurFrameN, reach];
%             pause(0.001)
%             play(h);
%
%         end
%
%     end
%
%
%     %%
%     pause(h)
%     CurFrameN = fig.DataSource.Controls.CurrentFrame
%     % log CurFrameN to result
%     play(h);
%
