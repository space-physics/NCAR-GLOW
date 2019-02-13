%!assert(islogical(interactive))
function isinteractive = interactive()
persistent isinter;

if isempty(isinter)
  if isoctave
    isinter = isguirunning;
  else % matlab
    isinter = usejava('desktop');
  end
end

isinteractive = isinter;  % has to be distinct line/var for Matlab
end