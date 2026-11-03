function nS = NextStates(s)

%% Create all of the next stages
% The demos display the expected results and the actual results

if( nargin < 1 )
  Demo;
  return
end

sN = split(s,'|');
lF = extractBefore(sN,2);
lA = extractAfter(sN,1);

k  = 1;
for i = 1:length(lF)
  l  = strfind(s,lF(i));
  sK = erase(s,lF(i));
  lS = strfind(sK,'||');
  if( ~isempty(lS))
    sK = eraseBetween(sK,lS,lS);
  end
  lS = strfind(sK,'|');
  j  = find(lS==l-1);
  if( ~isempty(j))
    nS(k) = append(lF(i),sK);
    k = k + 1;
  end
  lS(j) = [];
  for j = 1:length(lS)
    nS(k) = insertAfter(sK,lS(j),lF(i));
    k     = k + 1;
  end

  % On the table case
  if( lA(i) ~= "" )
    nS(k) = append(sK,"|",lF(i));
    k     = k + 1;
  end
end

% Remove any last |
for k = 1:length(nS)
  if( nS{k}(end) == "|")
    nS{k} = nS{k}(1:end-1);
  end
  if( nS{k}(1) == "|")
    nS{k} = nS{k}(2:end);
  end

end

end

%% Demo
function Demo

s     = "ACB|DF|E";
nE(1) = "CB|ADF|E";
nE(2) = "CB|DF|AE";
nE(3) = "CB|DF|E|A";
nE(4) = "DACB|F|E";
nE(5) = "ACB|F|DE";
nE(6) = "ACB|F|E|D";
nE(7) = "EACB|DF";
nE(8) = "ACB|EDF";
disp(s);
disp(nE);
nS = NextStates(s);
disp(nS)

clear nE
s     = "AB|C";
nE(1) = "B|AC";
nE(2) = "B|C|A";
nE(3) = "CAB";
disp(s);
disp(nE);
nS = NextStates(s);
disp(nS)
clear nS

end