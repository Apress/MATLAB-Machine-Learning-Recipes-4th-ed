%% LOADOBJFILE Load a 3D file in obj format.
%% Form:
%   LoadOBJFile    
%   g = LoadOBJFile( file, kScale )
%
%% Description
% LoadOBJFile will open myFile.obj. If you want to scale the units of the
% model, for example from vertex units to inches, you can define the
% factor using kScale.
%
% If you call the function with no outputs it will draw the model. 
%% Inputs
%
%   file    (1,:) Filename
%   kScale  (1,1) Optional scale factor of the model
%
%% Outputs
%   g       (1,1) Data structure
%                 .name       (1,:)  Model name
%                 .component  (:)    Component structure
%                 .radius     (1,1)  Maximum radius of the object
%

function g = LoadOBJFile( file, kScale )

% Input processing
if nargin == 0
  % Demo
  file = 'X15.obj';
  LoadOBJFile( file );
  return
end

% Read in the file
g = GetDataOBJ( file );

% Convert to triangles
g = Tesselate( g );

if( isempty( g ) )
  return;
end

if( nargin < 2 )
  kScale = 1;
end

g.radius = 0;
if( isfield( g, 'component' ) )
  for k = 1:length(g.component)
    g.component(k).v = g.component(k).v*kScale;
    g.radius         = max([Mag(g.component(k).v') g.radius]);
  end
  
  if( nargout == 0 )
    DrawPicture( g );
  end
end

%% Magnitude 
function m = Mag( u )

m = sqrt(sum(u.^2));

%% Draw the picture
function DrawPicture( g )

NewFigure( g.name )
axes('DataAspectRatio',[1 1 1],'PlotBoxAspectRatio',[1 1 1] );

for k = 1:length(g.component)
  DrawMesh( g.component(k) );
end

xlabel('X')
ylabel('Y')
zlabel('Z')

grid on
view(3)
rotate3d on
hold off

%% Get the polygon data
function g = GetDataOBJ( file )

% Initialize counters
kV      = 0;
kF      = 0;
nG      = 0;
hasG    = false;
g.name  = file;
lines   = readlines(file);
n       = size(lines);

% Read the file
for j = 1:n
  t = split(lines(j));
  
  if( ~isempty(t{1}) )
    
    % The first token determines the action
    switch t{1}
      case '#'
        % A Comment
        
      case 'v'
        kV      = kV + 1;
        v(kV,:) = [str2double(t{2}) str2double(t{3}) str2double(t{4}) ];
        
      case 'vn'
        % Normals not used
        
      case 'vt'
        % Texture map coordinates not used
        
      case 'f'
        if( ~hasG )
          kG        = 1;
          group{1}  = 'Default';
          nG        = 1;
        end
        if( isempty(t{end}))
          t = t(1:end-1);
        end

        lT        = length(t) - 1;
        vT        = zeros(1,lT);
        for k = 1:lT
          if( ~isempty(t{k+1}) )
            gVO = GetVertexOBJ(t{k+1});
            
            if( ~isempty(gVO) )
              vT(k) = gVO;
            end
          end
        end
        
        % Assign the faces to all groups
        for k = 1:length(kG)
          i     = kG(k);
          kF(i) = kF(i) + 1;
          component(i).f(kF(i),1:lT) = vT;
        end

      case 'g'
        hasG = true;
        n = length(t) - 1;
        if( n > 0 && ~isempty( t{2} ) )
          kG = [];
          for k = 1:n
            isANewGroup = 1;
            if( nG > 0 )
              for i = 1:nG
                if( strcmp( group{i}, t{k+1} ) )
                  isANewGroup = 0;
                  break;
                end
              end
              if( isANewGroup )
                nG        = nG + 1;
                kF(nG)    = 0;
                group{nG} = t{k+1};
                i         = nG;
              end
              kG = [kG i];
            else
              nG       = 1;
              kG       = 1;
              group{1} = t{2};
            end
          end
        end
        
      case 'l'
        fprintf(1,'%s: Line ''%s'' Lines not implemented\n',mfilename,t{1});

      case 'usemtl'
      case 'mtllib'
      case 's'
      case 'o'
        
        % Unknown command
      otherwise
        disp(line)
        fprintf(1,'%s: Line ''%s'' is not recognized\n',mfilename,t{1});
    end
  end
end

% Sort into groups
kG = 0;
for k = 1:nG
  [n,m] = size( component(k).f );
  fC    = sort(reshape( component(k).f, n*m, 1 ));
  
  % Delete duplicates
  fC(fC == 0) = [];
  kDelete = [];
  for j = 2:length(fC)
    if( fC(j) == fC(j-1) )
      kDelete = [kDelete j];
    end
  end
  
  fC(kDelete) = [];
  if( ~isempty(fC) )
    kG                  = kG + 1;
    g.component(kG)     = CreateComponent;
    g.component(kG).nV  = [];
    g.component(kG).f   = component(kG).f;
    g.component(kG).v   = v(fC,:);
    [rF,cF]             = size( g.component(kG).f );
    
    for i = 1:rF
      for j = 1:cF
        if( g.component(kG).f(i,j) == 0 )
          break;
        else
          p = find( fC == g.component(kG).f(i,j) ); % Reindexing
          g.component(kG).f(i,j) = p;
        end
      end
      nM = find(g.component(kG).f(i,:) == 0);
      if( isempty(nM) )
        nM = length( g.component(kG).f(i,:) );
      else
        nM = min(nM) - 1;
      end
      g.component(kG).nV(i) = nM; % The number of vertices per face
    end
    
    g.component(kG).name  = group{k};
    g.component(kG).color	= [0.6 0.6 0.6];
  end
end

%% LoadOBJ>CreateComponent
function c = CreateComponent

c.v     = [];
c.f     = [];
c.nV    = 0;
c.name	= '';
c.color	= [0.6 0.6 0.6];


%% Get the vertex from the face vertex list
function v = GetVertexOBJ( t )

k = strfind(char(t),'/');

if( isempty(k) )
  v = str2num(t); %#ok<ST2NM>
else
  k = k(1);
  v = str2num(t(1:(k-1))); %#ok<ST2NM>
end

%% Draw a mesh
function h = DrawMesh( m )

kMax = max(m.nV);
kMin = min(m.nV);
i    = 1;
for k = kMin:kMax
  j = find( m.nV == k );
  if( ~isempty(j) )
    h(i) = patch( 'Vertices', m.v, 'Faces',   m.f(j,1:k),...
      'facecolor',[0.7 0.7 0.7],...
      'EdgeLighting', 'phong',...
      'FaceLighting', 'phong');
    i = i + 1;
  end
end

%% Tesselate 4 corner polygons
function g = Tesselate( g )

for k = 1:length(g.component)
  
  nD = size( g.component(k).f, 2 );
  
  % Tesselate if necessary
  if( nD == 4 )
    f = g.component(k).f;
    
    % Tesselate
    i = 1;
    while i <= size(f,1)
      if f(i,4) ~= 0
        % Tesselate into 2 triangles: 1/2/4 and 2/3/4
        fv = f(i,:);
        f(i,:) = [fv(1) fv(2) fv(4) 0];
        f = [f(1:i,:); [fv(2) fv(3) fv(4) 0]; f(i+1:end,:)];
        i = i+2;
      else
        i = i+1;
      end
    end
    f(:,4) = [];
    g.component(k).f = f;
    g.component(k).nV = 3*ones(size(f,1),1);
  end
end


%% Copyright
% Copyright (c) 2023 Princeton Satellite Systems, Inc.
% All rights reserved.
