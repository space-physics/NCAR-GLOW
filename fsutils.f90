module fsutils

implicit none

contains


pure function dirname(instr,  delm)

character(*), intent(in) :: instr
character(*), intent(in) :: delm
character(:),allocatable :: dirname
integer :: idx

idx = scan(instr, delm, back=.true.)
dirname = instr(1:idx-1)

end function dirname

end module fsutils
