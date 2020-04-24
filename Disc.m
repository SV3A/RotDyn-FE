classdef Disc < NodeElement
% The 'Disc' class defines a machine element with linear- and rotational
% inertia as well as potential particle unbalance.

properties
  m;  % mass [kg]
  iD; % transverse mass moment of inertia [kg*m^2]
  iP; % polar mass moment of inertia [kg*m^2]
  m0; % localized unbalance [kg]
  e;  % eccentricity of unbalance [m]
end

methods
  function obj = Disc(mass, momentInert, momentPolar, m0, e)
    obj.m  = mass;
    obj.iD = momentInert;
    obj.iP = momentPolar;
    obj.m0 = m0;
    obj.e  = e;
  end
end
end
