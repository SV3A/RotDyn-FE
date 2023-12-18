classdef Disc < NodeElement
% The 'Disc' class defines a machine element with linear- and rotational
% inertia as well as potential particle unbalance.

properties
  m;            % mass [kg]
  iD;           % transverse mass moment of inertia [kg*m^2]
  iP;           % polar mass moment of inertia [kg*m^2]
  m0;           % localized unbalance [kg]
  e;            % eccentricity of unbalance [m]
  u;            % combined unbalance [kg*m]
  hasUnbalance; % unbalance flag
end

methods
  function obj = Disc(mass, momentInert, momentPolar, varargin)
    obj.m  = mass;
    obj.iD = momentInert;
    obj.iP = momentPolar;
    obj.hasUnbalance = false;

    % Optional discrete unbalance parameters
    if nargin == 4
      obj.u = varargin{1};
      obj.hasUnbalance = true;
    elseif nargin == 5
      obj.m0 = varargin{1};
      obj.e  = varargin{2};
      obj.u  = obj.m0*obj.e;
      obj.hasUnbalance = true;
    end
  end
end
end
