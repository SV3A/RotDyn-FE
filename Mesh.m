classdef Mesh < handle
% The 'Mesh' object represent the discretizised elements with associated
% material properties. The resulting object is pass-by-reference.

properties
  numEl % Number of finite shaft elements

  % 5xnumEl matrix containing each element and associated material props:
  %   | el. length       ... numEl |
  %   | el. outer radius ... numEl |
  %   | el. inner radius ... numEl |
  %   | el. density      ... numEl |
  %   | el. Young's mod  ... numEl |
  elements
end


methods
  function obj = Mesh(mesh)
    % Constructor
    obj.numEl = sum(mesh(4,:));

    obj.elements = zeros(5, obj.numEl);
    obj.setGeometry(mesh);
  end

  function setGeometry(obj, mesh)
    % Set the geomtry of the shaft, i.e. length, outer radius, and inner
    % radius of each element.
    startIdx = 1;

    for i = 1:size(mesh, 2)

      reps = mesh(4, i);
      endIdx = startIdx+reps-1;

      elLength    = 1e-3*mesh(1,i)/mesh(4,i);
      elOutRadius = 1e-3*mesh(2,i);
      elInRadius  = 1e-3*mesh(3,i);

      obj.elements(1, startIdx:endIdx) = repelem(elLength,    reps);
      obj.elements(2, startIdx:endIdx) = repelem(elOutRadius, reps);
      obj.elements(3, startIdx:endIdx) = repelem(elInRadius,  reps);

      startIdx = startIdx+reps;
    end
  end

  function setDensity(obj, rho, varargin)
    % Set the desity of all or individual elements.
    if nargin < 3
      obj.elements(4, :) = rho;
    else
      obj.elements(4, varargin{1}) = rho;
    end
  end

  function setEmod(obj, eMod, varargin)
    % Set the Young's modulus of all or individual elements.
    if nargin < 3
      obj.elements(5, :) = eMod;
    else
      obj.elements(5, varargin{1}) = eMod;
    end
  end

end
end
