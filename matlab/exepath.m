function exe = exepath(exename)

validateattributes(exename, {'char'}, {'vector'})
if ispc, exename = [exename,'.exe']; end

cwd = fileparts(mfilename('fullpath'));
exe = [cwd,filesep,'..', filesep, 'build', filesep, exename];

if exist(exe,'file')~=2
 setup()
end

end
