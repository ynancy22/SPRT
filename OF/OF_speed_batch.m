path = uigetdir();
xls_list = dir(fullfile(path, '*tracking.xlsx'));


out = [];
%%
for i = 1%length(xls_list)
    filename = xls_list(i).name
    of_trace = readmatrix([path,'\', filename]);
    out(1:height(of_trace), i) = of_trace(:,7);
end

%%
out(out==0) = NaN;
avg_speed =  mean(out,1,'omitnan')

%%
out(out>200) = 0;
sum_dist = sum(out,1,'omitnan')

%%
for f = 1:length(xls_list)
    f
    filename = xls_list(f).name
    of_trace = readmatrix([path,'\', filename]);
    fs = 30;
    of_trace(:,1) = 1/fs;
    of_trace(:,2) = cumsum(of_trace(:,1));
    
    of_trace(of_trace==0)= NaN;
    of_trace(:,4:5) = fillmissing(of_trace(:,4:5),'nearest');
    %
    
    for i = 2:height(of_trace)
        % if ~isnan(data(i,4))
        of_trace(i,6) = norm((of_trace(i, 4:5)-(of_trace(i-1, 4:5))));
    end
    
    of_trace(:,7) = of_trace(:,6)*ratio; % mm/frame
    % of_trace(:,8) = of_trace(:,7)./of_trace(:,2);
    of_trace(:,8) = of_trace(:,7)*30;
    
    
    
    disp("Process speed data(filter)")
    
    Fs_in = fs;
    Fs_out = 5;
    
    %1)
    Behavior_distance_raw = of_trace(:,8);
    
    
    %2) Now filter using 1-s median filter
    Behavior_filterFactor = Fs_in;
    Behavior_distance_filter = medfilt1(Behavior_distance_raw, Behavior_filterFactor,'omitnan','truncate');
    of_trace(:,9) = Behavior_distance_filter;
    
    %3)Now downsample to 5Hz
    Behavior_speed_filter = Behavior_distance_filter;%*Fs_in;
    
    %compute downsample factors for the two movies (to make them 5 Hz)
    downsampledRate = Fs_out;%define the target downsample rate
    Behavior_frameRate = Fs_in;
    Behavior_downsampleFactor = round(Behavior_frameRate/downsampledRate);
    
    if Behavior_downsampleFactor > 1
        
        Behavior_speed_filter = mean(reshape([Behavior_speed_filter(:); ...
            nan(mod(-numel(Behavior_speed_filter),Behavior_downsampleFactor),1)],...
            Behavior_downsampleFactor,[]),'omitnan');
    end
    
    %   Behavior_distance_filter20 = nansum(reshape([Behavior_distance_filter(:); nan(mod(-numel(Behavior_distance_filter),Behavior_downsampleFactor),1)],Behavior_downsampleFactor,[]));
    %   Behavior_distance_filter20 = Behavior_distance_filter20';%transpose the distance traces
    %   speedTrace = Behavior_distance_filter20*Fs_out;
    speedTrace = Behavior_speed_filter';
    of_trace(1:length(speedTrace),10) = speedTrace;
    
    
    [~,filename,~] = fileparts(filename);
    xlsname = [path,'\',filename,'_new.xlsx'];
    writematrix(of_trace, xlsname)
    
    
    out(1:height(of_trace), f) = of_trace(:,7);
end