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

cmd = [exe, ' ', idate,' ',utsec,' ',...
       num2str([glat, glon, f107a, f107, f107p, Ap]),...
       ' -e ', int2str(Nbins), ' ',num2str([Ebins, Phitop])];
[status,dat] = system(cmd);
if status ~= 0, error(dat), end

iono = glowparse(dat);
end
