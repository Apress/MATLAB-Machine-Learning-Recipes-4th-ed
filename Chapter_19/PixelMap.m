function p = PixelMap(hMap,h,xY,angle,nPix,wPix)

if( nargin < 1 )
  hMap  = rand(11,11); % An odd number
  h     = 100;
  xY    = 1;
  angle = 0.01;
  nPix  = 4;
  wPix  = 0.01;
  p = PixelMap(hMap,h,xY,angle,nPix,wPix)
  return
end

hMap
cMap = floor(size(hMap,1)/2) + 1;
wPix = h*tan(angle);
for j = 1:nPix
  for k = 1:nPix
  end
end
p    = zeros(nPix,nPix);


