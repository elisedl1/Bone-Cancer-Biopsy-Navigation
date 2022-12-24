

function [RMat,HMat] = RotationFrame(ax,a)
%%QUESTION10 - Rotation About Frame Axis
% [C,R]=RotationFrame(ax,a) Computes a Rotation Matrix (3x3) and a
% Homogeneous rotation matrix (4x4) using an inputted angle and axis of
% rotation
%
% INPUTS:
%         ax               - Axis of rotation
%         a                - Angle of rotation
%         
% OUTPUTS:
%         rMat             - Rotation matrix (3x3)
%         hMat             - Homogeneous matrix (4x4)

%%check if user inputted x,y or z axis
if ax == "x"
    %rotation matrix x
    RMat = [1 0 0; 0 cosd(a) -sind(a); 0 sind(a) cosd(a)];
    %homo matrix x
    HMat = [1 0 0 0; 0 cosd(a) -sind(a) 0; 0 sind(a) cosd(a) 0; 0 0 0 1];
elseif ax == "y"
    %rotation matrix y
    RMat = [cosd(a) 0 sind(a); 0 1 0; -sind(a) 0 cosd(a)];
    %homo matrix y
    HMat = [cosd(a) 0 sind(a) 0; 0 1 0 0; -sind(a) 0 cosd(a) 0; 0 0 0 1];
elseif ax == "z"
    %rotation matrix z
    RMat = [cosd(a) -sind(a) 0; sind(a) cosd(a) 0; 0 0 1];
    %homo matrix z
    HMat = [cosd(a) -sind(a) 0 0; sind(a) cosd(a) 0 0; 0 0 1 0; 0 0 0 1];
else
    disp("Invalid axis; please enter x,y or z!")
end



end