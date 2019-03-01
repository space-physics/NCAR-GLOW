function iono = glowenergy(time, glat, glon, f107a, f107, f107p, Ap, Ebins, Phitop)

validateattributes(glat, {'numeric'}, {'scalar'})
validateattributes(glon, {'numeric'}, {'scalar'})
validateattributes(f107, {'numeric'}, {'positive', 'scalar'})
validateattributes(f107a, {'numeric'}, {'positive', 'scalar'})
validateattributes(f107p, {'numeric'}, {'positive', 'scalar'})
validateattributes(Ap, {'numeric'}, {'positive', 'scalar'})
validateattributes(Ebins, {'numeric'}, {'positive', 'vector'})
validateattributes(Phitop, {'numeric'}, {'nonnegative', 'vector'})

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
if status ~= 0, error(dat), end

iono = glowparse(dat);
end
