classdef Bearing < NodeElement
% The 'Bearing' class defines a machine element with linear- and/or rotational
% stiffness.

properties
  localK; % Local component stiffness matrix, either 2x2 or 4x4
end

methods
  function obj = Bearing(k)
    obj.localK = k;
  end
end
end
