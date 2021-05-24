function iono = glow(time, glat, glon, f107a, f107, f107p, Ap, Q, Echar, Nbins)
arguments
  time (1,1) datetime
  glat (1,1) double {mustBeReal}
  glon (1,1) double {mustBeReal}
  f107a (1,1) double {mustBeReal,mustBePositive}
  f107 (1,1) double {mustBeReal,mustBePositive}
  f107p (1,1) double {mustBeReal,mustBePositive}
  Ap (1,1) double {mustBeReal,mustBePositive}
  Q (1,1) double {mustBeReal,mustBeNonnegative}
  Echar (1,1) double {mustBeReal,mustBePositive}
  Nbins (1,1) {mustBeInteger,mustBePositive}
end

%% binary
exe = exepath('glow.bin');
[idate, utsec] = dt2utsec(time);

cmd = exe + " " + idate + " " + utsec + " " + ...
       num2str([glat, glon, f107a, f107, f107p, Ap, Q, Echar, Nbins]);
disp(cmd)
[status,dat] = system(cmd);
assert(status == 0, dat)

iono = glowparse(dat);
end
