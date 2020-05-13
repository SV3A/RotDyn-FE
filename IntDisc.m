classdef IntDisc < NodeElement
% The 'IntDisc' class defines a machine element disc with a unbalance it is
% only used for FE-model with imported system matrices.

properties
  u;            % combined unbalance [kg*m]
  hasUnbalance; % unbalance flag
end

methods
  function obj = IntDisc(u)
    obj.u = u;
    obj.hasUnbalance = true;
  end
end
end
