classdef Mesh < handle
% The 'Mesh' object represent the discretizised elements with associated
% material properties.

properties
  numEl % Number of finite shaft elements

  scale % Length scale, default is 1

  % 6xnumEl matrix containing each element and associated material props:
  %   | el. length       ... numEl               |
  %   | el. outer radius ... numEl               |
  %   | el. inner radius ... numEl               |
  %   | el. density      ... numEl               |
  %   | el. Young's mod  ... numEl               |
  %   | el. reference to parent geometry element |
  elements
end


methods
  function obj = Mesh(mesh, varargin)

    obj.numEl = sum(mesh(4,:));

    obj.elements = zeros(6, obj.numEl);

    % Set length scale
    if nargin < 2
      obj.scale = 1;

    else
      switch varargin{1}
        case 'm'
          obj.scale = 1;
        case 'mm'
          obj.scale = 1e-3;
        otherwise
          if isnumeric(varargin{1})
            obj.scale = varargin{1};
          else
            error('Unknown scale parameter supplied')
          end
      end
    end

    obj.setGeometry(mesh);
  end

  function setGeometry(obj, mesh)
    % Set the geomtry of the shaft, i.e. length, outer radius, and inner
    % radius of each element.
    startIdx = 1;

    for i = 1:size(mesh, 2)

      reps = mesh(4, i);
      endIdx = startIdx+reps-1;

      elLength    = obj.scale*mesh(1,i)/mesh(4,i);
      elOutRadius = obj.scale*mesh(2,i);
      elInRadius  = obj.scale*mesh(3,i);

      obj.elements(1, startIdx:endIdx) = repelem(elLength,    reps);
      obj.elements(2, startIdx:endIdx) = repelem(elOutRadius, reps);
      obj.elements(3, startIdx:endIdx) = repelem(elInRadius,  reps);
      % obj.elements(4, startIdx:endIdx) is set in obj.setDensity
      % obj.elements(5, startIdx:endIdx) is set in obj.setEmod
      obj.elements(6, startIdx:endIdx) = i;

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
