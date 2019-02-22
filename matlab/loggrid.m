function Ebins = loggrid(Emin, Emax, N)
%% inputs
% * Emin: minimum energy bin center [eV]
% * Emax: maximum energy bin center [eV]
% * N: number of log-spaced energy bins
%% outputs
% * Ebins: energy bin centers [eV]

validateattributes(Emin, {'numeric'}, {'positive','scalar'})
validateattributes(Emax, {'numeric'}, {'positive','scalar'})
validateattributes(N, {'numeric'}, {'positive','scalar','integer'})

Ebins = logspace(log10(Emin), log10(Emax), N);

end