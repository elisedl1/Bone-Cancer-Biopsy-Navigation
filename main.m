

%%CISC330 - Assignment 3

%%GIVEN POINTS
%axis and tip of tool in tracker frame
axistrack = [0;1;0];
tiptrack = [0;0;0];

%tool marker points in tracker frame
Attrack = [-2 -2 0] + [0 20 0];
Bttrack = [4 -2 0] + [0 20 0];
Cttrack = [-2 4 0] + [0 20 0];

%%CALIBRATION TESTING
disp("Calibration Testing:")
[tipToolTesting, axisToolTesting ] = calibrationtest(Attrack,Bttrack,Cttrack)
disp("")


%%NAVIGATION ERROR ANALYSIS
disp("Navigation Error Analysis:")

%initialize all points in figure
%FM marker (patient) points in tracker frame
AM_track = [-2; -2; 0] + [10;10;0];
BM_track = [4; -2; 0] + [10;10;0];
CM_track = [-2; 4; 0] + [10;10;0];

%Ftool markers in tracker frame
Atool_track = [-2;-2;0] + [0;20;0];
Btool_track = [4;-2;0] + [0;20;0];
Ctool_track = [-2;4;0] + [0;20;0];


%gaussian distibution with 2sigma
RMS = 2*0.25;

%initialize empty spoiled marker point vectors
AM_Track_Spoiled = [];
BM_Track_Spoiled = [];
CM_Track_Spoiled = [];
Atool_track_Spoiled = [];
Btool_track_Spoiled = [];
Ctool_track_Spoiled = [];


%make marker cloud for all 6 points (3 tool, 3 marker)
%each cloud contains 30 points
for jx = 1:30

    %AM spoiling
    %get marker with applied gaussian distributed error
    AM_Track_Spoiled_i = normrnd( AM_track , RMS);
    AM_Track_Spoiled(jx,:) = AM_Track_Spoiled_i;

    %BM spoiling
    %get marker with applied gaussian distributed error
    BM_Track_Spoiled_i = normrnd( BM_track , RMS);
    BM_Track_Spoiled(jx,:) = BM_Track_Spoiled_i;

    %CM spoiling
    %get marker with applied gaussian distributed error
    CM_Track_Spoiled_i = normrnd( CM_track , RMS);
    CM_Track_Spoiled(jx,:) = CM_Track_Spoiled_i;

    %AT spoiling
    %get marker with applied gaussian distributed error
    Atool_track_i = normrnd( Atool_track , RMS);
    Atool_track_Spoiled(jx,:) = Atool_track_i;
    
    %BT spoiling
    %get marker with applied gaussian distributed error
    Btool_track_i = normrnd( Btool_track , RMS);
    Btool_track_Spoiled(jx,:) = Btool_track_i;

    %BT spoiling
    %get marker with applied gaussian distributed error
    Ctool_track_i = normrnd( Ctool_track , RMS);
    Ctool_track_Spoiled(jx,:) = Ctool_track_i;

end

%compute number of points (if changed)
[numPoints,~] = size(Atool_track_Spoiled);
tipSpoilCloud = [];

%for each of the spoiled marker points, compute an orthonormal coordinate
%base and transform the spoiled tool tip in tracker frame to tool frame
for x = 1:numPoints

    %ortho base for tool in tracker frame
    [ToolFrameCenterinTrack_spoiled, vbase1_spoiled, vbase2_spoiled, vbase3_spoiled] = OrthoFrameT(Atool_track_Spoiled(x,:),Btool_track_Spoiled(x,:),Ctool_track_Spoiled(x,:));
    
    %spoiled frame transofmration from marker TO home (tracker)
    [F_hfromm_spoiled] = FrameToHome(ToolFrameCenterinTrack_spoiled,vbase1_spoiled,vbase2_spoiled,vbase3_spoiled);
    
    %%apply transofmraiton matrix onto tip_tool
    tip_tool_spoiled = F_hfromm_spoiled * [0;-20;0;1];
    tip_tool_spoiled(end) = []; %unpad

    %%add to total tip cloud
    tipSpoilCloud(x,:) = tip_tool_spoiled';

end

%compute tool tip errors
%errors are calculated as the distance from the TRUE tool tip and the new
%spoiled tool tip in tracker frame, for each of the 30 spoiled tool tips

tipErrors = [];
%iterate through all 30 "spoiled" tool tips
for xx = 1:numPoints   
    %(0,0,0) is the true tool tip in tracker frame, each row of 
    % tipSpoiledCloud is the "spoiled" tip in tracker frame
    tiperror_i = norm([0;0;0] - [tipSpoilCloud(xx,:)]);
    tipErrors(xx) = tiperror_i;
end

%transpose to get column vector of error distances
tipErrors = tipErrors';

%compute radius of sphere of tool tip error using sigma of fitdist
pd = fitdist(tipErrors, 'Normal');
TipcloudRadius = pd.sigma;

axisSpoilVecs = [];
%for each of the spoiled marker points, compute an orthonormal coordinate
%base and transform the spoiled axis vector in tool frame to tracker frame
for k = 1:numPoints
    
    %ortho base for tool in tracker frame
    [ToolFrameCenterinTrack_spoiled, vbase1_spoiled, vbase2_spoiled, vbase3_spoiled] = OrthoFrameT(Atool_track_Spoiled(k,:),Btool_track_Spoiled(k,:),Ctool_track_Spoiled(k,:));
    %spoiled frame transofmration from marker TO home (tracker)
    [F_hfromm_spoiled] = FrameToHome(ToolFrameCenterinTrack_spoiled,vbase1_spoiled,vbase2_spoiled,vbase3_spoiled);
    
    %%apply transofmraiton matrix onto true tool axis vector
    axis_tool_spoiled = F_hfromm_spoiled * [0;1;0;1];
    axis_tool_spoiled(end) = []; %unpad
    
    %%add to total tip cloud (normalized)
    axisSpoilVecs(k,:) = axis_tool_spoiled';

