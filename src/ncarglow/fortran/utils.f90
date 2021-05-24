module utils
! f2py -c utils.f90 -m futils
use, intrinsic :: iso_fortran_env, only: stderr=>error_unit

implicit none
!private
public :: alt_grid, linspace, cumsum

contains


subroutine argv(i, val)

integer, intent(in) :: i
class(*), intent(out) :: val
character(1024) :: buf
integer :: j, narg

narg = command_argument_count()
if(narg < i) then
  write(stderr,'(A,I0,A,I0)') "Only ",narg, " arguments given, but you requested argument # ", i
  error stop
endif

call get_command_argument(i, buf)

select type(val)
  type is (real)
    read(buf, *, iostat=j) val
  type is (integer)
    read(buf, *, iostat=j) val
  class default
    error stop 'unknown value type'
end select

if(j/=0) then
  write(stderr,*) 'argv: failed to read command line value #',i
  error stop
endif

end subroutine argv


pure real function alt_grid(Nalt, minalt, dmin, dmax)

! * Nalt: number of altitude points
! * altmin: minimum altitude [km]
! * dmin: minimum grid spacing at minimum altitude [km]
! * dmax: maximum grid spacing at maximum altitude [km]
!
! Example: alt = alt_grid(286, 90, 1.5, 11.1475)

real, intent(in) :: dmin, dmax, minalt
integer, intent(in) :: Nalt
real :: dz(Nalt)
dimension :: alt_grid(Nalt)

dz = ztanh(dmin, dmax, Nalt)

alt_grid = cumsum(dz) + minalt-dmin

end function alt_grid


pure real function ztanh(gridmin, gridmax, N)

real, intent(in) :: gridmin, gridmax
integer, intent(in) :: N
real :: x(N)
dimension :: ztanh(N)

x = linspace(0., 3.14, N)
!! arbitrarily picking 3.14 as where tanh gets to 99% of asymptote

ztanh = tanh(x) * gridmax + gridmin

end function ztanh


pure real function linspace(Vmin, Vmax, Nv)

real, intent(in) :: Vmin, Vmax
integer, intent(in) :: Nv
integer :: i
real :: step
dimension :: linspace(Nv)

step = (Vmax - Vmin) / Nv

linspace(1) = Vmin
do i = 2,Nv
  linspace(i) = linspace(i-1) + step
enddo

end function linspace


pure real function cumsum(A)

real, intent(in) :: A(:)
dimension :: cumsum(size(A))
integer :: i

 cumsum(1) = A(1)
 do i = 2,size(A)
   cumsum(i) = cumsum(i-1) + A(i)
 enddo

end function cumsum

end module utils
