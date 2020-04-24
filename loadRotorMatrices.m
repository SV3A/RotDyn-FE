function rotorSystem = loadRotorMatrices(directory)

  rotorSystem.M = importdata(fullfile(directory, 'M.txt'));
  rotorSystem.G = importdata(fullfile(directory, 'G.txt'));
  rotorSystem.K = importdata(fullfile(directory, 'K.txt'));
  rotorSystem.D = importdata(fullfile(directory, 'C.txt'));

  rotorSystem.numDof = size(rotorSystem.M, 1);
end
