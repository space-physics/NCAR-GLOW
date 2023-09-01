module fsutils

implicit none

contains

function expanduser(indir)

character(:), allocatable :: expanduser
character(*), intent(in) :: indir

! -- resolve home directory as Fortran does not understand tilde
! works for Linux, Mac, Windows and more

if (len_trim(indir) < 1) error stop 'must provide path to expand'

if (indir(1:1) /= '~') then
  expanduser = trim(adjustl(indir))
elseif (len_trim(indir) < 3) then
  expanduser = homedir() // "/"
else
  expanduser = homedir() // "/" // trim(adjustl(indir(3:)))
endif

end function expanduser


function homedir()

character(:), allocatable :: homedir
character(256) :: buf
integer :: i

! assume MacOS/Linux/BSD/Cygwin/WSL
call get_environment_variable("HOME", buf, status=i)

if (i /= 0) then  ! Windows
  call get_environment_variable("USERPROFILE", buf, status=i)
endif

if (i/=0) error stop 'could not determine home directory'

homedir = trim(buf)

end function homedir


pure function dirname(instr,  delm)

character(*), intent(in) :: instr
character(*), intent(in) :: delm
character(:),allocatable :: dirname
integer :: idx

idx = scan(instr, delm, back=.true.)
dirname = instr(1:idx-1)

end function dirname

end module fsutils
