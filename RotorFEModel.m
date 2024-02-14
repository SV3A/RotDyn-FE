classdef RotorFEModel < handle
% The 'RotorFEModel' class implements the finite element method on a rotor.
% In addition to the shaft, 'NodeElement's can be mounted onto the rotor, e.g.
% bearings or discs.  The resulting object is pass-by-reference.

properties
  numNoDof % Number of degrees of freedom pr element
  numEl;   % Number of elements
  numDof;  % Number of degress of freedom
  numNo;   % Number of nodes

  M;      % Global mass matrix
  G;      % Global gyroscopic matrix
  K;      % Global stiffness matrix
  D;      % Global damping matrix

  damped; % Damping flag (bool), default is false
  comps;  % Mounted components
end


methods
  function obj = RotorFEModel(varargin)
    % Constructor

    obj.damped = false;

    obj.numNoDof = 4;

    % Handle if mesh is supplied or external model
    if nargin < 2
      elements   = varargin{1};
      obj.numEl  = size(elements, 2);
      obj.numNo  = obj.numEl+1;
      obj.numDof = obj.numNo*4;

      % Set size of system matrices and state matrices
      obj.M = zeros(obj.numDof);
      obj.G = zeros(obj.numDof);
      obj.K = zeros(obj.numDof);
      obj.D = zeros(obj.numDof);

      obj.buildShaftMatrices(elements);

    else
      obj.M      = varargin{1};
      obj.G      = varargin{2};
      obj.K      = varargin{3};
      obj.numDof = size(obj.M, 1);
      obj.numNo  = obj.numDof/obj.numNoDof;
      obj.numEl  = obj.numNo-1;

      % Handle damping if supplied
      if nargin > 3 && sum(varargin{4}, 'all') > 0
        obj.D      = varargin{4};
        obj.damped = true;
      else
        obj.D = zeros(obj.numDof);
      end

    end

  end

  function buildShaftMatrices(obj, elements)
    % Builds the global matrices M, K, and G.

    % Start- and end indices
    a = 1;
    b = 8;

    momInertFact = pi/4.0;

    for e = 1:obj.numEl
      l    = elements(1, e);
      ro   = elements(2, e);
      ri   = elements(3, e);
      rho  = elements(4, e);
      eMod = elements(5, e);

      lsq       = l^2;
      transArea = pi*(ro^2 - ri^2);
      momInert  = momInertFact*(ro^4 - ri^4);

      % Mass matrices
      % Linear inertia matrix
      localMLin = [
          156    0      0       22*l    54     0      0      -13*l
          0      156   -22*l    0       0      54     13*l    0
          0     -22*l   4*lsq   0       0     -13*l  -3*lsq   0
          22*l   0      0       4*lsq   13*l   0      0      -3*lsq
          54     0      0       13*l    156    0      0      -22*l
          0      54    -13*l    0       0      156    22*l    0
          0      13*l  -3*lsq   0       0      22*l   4*lsq   0
         -13*l   0      0      -3*lsq  -22*l   0      0       4*lsq];

      localMLin = localMLin*((rho*transArea*l) / 420.0);


      % Angular inertia matrix
      localMRot = [
          36    0     0       3*l    -36    0     0       3*l
          0     36   -3*l     0       0    -36   -3*l     0
          0    -3*l   4*lsq   0       0     3*l  -lsq     0
          3*l   0     0       4*lsq  -3*l   0     0      -lsq
         -36    0     0      -3*l     36    0     0      -3*l
          0    -36    3*l     0       0     36    3*l     0
          0    -3*l  -lsq     0       0     3*l   4*lsq   0
          3*l   0     0      -lsq    -3*l   0     0       4*lsq];

      localMRot = localMRot*((rho*transArea*(ro^2 - ri^2)) / (120.0*l));

      % Add the inertia matrices
      localMLin = localMLin + localMRot;


      % Gyro matrix
      localG = [
          0    -36    3*l     0      0     36    3*l     0
          36    0     0       3*l   -36    0     0       3*l
         -3*l   0     0      -4*lsq  3*l   0     0       lsq
          0    -3*l   4*lsq   0      0     3*l  -lsq     0
          0     36   -3*l     0      0    -36   -3*l     0
         -36    0     0      -3*l    36    0     0      -3*l
         -3*l   0     0       lsq    3*l   0     0      -4*lsq
          0    -3*l  -lsq     0      0     3*l   4*lsq   0];

      localG = localG*(2.0*( rho*transArea*(ro^2 + ri^2) / (120.0*l) ));


      % Stiffness matrix
      localK = [
          12    0     0       6*l    -12    0     0       6*l
          0     12   -6*l     0       0    -12   -6*l     0
          0    -6*l   4*lsq   0       0     6*l   2*lsq   0
          6*l   0     0       4*lsq  -6*l   0     0       2*lsq
         -12    0     0      -6*l     12    0     0      -6*l
          0    -12    6*l     0       0     12    6*l     0
          0    -6*l   2*lsq   0       0     6*l   4*lsq   0
          6*l   0     0       2*lsq  -6*l   0     0       4*lsq];

      localK = localK*((eMod * momInert) / l^3);


      % Construct the global mass- and gyro matrix (of size numDof x numDof)
      %
      % Note (e-1)*4 is the local indexing, at each iteration it will start
      % with 1, 2, 3 ...
      for i = a:b
        for j = a:b
          obj.M(i, j) = obj.M(i,j) + localMLin(i - (e-1)*4, j - (e-1)*4);
          obj.G(i, j) = obj.G(i,j) +    localG(i - (e-1)*4, j - (e-1)*4);
          obj.K(i, j) = obj.K(i,j) +    localK(i - (e-1)*4, j - (e-1)*4);
        end
      end

      a = a+4;
      b = b+4;
    end
  end

  function addRayDamping(obj, alpha, beta)
    % Enables Rayleigh (proportional) damping
    obj.damped = true;

    obj.D = obj.D + alpha*obj.M + beta*obj.K;
  end

  function addNodeComponent(obj, node, component, varargin)
    % Method for adding external components to the rotor

    % Check bounds
    if node > obj.numEl+1
      warning('Nodal number out of bounds, ignoring component.')
      return;
    end

    % Check type of component to be added, and add accordingly

    % Element start index
    es = (node-1)*4;

    if isa(component, 'Disc')
      obj.M(es+1, es+1) = obj.M(es+1, es+1) + component.m;
      obj.M(es+2, es+2) = obj.M(es+2, es+2) + component.m;
      obj.M(es+3, es+3) = obj.M(es+3, es+3) + component.iD;
      obj.M(es+4, es+4) = obj.M(es+4, es+4) + component.iD;

      obj.G(es+3, es+4) = obj.G(es+3, es+4) - component.iP;
      obj.G(es+4, es+3) = obj.G(es+4, es+3) + component.iP;

    elseif isa(component, 'Bearing')

      if nargin == 3 || (nargin > 3 && strcmp(varargin{1}, 'internal'))
        % Handle 2x2 or 4x4 stiffness matrix
        if size(component.localK, 2) == 2
          obj.K(es+1:es+2, es+1:es+2) = ...
            obj.K(es+1:es+2, es+1:es+2) + component.localK;
        else
          obj.K(es+1:es+4, es+1:es+4) = ...
            obj.K(es+1:es+4, es+1:es+4) + component.localK;
        end
      end
    elseif isa(component, 'Damper')
      obj.damped = true;
      obj.D(es+1, es+1) = obj.D(es+1, es+1) + component.d;
      obj.D(es+2, es+2) = obj.D(es+2, es+2) + component.d;
    end

    % Add component to internal component list (used for info and debug)
    component.nodalPosition = node;

    % Append component to internal list
    obj.comps{length(obj.comps)+1} = component;
  end

  function rotorSystem = export(obj)
    % Exports the rotor system in terms of the system matrices.

    rotorSystem.numDof = obj.numDof;
    rotorSystem.comps  = obj.comps;
    rotorSystem.nodeDof = obj.numNoDof;

    rotorSystem.M = obj.M;
    rotorSystem.K = obj.K;
    rotorSystem.G = obj.G;
    if obj.damped
      rotorSystem.D = obj.D;
    end

    % Collect discs and bearings for easy referencing
    discs    = {};
    bearings = {};
    for i = 1:length(obj.comps)
      if isa(obj.comps{i}, 'Disc') || isa(obj.comps{i}, 'IntDisc')
        discs{length(discs)+1} = obj.comps{i};
      elseif isa(obj.comps{i}, 'Bearing') || isa(obj.comps{i}, 'MagnetBearing')
        bearings{length(bearings)+1} = obj.comps{i};
      end
    end

    rotorSystem.discs    = discs;
    rotorSystem.bearings = bearings;
  end

  function printInfo(obj)
    % Prints some information concerning the FE model.

    if obj.damped
      dampedAns = 'yes';
    else
      dampedAns = 'no';
    end

    fprintf('\nFE-model info:\n  Number of elements: %d\n', obj.numEl);
    fprintf('  Number of DOFs: %d\n', obj.numDof);
    fprintf('  Internally damped: %s\n', dampedAns);
    fprintf('  Nodal components added: %d\n', length(obj.comps));
    for i = 1:length(obj.comps)
      fprintf('    - %s at node %d\n', class(obj.comps{i}), ...
              obj.comps{i}.nodalPosition);
    end
    fprintf('\n');
  end

end
end
