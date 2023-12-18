## Finite Elements Module

### Minimal Working Examples (MWE)
#### Define FE model from discretization
```
% Rotordynamics example program
% Author: Svend E. Andersen (seran@mek.dtu.dk)

% Define shaft mesh and material
shaftDim = [500 250 250   % Length [mm]
             10  20  15   % Outer radius [mm]
              0   0   0   % Inner radius [mm]
              6   3   3]; % Partition num    ];

msh = Mesh(shaftDim, 'mm');
msh.setDensity(7800);
msh.setEmod(2.0e11);

rotMod = RotorFEModel(msh.elements);  % Initiate FE model
rotMod.addRayDamping(0, 5.3996e-05);  % Add proportional damping

% Define machine elements
bearing1 = Bearing([10e2   0
                      0  10e2])
% Mount the elements
rotMod.addNodeComponent( 1, bearing1, 'internal')
rotMod.addNodeComponent(13, bearing1, 'internal')
rotMod.addNodeComponent( 7, Disc(1, 0.5, 0.5, 30e-3, 60e-3))

rotMod.printInfo();

% Export rotor
rotorSystem = rotMod.export();

% rotSys =
%
%   struct with fields:
%
%       numDof: 52
%        comps: {[1x1 Bearing]  [1x1 Bearing]  [1x1 Disc]}
%            M: [52x52 double]
%            K: [52x52 double]
%            G: [52x52 double]
%            D: [52x52 double]
%        discs: {[1x1 Disc]}
%     bearings: {[1x1 Bearing]  [1x1 Bearing]}
```

#### Define FE-model from external matrices
```
% Define nodes of the model and where to find the M, G, K, and D matrices
nodes.bearA =  6;
nodes.bearB = 17;
nodes.wheel = 27;
ext = loadRotorMatrices('someDir');

rotMod = RotorFEModel(ext.M, ext.G, ext.K, ext.D);  % Initiate FE model
rotMod.addRayDamping(0.1, 1e-05);                   % Add proportional damping

wheel = IntDisc(2000*1e-6);

rotMod.addNodeComponent(nodes.bearA, MagnetBearing)
rotMod.addNodeComponent(nodes.bearB, MagnetBearing)
rotMod.addNodeComponent(nodes.wheel, wheel)

rotMod.printInfo();

% Export rotor and clean up
rotSys = rotMod.export(); delete(rotMod)

% rotSys =
%
%   struct with fields:
%
%       numDof: 116
%        comps: {[1x1 MagnetBearing]  [1x1 MagnetBearing]  [1x1 IntDisc]}
%            M: [116x116 double]
%            K: [116x116 double]
%            G: [116x116 double]
%            D: [116x116 double]
%        discs: {[1x1 IntDisc]}
%     bearings: {[1x1 MagnetBearing]  [1x1 MagnetBearing]}
```
