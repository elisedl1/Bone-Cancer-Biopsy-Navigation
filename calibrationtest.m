

function  [tipToolTesting, axisToolTesting ] = calibrationtest(Attrack,Bttrack,Cttrack)
% calibrationtesting calls tipcalibration and axiscalibration to confirm
% the ground truth calibration will work. It generates simulated poses for
% tip calibration and axis calibration. Each explanation is included within
% the comments.
%
% INPUTS:
%         Attrack,Bttrack,Cttrack - Initial positions of A,B,C markers in
%                                   tracker frame
% OUTPUTS:
%         tipToolTesting          - Tip tool in tool frame
%         axisToolTesting         - Tip tool in tool frame

%%TOOL TIP calibration
%20 poses were generated randomly with an angle ranging from 0 to 60 degrees. 
% A rotation matrix using this random angle along with either the z or x axis w
% as applied onto the original A, B, C markers. A 60-degree angle maximum allowed 
% for a sufficiently wide cone. 

%initialize cone poses
tempAtotal = [];
tempBtotal = [];
tempCtotal = [];

%%Generate 20 random poses with 60 degree angle max cone
for ix = 1:20

    %randomly choose x or z axis
    axisRand = randi([0,1]);
    if axisRand == 0
        a = 'x';
    elseif axisRand == 1
        a = 'z';
    end

    %choose random angle from -60 to 60 degrees
    %make rotation matrix on either z or x axis from above randomization
    RandAngle = randi([-60,60]);
    [rm, ~] = RotationFrame(a, RandAngle);
    tempA = rm*Attrack';
    tempB = rm*Bttrack';
    tempC = rm*Cttrack';

    %add randomly gnerated pose to final poses
    tempAtotal = [tempAtotal; tempA'];
    tempBtotal = [tempBtotal; tempB'];
    tempCtotal = [tempCtotal; tempC'];

end


%combine into cell array for input
AposesTip = tempAtotal;
BposesTip = tempBtotal;
CposesTip = tempCtotal;
pivotPosesTip = {[AposesTip] [BposesTip] [CposesTip]};

%call calibration
tipToolTesting = tipcalibration(pivotPosesTip);


%%AXIS CALIBRAITON TESTING
%initialize final axis poses
tempAtotalAxis = [];
tempBtotalAxis = [];
tempCtotalAxis = [];

%degree incrementation is 360 / number of poses
%20 poses were chosen
%by using a degree increment, you are ensuring the planar circle is
%generated the same direction, so the normal vector computed in
%axiscalibration.m is pointing the correct direction and not upside down

deg = 360/20;

%computation rotation matrix using degree incrementation
[rm, ~] = RotationFrame("y", deg);

%Generate 20 random points for A,B,C planar circles
for ix = 1:20

    %start with original A,B,C poses, and add new A,B,C every iteration
    tempAtotalAxis = [tempAtotalAxis; Attrack];
    tempBtotalAxis = [tempBtotalAxis; Bttrack];
    tempCtotalAxis = [tempCtotalAxis; Cttrack];

    %compute new A,B,C on planar circle by using rotation matrix with added
    %degree each time
    Attrack = (rm*Attrack.').';
    Bttrack = (rm*Bttrack.').';
    Cttrack = (rm*Cttrack.').';

end

%combine final poses into cell array
AposesAxis = tempAtotalAxis;
BposesAxis = tempBtotalAxis;
CposesAxis = tempCtotalAxis;
%output set as cell array
pivotPosesAxis = {[AposesAxis] [BposesAxis] [CposesAxis]};

%call axis calibration
axisToolTesting = axiscalibration(pivotPosesAxis);


end


