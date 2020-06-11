classdef Damper < NodeElement
% The 'Damper' class defines a machine element with linear damping proportional
% to velocity.

properties
  d; % Damping coefficient [Ns/m]
end

methods
  function obj = Damper(d)
    obj.d = d;
  end
end
end
