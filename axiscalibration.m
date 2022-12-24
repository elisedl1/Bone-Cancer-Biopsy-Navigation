
function axisTool = axiscalibration(pivotPoints)
%%QUESTION2 - Axis Calibration
% tipTool = tipcalibration(pivotPoses) Computes the Tool Axis in tool
% Frame. The poses are initially moving along a circle (3 for each point).
% A circle is fitted on each planar circle, and the average of the center
% norms are used as the tracker axis. The same method as tool tip is used
% to compute the axis in tool frame.
%
% INPUTS:
%         pivotPoses - Marker positions supplied by the tracker in the form
%                      of a 1x3 cell array (Apoints, Bpoints, Cpoints)
% OUTPUTS:
%         axisTool   - axis tool in tool frame


%extract A B and C points from cell array
Aposes = pivotPoints{1};
Bposes = pivotPoints{2};
Cposes = pivotPoints{3};


%fit a planar circle onto each pose path using CircFit3D
%the circleNormal is the normal of each planar circle form the center of
%the circle. This is the axis in tracker frame.
%Fit for A
[~, circleNormalA, ~] = CircFit3D(Aposes);
%Fit for B;
[~, circleNormalB, ~] = CircFit3D(Bposes);
%Fit for B
[~, circleNormalC, ~] = CircFit3D(Cposes);


%adjust normal direction to match each other
if (dot(circleNormalA, circleNormalB) < 0)
    circleNormalB =  -circleNormalB;
end

if (dot(circleNormalA, circleNormalC) < 0)
    circleNormalC =  -circleNormalC;
end


%compute avg of three norms to get axis vector in tracker frame
axis_tracker = (circleNormalA + circleNormalB + circleNormalC) / 3;


%COMPUTE IN TOOL FRAME
%get number of poses
[numPoses,~] = size(Aposes);

%transform each to tool frame
%each pose has a different coordinate system (ie center, base vectors)
%you can transform the computed tracker axis for each pose and average them
%to compute the axis in TOOL FRAME
%for each pose, compute its ortho frame and transform pH to tool frame
vmCombined = [];

for ix = 1:numPoses

    %generate frame for each row of poses
    [ToolFrameCenter, vbase1, vbase2, vbase3] = OrthoFrameT(Aposes(ix,:),Bposes(ix,:),Cposes(ix,:));
    [F_hfromt] = FrameToHome(ToolFrameCenter,vbase1,vbase2,vbase3);

    %invert frame to go from tracker to tool
    F_tfromh = inv(F_hfromt);

    %extract rotational aspect of frame transofmraiton matrix (no
    %transofmrations are needed)
    F_tfromh = F_tfromh(1:3,1:3);

    %%apply transofmraiton matrix onto axis_tracker
    vmI = F_tfromh * axis_tracker;

    vmCombined(:,ix) = vmI;

end

%avg all poses to get toolAxis in marker frame
axisTool = mean(vmCombined,2);

end


