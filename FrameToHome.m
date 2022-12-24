

function [F_hfromv] = FrameToHome(Ov,v1,v2,v3)
% [F_hfromv]=FrameToHome(Ov,v1,v2,v3) Computes a 4x4 Frame Transformation
% in the form of a 4x4 homogeneous matrix. 
%
% The function computes a pure translation matrix and a pure rotation
% both from frame v to home using the origin of frame v. It combines the 
% two to create the final Frame Transformation matrix.
%
%
% INPUTS:
%         Ov               - Center in v frame in home frame
%         v1               - Base vector 1 in v frame
%         v2               - Base vector 2 in v frame
%         v3               - Base vector 3 in v frame
%         
% OUTPUTS:
%         F_hfromv         - Frame Transformation (4x4 homogeneous matrix)


%normalize base vectors
v1 = v1 / norm(v1);
v2 = v2 / norm(v2);
v3 = v3 / norm(v3);

%compute translation matrix using origin in frame v
%matrix is padded for invertability 
Tv = [1 0 0 1*Ov(1); 0 1 0 1*Ov(2); 0 0 1 1*Ov(3); 0 0 0 1];

%compute rotation matrix using origin in frame v
%matrix is padded for invertability 
R_vtoh = [v1(1) v2(1) v3(1) 0; v1(2) v2(2) v3(2) 0; v1(3) v2(3) v3(3) 0; 0 0 0 1];

%compute frame transformation by combining translation and rotation
%matricies
F_hfromv = Tv * R_vtoh;


end

