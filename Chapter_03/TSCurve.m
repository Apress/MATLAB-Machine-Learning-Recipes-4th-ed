%% TSCURVE generate the TS curve for water and steam
%% Form:
%   [s,t] = TSCurve(t)
%
%% Description
% Reads in a steam table and generates a TS curve
% Requires that Steam_Tables_Temperature.xlsx be in the search path.
%
% Type TSCurve for a demo.
%
% If t is entered s will be [sL;sV] corresponding to t
% sL is the liquid phase, and sV is the vapor phase
%
%% Inputs
%   t      (1,:) Temperature (K)
%
%% Outputs
%   s      (1 or 2,:) Entropy (kJ/kg K)
%   t      (1,:)      Temperature (K)

function [s,t] = TSCurve( t )

% Read the steam table
tableT = readtable('Steam_Tables_Temperature.xlsx','range','A1:M384');

% Convert to double
sL = CellToCol(tableT.Var11)';
sV = CellToCol(tableT.Var12)';

% The first path generates the full diagram
if( nargin < 1 )
  t =  tableT.Var1';
  t  = [t fliplr(t)];
  s  = [sL fliplr(sV)];
else
  s = zeros(2,length(t));
  x = tableT.Var1';
  [~,j] = unique(x);

  for k = 1:length(t)
   s(1,k) = interp1(x(j),sL(j),t(k));
   s(2,k) = interp1(x(j),sV(j),t(k));
  end
end

% Default plot
if( nargout < 1 )
  PlotSet(s,t,'x label','Entropy (KJ/kg K)', 'y label', ...
    {'Temperature (K)'},'figure title','T-S');
  [tMax,k] = max(t);
  p = tableT.Var2';
  sMax  = s(k);
  pMax  = str2double(p(end));
  text(sMax,1.02*tMax,sprintf('Critical Point: %4.1f MPa %4.1f K',pMax,tMax));
  clear s
end

%% Convert cell to column
function c = CellToCol(cA)

c = zeros(length(cA),1);
for k = 1:length(cA)
  c(k) = str2double(cA{k});
end


%% Copyright
% Copyright (c) 2023 Princeton Satellite Systems, Inc.
% All rights reserved.
