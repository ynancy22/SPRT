function reach_test_sys(cam, behavCam, sweepTime, pdir, behavFPS, camFPS)
% (cam1(webcam,30Hz), cam2(100Hz), time(sec), folder)
% run in parpool for 2 cams (cam/behavCam) for sweepTime (sec)
% files saved in pdir/test

%%
% disp("=============")
warning off
delete('stopSign.mat')
disp('System test START')

testdir = [pdir,'test'];
session = "test";
mouseNum = 0;
stop(cam)
stop(behavCam)

f1 = parfeval(@singleCamAcquisitionDiskLoggingTimed, 2, cam, mouseNum, session, sweepTime, testdir , camFPS);
f2 = parfeval(@singleCamAcquisitionDiskLoggingTimed, 2, behavCam, mouseNum, session, sweepTime, testdir, behavFPS);

[~, reachTimes] = reach_precision_mouse([], "test system", mouseNum, sweepTime, "off");
save('stopSign.mat','behavFPS')

[behavFPS, behavCamTimes] = fetchOutputs(f1);
[camFPS, camTimes] = fetchOutputs(f2);
[camFPS, behavFPS]

reach_align_result(reachTimes, behavCamTimes, camTimes, pdir, session, mouseNum)

% show recorded file
% cd(pdir)
% winopen([pdir,'\test'])
delete('stopSign.mat')
disp('System test DONE')
disp("=============")
end