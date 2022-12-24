
function I = LinePlaneIntersect(A,n,P,v)
%%QUESTION3 - Intersect-Two-Lines
% I=LinePlaneIntersect(A,n,P,v) find the Intersection of line and plane
%
% INPUTS:
%         A     - Point of plane 
%         n     - Normal vector of plane
%         P     - Point on line
%         v     - direction vector of line
%         
% OUTPUTS:
%         I     - Intersection of line and plane

%Rearrange equation of line and equation of plane to 
%isolate for common t value
%Line equation: L = P + vt
%When L intersects Plane: L-A dot N = 0
%Plug in L: (P + vt - A) dot N = 0
%solve for t
t1 = dot(A-P,n) / dot(v,n);

%check value of t
%if t is NAN, line contained in plane
if isnan(t1) 
    disp("Line contained in plane!")
    I = "Infinite";
    return;
%if t is infinite, lines are parallel
elseif isinf(t1)
    disp("Lines are parallel!");
    I = "None";
    return;
%otherwise intersection
else
    %intersection point - plug in t to Line equation
    I = P + (v*t1);
end
end
