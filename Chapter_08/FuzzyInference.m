%% FUZZYINFERENCE Fuzzy Inference engine
% Performs fuzzy inference given a fuzzy system and crisp data x. The crisp
% inputs x are each given a membership value across the fuzzy categories.
% For example, if there are values 'low','med','high', and the input is
% 4.5, it may have membership values [0.1 0.85 0.05]. This is done in Fuzzify(). The
% rules are applied in Fire() and the fuzzy output set membership is the
% converted back into a crisp value in Defuzzify().
%
%% Form:
%  y = FuzzyInference( x, system )
%
%% Inputs
%  x       (1,n)   crisp input vector
%  system   (.)    fuzzy system
%                   .input     (n) Input struct array
%                   .output    (m) Output struct array
%                   .rules     (p) Rules struct array
%                   .implicate  @  Function handle
%                   .aggregate  @  Function handle
%                   .defuzzify  @  Function handle
%
%% Outputs
%  y       (1,m)   Crisp output vector
%  data     (.)    Additional data on the fuzzy inference
%
%% See also:
% FuzzyInference>Fuzzify, FuzzyInference>Fire, FuzzyInference>Defuzzify

function [y,data] = FuzzyInference( x, system, verbosity )

persistent verbose

if nargin<3
  verbose = false;
else
  verbose = verbosity;
end

if length(x) == length( system.input )
  fuzzyX     = Fuzzify( x, system.input );
  strength   = Fire( fuzzyX, system.rules );
  y          = Defuzzify( strength, system, x );
else
  warndlg({'The length of x must be equal to the',...
    'number of input sets in the system.'})
end

if (nargout>1)
  data.x = x;
  data.fuzzyX = fuzzyX;
  data.strength = strength;
  data.fuzzyY = Fuzzify( y, system.output );
  data.y = y;
end

  function fuzzyX = Fuzzify( x, sets )
    %% Fuzzify the inputs with the type function
    % fuzzyX = Fuzzify( x, sets )
    %
    % x      (n)  crisp input, length must match number of input sets
    % sets   (n)  system.input struct array
    %
    % fuzzyX {n}  each cell has the membership array for each set

    n = length(sets);
    fuzzyX = cell(1,n);
    for i = 1:n
      nC = length(sets(i).comp);
      range = sets(i).range(:);
      if (range(1) <= x(i)) && (x(i) <= range(2))
        for j = 1:nC
          fuzzyX{i}(j) = feval(sets(i).type{j},x(i),sets(i).params{j});
        end
      else
        fuzzyX{i}(1:nC) = zeros(1,nC);
      end
    end

  end

  function strength = Fire( FuzzyX, rules )
    %% Fire a rule using the specified rules.operator function
    % strength = Fire( FuzzyX, rules )
    %
    % FuzzyX   {n}  cell array of fuzzy membership values
    % rules    (p)  system.rules struct array
    %
    % strength (p)  strength of each rules

    p = length( rules );
    n = length( FuzzyX );

    strength = zeros(1,p);

    for i = 1:p
      method = rules(i).operator;
      dom = zeros(1,n);
      for j = 1:n
        comp = rules(i).input(j);
        if comp ~= 0
          dom(j) = FuzzyX{j}(comp);
        else
          dom(j) = inf;
        end
      end
      strength(i) = feval(method,dom(dom<=1));
    end

  end

  function [result,aggregate] = Defuzzify( strength, system, xIn )
    %% Defuzzify the rule output
    % result = Defuzzify( strength, system )
    %
    % strength (p)  Array of rule strength
    % system   (.)  System struct
    %
    % result   (m)

    rules   = system.rules;
    output  = system.output;

    m       = length( output );
    p       = length( rules );
    impfun  = system.implicate;
    aggfun  = system.aggregate;
    defuzz  = system.defuzzify;

    nPts    = 200;
    result  = zeros(1,m);

    if verbose
      figure('name','Fuzzy Inference')
      subplot(m,1,1); hold on;
      xstr = num2str(xIn);
      title(sprintf('Fuzzy output for [%s]',xstr))
    end

    for i = 1:m
      if verbose
        subplot(m,1,i); hold on; grid on;
      end
      range = output(i).range(:);
      xO = linspace( range(1),range(2),nPts );
      mem = zeros(p,nPts);
      % precompute membership for the output set
      ls = [];
      label = {};
      nC = length(output(i).type);
      ymf = zeros(nC,nPts);
      for k = 1:nC
        mfun   = output(i).type{k};
        params = output(i).params{k};
        ymf(k,:) = feval(mfun,xO,params);
        if verbose
          plot(xO,ymf(k,:),'-.','linewidth',1);
        end
      end
      % compute the membership for each fired rule
      for j = 1:p
        comp = rules(j).output(i);
        if( comp ~= 0 ) && strength(j)>0
          mem(j,:)  = feval(impfun, ymf(comp,:),strength(j));
          if verbose
            ls(end+1) = plot(xO,mem(j,:),'linewidth',1);
            label{end+1} = [num2str(j) ' (' num2str(strength(j),3) ')'];
          end
        else
          mem(j,:)  = zeros(size(xO));
        end
      end % rules
      aggregate = feval(aggfun,mem);
      result(i) = feval(defuzz,aggregate,xO);
      if verbose
        plot(xO,aggregate,'k--','linewidth',2);
        yy = axis;
        plot(result(i)*[1 1],yy(3:4),'r','linewidth',3)
        text(result(i),yy(3) + 0.75*(yy(4)-yy(3)),sprintf('  %g',result(i)))
        xlabel(output(i).name)
        if i == 1
          ll = legend(ls,label,'location','best');
          ll.Title.String = 'Rules';
        end
      end
    end % outputs

  end

end