end


%find angles between (0,1,0) and all spoiled axis vectors
errorAngles = [];
%compute axis angles
for kk = 1:numPoints   

    %compute angle in degrees
    angle = subspace([0;1;0], axisSpoilVecs(kk,:)');
    errorAngle_i = rad2deg(angle);

    %add angle to vector containing all angles
    errorAngles(kk) = errorAngle_i;
end

%tranpose for col vector
errorAngles = errorAngles';

%the angle of the "cone" of uncertainity is the maximum angle computed
%the max angle ensures the cone emcompasses all vh observations
coneAngle = max(errorAngles);


%%find cone starting point using trig (height / y component)
coneY = TipcloudRadius / sin(coneAngle);

%cone starting point that fits on the tip error sphere
%pdf contains drawing of thought process
coneVecPoint = [0;coneY;0];

%rotate true axis vector around z axis with cone angle 
RMATCone = RotationFrame('z', coneAngle);
coneVec = RMATCone * [0;-1;0];


%find where cone intersections with plane containing tumor center
%intersect cone lines and plane to get outside point of spherical tumor
tumorSpherePoint = LinePlaneIntersect([0;-20;0],[0;1;0],coneVecPoint,coneVec);


%compute distance from true axis to outside of tumor to get radius
%of smallest spherical tumor we can hit
tumorRadius = PointLineDist([0;0;0], [0;-1;0], tumorSpherePoint);


%subtract 10% of radius to ensure the tumor is always hit
tumorRadius = tumorRadius - 0.10*tumorRadius
smallestTumorToHit = tumorRadius*2


%%Compute sphere of tumor registration error
%compute tumor center in marker frame
[MarkerFrameCenter, vbase1, vbase2, vbase3] = OrthoFrameT(AM_track,BM_track,CM_track);
[F_hfromm] = FrameToHome(MarkerFrameCenter,vbase1,vbase2,vbase3);
tumorCenter_marker = inv(F_hfromm) * [0;-20;0;1];


tumorRegError = [];
%%compute tumor registration error
%for all error segmented marker points on patient, compute a new ortho
%frame and frame transofmration matrix. Apply this onto the tumor center in
%marker frame to get tumor center in tracker frame. This creates a "cloud"
%of error tumor center points.
for j = 1:numPoints
    
    %ortho base for marker points in tracker frame
    [MarkerFrameCenter_spoiled, mbase1_spoiled, mbase2_spoiled, mbase3_spoiled] = OrthoFrameT(AM_Track_Spoiled(j,:),BM_Track_Spoiled(j,:),CM_Track_Spoiled(j,:));
    
    [F_hfromM_spoiled] = FrameToHome(MarkerFrameCenter_spoiled,mbase1_spoiled,mbase2_spoiled,mbase3_spoiled);
    
    %%apply transofmraiton matrix onto tumor center
    tumor_center_spoiled = F_hfromM_spoiled * tumorCenter_marker;
    tumor_center_spoiled(end) = [];
    
    %%add to total tumor cloud
    tumorRegError(j,:) = tumor_center_spoiled;

end


%spoiled tumor center coordinates in tracker frame
%compute tumor reg error as the distance from the true tumor center
%(0,-20,0) and the "error" tumor centres
targetErrors = [];
for xi = 1:numPoints   
    targeterror_i = norm([0;-20;0] - [tumorRegError(xi,:)]);
    targetErrors(xi) = targeterror_i;
end

%transpose to get column vector
targetErrors = targetErrors';

%compute radius of tumor sphere using sigma of fitdist
pdTumorCloud = fitdist(targetErrors, 'Normal');
tumorCloudRadius = pdTumorCloud.sigma;


%%Compute nerve registration error
%nerve must be outside sphere of tumor registration error
%because markers on body are spoiled the same, the nerve sphere will have
%the same radius as the tumor sphere

%add radius of sphere cloud onto the OUTSIDE of the true tumor point
nerveCenter = tumorSpherePoint + [tumorCloudRadius;0;0];

%compute closest distance for nerve from needle trajectory
%distance from  nerve center to tumor center + 0.5cm for near certaintiy
closestDistanceNerve = PointLineDist([0;-20;0], [0;1;0], nerveCenter) + 0.5



%%PLOTS IGNORE (comment on on submission)
%tumor
% [x,y,z] = sphere;
% x = x*tumorRadius;
% y = y*tumorRadius;
% z = z*tumorRadius;

%tumor error sphere
% [x1,y1,z1] = sphere;
% x1 = x1*tumorCloudRadius;
% y1 = y1*tumorCloudRadius;
% z1 = z1*tumorCloudRadius;

% 
% figure(1)
% surf(x,y,z,'FaceAlpha',0.3)
% title("Tumor with Closest Nerve Sphere Cloud")
% hold on;
% surf(x1,y1,z1,'FaceAlpha',0.3)
% surf(x2+nerveCenter(1),y1,z1,'FaceAlpha',0.3)
% plot3(nerveCenter(1), nerveCenter(2), nerveCenter(3))
% %axis([-10  10    -10 10    -20  20])
% axis([-20 20 -20 20 -20 20]);

% plotv(-1*axisSpoilVecs')
% hold on;
% 
% title("Cone of Uncertainty from origin")
% axis([-10  10    -10 10    -30  25])





