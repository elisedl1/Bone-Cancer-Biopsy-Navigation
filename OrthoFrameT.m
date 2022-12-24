
function [Oe, e1n, e2n, e3n] = OrthoFrameT(A,B,C)
% [Oe, eVec] = OrthoFrame(A,B,C) Compute an orthonormal frame from three
% inputted points (A,B,C). 
%
% INPUTS:
%         A,B,C              - Three points
%         
% OUTPUTS:
%         Oe                 - Centre of orthonormal frame
%         eVec(e1;e2;e3)     - Base vectors of orthonormal frame stored in 3x3 matrix

%exception testing
%check if any two points are the same
if isequal(A,B)|| isequal(A,C) || isequal(C,B)
    Oe = "None";
    eVec = "None";
    disp("All 3 points must be different!");
    return;
end

%%Compute Oe and eVec
%average: add each point and divide by 3 to get centroid
x = (A(1) + B(1) + C(1)) / 3;
y = (A(2) + B(2) + C(2)) / 3;
z = (A(3) + B(3) + C(3)) / 3;

%put points into center matrix
Oe = [x;y;z];

%compute base vectors
%make vector from two points
d = C-A;
%make e1 from two different points
e1 = B-A;
%take cross product of vectors made from points to get vector
%cross produce plane perpendicular to plane with e1 to get e3
e3 = cross(e1, d);
%perpendicular to triangular plane (e2)
e2 = cross(e3, e1);


%check if all are collinear
%check if all x, z or y are the same
%if cross product between all vector = (0,0,0), points are collinear
if cross(e1,e2) == [0;0;0]
    if (cross(e1,e3) == [0;0;0])
        if (cross(e2,e3) == [0;0;0]) 
            Oe = "None";
            eVec = "None";
            disp("Points are collinear!");
            return;
        end
    end         
end

%normalize base vectors
e2n = e2 / norm(e2);
e1n = e1 / norm(e1);
e3n = e3 / norm(e3);


end