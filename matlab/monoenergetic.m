function [Ebins, flux] = monoenergetic(Emin, Emax, N, E0)
%% Inputs
% * Emin: minimum energy bin center [eV]
% * Emax: maximum energy bin center [eV]
% * N: number of log-spaced energy bins
% * E0: monoenergetic bin (closest) [eV]
%% Outputs
% * Ebins: energy bin centers [eV]
% * flux: particle flux

validateattributes(Emin, {'numeric'}, {'positive','scalar'})
validateattributes(Emax, {'numeric'}, {'positive','scalar'})
validateattributes(N, {'numeric'}, {'positive','scalar','integer'})
validateattributes(E0, {'numeric'}, {'positive','scalar'})

Ebins = logspace(log10(Emin), log10(Emax), N);

[~, i] = min(abs(Ebins-E0));

flux = zeros(size(Ebins));
flux(i) = 1.;

end
