function Ebins = loggrid(Emin, Emax, N)
%% inputs
% * Emin: minimum energy bin center [eV]
% * Emax: maximum energy bin center [eV]
% * N: number of log-spaced energy bins
%% outputs
% * Ebins: energy bin centers [eV]
arguments
  Emin (1,1) {mustBeReal,mustBePositive}
  Emax (1,1) {mustBeReal,mustBePositive}
  N (1,1) {mustBePositive,mustBeInteger}
end

Ebins = logspace(log10(Emin), log10(Emax), N);

end
