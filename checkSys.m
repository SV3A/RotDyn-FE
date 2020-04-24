function checkSys(rs)
  % Makes various checks on the rotor-system object provided by the
  % 'RotorFEModel' class.

  fprintf('\nRunning system check...\n')

  % Check for symmetry
  figure('Name','Symmetry Check')
  subplot(2,3,1); spy(rs.M);        title('M matrix')
  subplot(2,3,2); spy(rs.K);        title('K matrix')
  subplot(2,3,3); spy(rs.G);        title('G matrix')
  subplot(2,3,4); spy(rs.M-rs.M.'); title('M-M^T')
  subplot(2,3,5); spy(rs.K-rs.K.'); title('K-K^T')

end
