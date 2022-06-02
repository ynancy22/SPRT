function reach_test_sys(cam, behavCam, sweepTime, pdir, camFPS, behavFPS)
% (cam1(webcam,30Hz), cam2(100Hz), time(sec), folder)
% run in parpool for 2 cams (cam/behavCam) for sweepTime (sec)
% files saved in pdir/test

%%
% disp("=============")
% warning on
delete('stopSign.mat')
disp('System test START')

testdir = [pdir,'\test'];
stop(cam)
stop(behavCam)
mouseNum = 0;
session = 'test';

f1 = parfeval(@singleCamAcquisitionDiskLoggingTimed, 1, cam, mouseNum, session, sweepTime, testdir , camFPS);
f2 = parfeval(@singleCamAcquisitionDiskLoggingTimed, 1, behavCam, mouseNum, session, sweepTime, testdir, behavFPS);

reach_precision_mouse([],session, mouseNum, sweepTime, "off");

pause(1)
save('stopSign.mat','behavFPS')

% [outputState_cam] = fetchOutputs(f1);
% [outputState_pCam] = fetchOutputs(f2);

pause(1)

[vidFPS_behavCam_cam] = [fetchOutputs(f1), fetchOutputs(f2)]


% show recorded file
% cd(pdir)
% winopen([pdir,'\test'])
delete('stopSign.mat')
disp('System test DONE')
disp("=============")
end