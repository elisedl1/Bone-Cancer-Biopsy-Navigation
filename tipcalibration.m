
function tipTool = tipcalibration(pivotPoses)
%%QUESTION2 - Tip Calibration
% tipTool = tipcalibration(pivotPoses) Computes the Tool Tip in tool
% Frame. It uses a sphere fit approach and computes the average in both
% tracker and tool frame. Each pose's ortho frame is used to transform the
% tip in tracker to the tip in tool and the average is used.
%
% INPUTS:
%         pivotPoses - Marker positions supplied by the tracker in the form
%                      of a 1x3 cell array (Apoints, Bpoints, Cpoints)
% OUTPUTS:
%         tipTool   - Tip tool in tool frame


%separate cell array into x,y,z points for marker A, marker B and marker C
Aposes = pivotPoses{1};
Bposes = pivotPoses{2};
Cposes = pivotPoses{3};

%COMPUTE TIP IN TRACKER FRAME
%A B and C positions are already moving in a spherical way
%fit a sphere onto the positions to find the center of each

%spherefit A
[CenterA,~] = sphereFit(Aposes);
CenterA_track = round(CenterA,1);

%spherefit B
[CenterB,~] = sphereFit(Bposes);
CenterB_track = round(CenterB,1);

%spherefit C
[CenterC,~] = sphereFit(Cposes);
CenterC_track = round(CenterC,1);

%the average of the centeres is the tool tip in TRACKER FRAME
%average them to compute tip in tracker frame
tip_tracker = ((CenterA_track + CenterB_track + CenterC_track) / 3);
%transpose and pad for dimensionality
tip_tracker = [tip_tracker  1]';


%get number of poses
[numPoses,~] = size(Aposes);

%%COMPUTE IN TOOL FRAME
%each pose has a different coordinate system (ie center, base vectors)
%you can transform the computed tracker tip for each pose and average them
%to compute tht ip in TOOL FRAME

%for each pose, compute its ortho frame and transform pH to tool frame
pmCombined = [];

for ix = 1:numPoses

    %generate Frame (tool to home/tracker)
    [ToolFrameCenter, vbase1, vbase2, vbase3] = OrthoFrameT(Aposes(ix,:),Bposes(ix,:),Cposes(ix,:));
    [F_hfromt] = FrameToHome(ToolFrameCenter,vbase1,vbase2,vbase3);

    %take inverse of frame matrix to get tracker to tool frame
    %%apply transofmraiton matrix onto tip_tracker
    pmI = inv(F_hfromt) * tip_tracker;

    %append to combination matrix containing ALL tip in tool coords
    pmCombined(:,ix) = pmI;

end

%compute the average of all the tips computed in tool frame, unpad
tipTool = round(mean(pmCombined,2),1);
tipTool(end) = [];

 
end

