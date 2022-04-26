function reach_test_sys(cam, behavCam, sweepTime, pdir, behavFPS, camFPS)
% (cam1(webcam,30Hz), cam2(100Hz), time(sec), folder)
% run in parpool for 2 cams (cam/behavCam) for sweepTime (sec)
% files saved in pdir/test

%%
% disp("=============")
warning off
delete('stopSign.mat')
disp('System test START')

testdir = [pdir,'\test'];
stop(cam)
stop(behavCam)

f1 = parfeval(@singleCamAcquisitionDiskLoggingTimed, 1, cam, 1, sweepTime,testdir , 1, camFPS);
f2 = parfeval(@singleCamAcquisitionDiskLoggingTimed, 1, behavCam, 2, sweepTime, testdir, 1, behavFPS);

reach_precision_mouse([], "test system", [], "off");
save('stopSign.mat','behavFPS')

[outputState_cam] = fetchOutputs(f1);
[outputState_pCam] = fetchOutputs(f2);



% show recorded file
% cd(pdir)
% winopen([pdir,'\test'])
delete('stopSign.mat')
disp('System test DONE')
disp("=============")
end