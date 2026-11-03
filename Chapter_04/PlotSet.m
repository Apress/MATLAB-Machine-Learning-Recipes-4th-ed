%% PLOTSET Create two-dimensional plots from a data set.
%% Form
%  h = PlotSet( x, y, varargin )
%
%% Decription
% Plot y vs x in one figure.
% If x has the same number of rows as y then each row of y is plotted
% against the corresponding row of x. If x has one row then all of the
% y vectors are plotted against those x variables. The plot title will be
% used as the figure title by default.
%
% Accepts optional arguments that modify the plot parameters. 'plot set'
% groups y rows together into plots via a cell array.
%
% Type PlotSet for a demo.
%
%% Inputs
%  x         (:,:)  Independent variables
%  y         (:,:)  Dependent variables
%  varargin   {}    Optional arguments with values
%                     'x label', 'y label', 'plot title', 'plot type'
%                     'plot set', 'figure title', 'legend'
%
%% Outputs
%  h         (1,1)  Figure handle

function h = PlotSet( x, y, varargin )

% Demo
if( nargin < 1 )
  Demo;
  return;
end
      
% Defaults
nCol      = 1;
n         = size(x,1); % number of independent variables
m         = size(y,1); % number of dependent variables
fontSize  = 12;

yLabel    = cell(1,m);
xLabel    = cell(1,n);
plotTitle = cell(1,n);
for k = 1:m
  yLabel{k} = 'y';
end
for k = 1:n
  xLabel{k}     = 'x';
  plotTitle{k}  = '';
end
figTitle = '';
plotType = 'plot';

plotSet = cell(1,m);
leg     = cell(1,m);
for k = 1:m
  plotSet{k} = k;
  leg{k} = {};
end

% Handle input parameters
for k = 1:2:length(varargin)
  switch lower(varargin{k} )
    case {'x label','xlabel'}
      xLabel = varargin{k+1};
    case {'y label','ylabel'}
      temp = varargin{k+1};
      if( ischar(temp) )
        yLabel{1} = temp;
      else
        yLabel    = temp;
      end
    case {'plot title','title'}
      if( iscell(varargin{k+1}) )
        plotTitle    = varargin{k+1};
      else
        plotTitle{1} = varargin{k+1};
      end
    case 'figure title'
      figTitle      = varargin{k+1};
    case 'plot type'
      plotType      = varargin{k+1};
    case 'plot set'
      plotSet       = varargin{k+1};
      m             = length(plotSet);
    case 'legend'
      leg           = varargin{k+1};
    otherwise
      fprintf(1,'%s is not an allowable parameter\n',varargin{k});
  end
end
if isempty(figTitle)
  if isscalar(plotTitle)
    figTitle = plotTitle{1};
  else
    figTitle = 'PlotSet';
  end
end

h = figure;
set(h,'Name',figTitle);
% First path is for just one row in x
if( n == 1 )
  for k = 1:m
    subplot(m,nCol,k);
    j = plotSet{k};
    for i = 1:length(j)
      plotXY(x,y(j(i),:),plotType);
      hold on
    end
    hold off
    ylabel(yLabel{k});
    if( isscalar(plotTitle) )
      if k==1
        title(plotTitle{1})
      end
    else
      title(plotTitle{k})      
    end
    if( ~isempty(leg{k}) )
      legend(leg{k},'fontsize',fontSize);
    end
    if( k < m )
      set(gca,'xticklabel',[]);
    end
    grid on
    set(gca,'fontsize',fontSize); % for book images
  end
  xlabel(xLabel);    
else
  for k = 1:n
    subplot(n,nCol,k);
    j = plotSet{k};
    for i = 1:length(j)
      plotXY(x(k,:),y(j(i),:),plotType);
      hold on
    end   
    hold off
    xlabel(xLabel{k});    
    ylabel(yLabel{k});
    if( isscalar(plotTitle) )
      if k==1
        title(plotTitle{1})
      end
    else
      title(plotTitle{k})      
    end
    if( ~isempty(leg{k}) )
      legend(leg{k},'location','best','fontsize',fontSize);
    end
    grid on
    set(gca,'fontsize',fontSize);
  end
end


%%% PlotSet>plotXY Implement different plot types
% log and semilog types are supported.
%
%   plotXY(x,y,type)
function plotXY(x,y,type)

switch type
  case 'plot'
    plot(x,y,'linewidth',1);
  case {'log' 'loglog' 'log log'}
    loglog(x,y,'linewidth',1);
  case {'xlog' 'semilogx' 'x log'}
    semilogx(x,y,'linewidth',1);
  case {'ylog' 'semilogy' 'y log'}
    semilogy(x,y,'linewidth',1);
  otherwise
    error('%s is not an available plot type',type);
end

%%% PlotSet>Demo
function Demo

x = linspace(1,1000);
y = [sin(0.01*x);cos(0.01*x);cos(0.03*x)];
disp('PlotSet: One x and three y rows')
PlotSet( x, y, 'figure title', 'PlotSet Demo',...
    'plot set',{[2 3], 1},'legend',{{'A' 'B'},{}},'plot title',{'cos','sin'});

disp('PlotSet: Two x and two y rows')
PlotSet( [x;y(1,:)], y(1:2,:) );

disp('PlotSet: Two x and two y rows using `plot set`')
PlotSet( [x;y(1,:)], y, 'plot set', {[1 2 3],2}, 'legend',...
  {{'sin','cos A',' cosB'},{'sin vs cos'}} );


%% Copyright
% Copyright (c) 2016, 2023 Princeton Satellite Systems, Inc.
% All rights reserved.

