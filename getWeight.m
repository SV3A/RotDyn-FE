function m = getWeight(elements)
  % elements:
  %   5xnumEl matrix containing each element and associated material props:
  %   | el. length       ... numEl |
  %   | el. outer radius ... numEl |
  %   | el. inner radius ... numEl |
  %   | el. density      ... numEl |
  %   | el. Young's mod  ... numEl |

  m = 0;

  for i = 1:size(elements, 2)
    el = elements(:,i);
    V = pi*(el(2)^2 - el(3)^2)*el(1);
    m = m + V*el(4);
  end
end
