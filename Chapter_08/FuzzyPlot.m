%% FUZZYPLOT  Plots a fuzzy set over its specified range
%% Form:
%  FuzzyPlot( set )
%% Inputs
%  set     A struct containing all info on the categories for the fuzzification
%            .name
%            .comp   {m}
%            .type   {m}
%            .params {m}
%            .range  (2)
%
% Note: The comp, type, and params fields should be cell arrays. comp are strings
%       and type are membership function handles.
%       The params fields is a cell array of parameter vectors
%
%% Outputs
%  None
%% 

function FuzzyPlot( fzSet )

if (nargin==0)
  fzSet.name = 'Example of Triangle Membership Function';
  fzSet.comp = {''};
  fzSet.type = {@TriangleMF};
  fzSet.params = {[2 5]};
  fzSet.range = [0 10];
  FuzzyPlot(fzSet);
  return;
end

NewFigure(fzSet.name);
fS = 13; % enlarge for book images

n = length(fzSet.comp);
x = linspace(fzSet.range(1), fzSet.range(2), 200);
y = zeros(n,length(x));

labels = cell(1,n);
for i = 1:n
  mf = fzSet.type{i};
  y(i,:) = feval(mf,x,fzSet.params{i});
  temp = find(y(i,:) == max(y(i,:)));
  v(i) = sum(x(temp))/length(temp);
  labels{i} = func2str(mf);
end

plot(x,y,'linewidth',1)
axis([x(1) x(end) 0 1.2])
grid on
set(gca,'fontsize',fS)

for i = 1:n  
  if ~isempty(fzSet.comp)
    text(v(i),1.05,fzSet.comp(i),'fontsize',fS)
  end
end

title(sprintf('%s',fzSet.name))
ylabel('Degree of Membership')
xlabel('Crisp Value')
legend(labels,'location','southwest','fontsize',fS)
