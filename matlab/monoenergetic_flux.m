function flux = monoenergetic_flux(Ebins, E0)
%% Inputs
% * E0: monoenergetic bin (closest) [eV]
% * Ebins: energy bin centers [eV]
%% Outputs
% * flux: normalized particle flux by energy bin

validateattributes(Ebins, {'numeric'}, {'positive','vector'})
validateattributes(E0, {'numeric'}, {'positive','scalar'})

[~, i] = min(abs(Ebins-E0));

flux = zeros(size(Ebins));
flux(i) = 1.;

end
