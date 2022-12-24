
function D = PointLineDist(P, v, A)
%%QUESTION1 - Distance-of-Point-from-Line
% [D = PointLineDist(P,v,A) Finds the distance from a point to a line.
%
% INPUTS:
%         P     - Point on line 
%         v     - Direction vector of line
%         A     - Point A
% OUTPUTS:
%         D - Distance between point and line


%normalize direction vector
v = v / norm(v);

%compute distance from A to P
c = norm(A-P);

%compute the absolute value of the dot product of direction vector, and
%A-P vector subtraction
%This equals the distance from the point P to A where they are orthogonal
a = abs(dot(v, A-P));

%compute final distance and take square root
D = sqrt((c+a)*(c-a));

%round final distance to 5 decimals for simplicity
D = round(D, 5);

end
