function iono = glowenergy(time, glat, glon, f107a, f107, f107p, Ap, Ebins, Phitop)
arguments
  time (1,1) datetime
  glat (1,1) double {mustBeReal}
  glon (1,1) double {mustBeReal}
  f107a (1,1) double {mustBeReal,mustBePositive}
  f107 (1,1) double {mustBeReal,mustBePositive}
  f107p (1,1) double {mustBeReal,mustBePositive}
  Ap (1,1) double {mustBeReal,mustBePositive}
  Ebins (1,:) double {mustBeReal,mustBeNonnegative}
  Phitop (1,:) {mustBeReal,mustBeNonnegative}
end

Nbins = length(Ebins);
assert(Nbins == length(Phitop), 'Phitop and Ebins must be same length')
%% binary
exe = glowpath();
[idate, utsec] = glowdate(time);

%% workaround Windows
% 8192 cmd line limit AND lack of stdin
% by using binary input files to pass data
Efn = tempname;
fid = fopen(Efn,'w');
fwrite(fid, Ebins, 'float32');
fwrite(fid, Phitop, 'float32');
fclose(fid);

cmd = [exe, ' ', idate,' ',utsec,' ',...
       num2str([glat, glon, f107a, f107, f107p, Ap]),...
       ' -e ', int2str(Nbins), ' ', Efn];

if ispc && length(cmd) > 8000
  warning('Windows has an 8k character limit on the command line')
end

[status,dat] = system(cmd);
assert(status == 0, dat)

iono = glowparse(dat);
end
