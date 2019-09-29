! Basic single-processor driver for the GLOW model.
! Uses MSIS/IRI for input.
! Runs GLOW for designated inputs once, or multiple times.
! MPI and netCDF libraries NOT required.

! Example: ./glow.bin 16355 0 80 0 70 70 70 4 1 2000


! Other definitions:
! f107p   Solar 10.7 cm flux for previous day
! ap      Ap index of geomagnetic activity
! z       altitude array, km

! Array dimensions:
! Nalt    number of altitude levels
! nbins   number of energetic electron energy bins
! lmax    number of wavelength intervals for solar flux
! nmaj    number of major species
! nst     number of states produced by photoionization/dissociation
! nei     number of states produced by electron impact
! nex     number of ionized/excited species
! nw      number of airglow emission wavelengths
! nc      number of component production terms for each emission

use, intrinsic :: iso_fortran_env, only: stdout=>output_unit, stdin=>input_unit, wp=>real32, stderr=>error_unit
use fsutils, only: dirname
use utils, only: alt_grid, argv

use cglow,only: Nalt=>jmax,nbins,nex, nw
use cglow,only: idate,utsec=>ut,glat,glong,f107a,f107,f107p,ap,ef,ec
use cglow,only: iscale,jlocal,kchem,xuvfac
use cglow,only: zz,zo,zn2,zo2,zns,znd,zno,ztn,ze,zti,zte
use cglow,only: ener,del,phitop
use cglow,only: tir,ecalc,zxden,zeta
use cglow,only: cglow_init
use cglow,only: data_dir, &
  production, loss

! aglw, dflx, dip, efrac,,pespec ,tei,tpi, uflx,wave1,wave2,zceta,zlbh, photoi,photod,phono
! sflux, sion, sza,sespec, lmax,nei,nc,nmaj,,nst,nw

implicit none

character(:), allocatable :: iri90_dir

character(1024) :: buf
character(80) :: operating_mode  ! what kind of user scenario

real(wp), allocatable :: z(:)                    ! glow height coordinate in km (Nalt)
real(wp), allocatable :: zun(:), zvn(:)          ! neutral wind components (not in use)
real(wp), allocatable :: pedcond(:), hallcond(:) ! Pederson and Hall conductivities in S/m (mho)
real(wp), allocatable :: outf(:,:)               ! iri output (11,Nalt)
real(wp) :: stl,fmono,emono
real(wp), parameter :: sw(25) = [1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.]
integer :: j,ii,itail

!> -nosource variables
real :: Thot, Talt
integer :: ialt


! Initialize standard switches:
iscale=1
xuvfac=3.
kchem=4
jlocal=0
itail=0
fmono=0.
emono=0.


!> Set data directories:
call get_command_argument(0, buf)
data_dir = dirname(buf, '/'//char(92)) // '/../data/'
iri90_dir = trim(data_dir) // 'iri90/'

!> Set number of altitude levels:
Nalt = 250

!> Allocate local arrays:
allocate(z(Nalt))
allocate(zun(Nalt))
allocate(zvn(Nalt))
allocate(pedcond(Nalt))
allocate(hallcond(Nalt))
allocate(outf(11,Nalt))

!! Get input values:
!! idate  Date in yyyyddd or yyddd format

! yyyyddd UTsec glat glon F107a F107 F107p Ap Ef Ec Nbins

call argv(1, idate)
call argv(2, utsec)
call argv(3, glat)
call argv(4, glong)
call argv(5, f107a)
call argv(6, f107)
call argv(7, f107p)
call argv(8, ap)

!> pick precipitation input
call get_command_argument(9, operating_mode)
select case (operating_mode)
case ('-e')
  !! monoenergetic precipitation differential number flux
  call argv(10, nbins)
  allocate(ener(nbins), del(nbins), phitop(nbins))

  block
    integer :: u, ios
    call get_command_argument(11, buf)
    open(newunit=u, file=buf, access='stream', action='read', status='old')

    !> array filling real32 reads
    read(u, iostat=ios) ener
    read(u, iostat=ios) phitop
    if(ios /= 0) then
      write(stderr,*) 'failed to read input energy bin file ',trim(buf),' code',ios
      if (ios < 0) error stop 'was file truncated?'
      error stop
    endif

    close(u)
  endblock

  del(2:) = ener(2:) - ener(1:nbins-1)
  del(1) = del(2) / 2  ! arbitrary
case('-noprecip', '-nosource')
  !! no precipitation
  call argv(10, nbins)
  allocate(ener(nbins), del(nbins), phitop(nbins))

  if(operating_mode == '-nosource') then
    !> what altitude to set temperature
    call argv(11, Talt)  !< altitude to set temperature
    call argv(12, Thot)  !< temperature to set
  endif

  !> setup energy grid
  call egrid(ener, del, nbins)
  phitop(:) = 0.
case default
  !! maxwellian precipitation differential number flux
  call argv(9, ef)  ! hemispherical flux

  call argv(10, ec) ! characteristic energy [eV]
  call argv(11, nbins) ! number of energy bins
  allocate(ener(nbins), del(nbins), phitop(nbins))

  !> setup energy grid
  call egrid(ener, del, nbins)

  !! Call MAXT to put auroral electron flux specified into phitop array:
  phitop(:) = 0.
  if (ef>.001 .and. ec>1.) call maxt (ef,ec,ener,del,nbins,itail,fmono,emono,phitop)
end select

!! Call CGLOW_INIT (module CGLOW) to set array dimensions and allocate use-associated variables:
call cglow_init

!! Calculate local solar time:
stl = utsec/3600. + glong/15.
stl = modulo(stl, 24.)

! Call MZGRID to use MSIS/NOEM/IRI inputs

!z =[80.,  81.,  82.,  83.,  84.,  85.,  86.,  87.,  88.,  89., &
!    90.,  91.,  92.,  93.,  94.,  95.,  96.,  97.,  98.,  99., &
!   100., 101., 102., 103., 104., 105., 106., 107., 108., 109., &
!   110.,111.5, 113.,114.5, 116., 118., 120., 122., 124., 126., &
!   128., 130., 132., 134., 137., 140., 144., 148., 153., 158., &
!   164., 170., 176., 183., 190., 197., 205., 213., 221., 229., &
!   237., 245., 254., 263., 272., 281., 290., 300., 310., 320., &
!   330., 340., 350., 360., 370., 380., 390., 400., 410., 420., &
!   430., 440., 450., 460., 470., 480., 490., 500., 510., 520., &
!   530., 540., 550., 560., 570., 580., 590., 600., 610., 620., &
!   630., 640. ]


z = alt_grid(Nalt=Nalt, minalt=60., dmin=0.5, dmax=4.)
!! Nalt: number of altitude bins
!! minalt: lowest altitude in grid [km]
!! dmin: grid spacing at minimum altitude [km]
!! dmax: grid spacing at maximum altitude [km]


call mzgrid (Nalt,nex,idate,utsec,glat,glong,stl,f107a,f107,f107p,ap,iri90_dir, &
             z,zo,zo2,zn2,zns,znd,zno,ztn,zun,zvn,ze,zti,zte,zxden)

if(operating_mode == '-nosource') then
!! testing only. Set Ti=Te=Thot at a single altitude
  ialt = minloc(abs(z-Talt), dim=1)
  zte(ialt) = Thot
  zti(ialt) = Thot
endif

!! Fill altitude array, converting to cm:
zz(:) = z(:) * 1.e5     !< km to cm at all Nalt levels

! Call GLOW to calculate ionized and excited species, airglow emission rates,
! and vertical column brightnesses:

call glow

!! Call CONDUCT to calculate Pederson and Hall conductivities:
do j=1,Nalt
  call conduct (glat, glong, z(j), zo(j), zo2(j), zn2(j), &
                zxden(3,j), zxden(6,j), zxden(7,j), ztn(j), zti(j), zte(j), &
                pedcond(j), hallcond(j))
enddo

!! Output

write(stdout,"(1x,i7,9f8.1)") idate,utsec,glat,glong,f107a,f107,f107p,ap,ef,ec
write(stdout,"('   Z     Tn       O        N2        O2        NO      Ne(in)    Ne(out)  Ionrate" //&
  "      O+       O2+      NO+       N(2D)    Pederson   Hall')")
write(stdout,"(1x,0p,f5.1,f6.0,1p,13e10.2)") (z(j),ztn(j),zo(j),zn2(j),zo2(j),zno(j),ze(j), &
  ecalc(j),tir(j),zxden(3,j),zxden(6,j),zxden(7,j),zxden(10,j),pedcond(j),hallcond(j),j=1,Nalt)

!> Optical emissions  (Rayleighs)
write(stdout,'(A)') "   Z      3371    4278    5200    5577    6300    7320   10400    " //&
  "3644    7774    8446    3726    LBH     1356    1493    1304"
write(stdout,"(1x,f5.1,15f8.2)") (z(j),(zeta(ii,j),ii=1,nw),j=1,Nalt)

!> production, loss
write(stdout, "(f5.1, 12f12.2)") (z(j),(production(ii,j), ii=1,nex), j=1,Nalt)

write(stdout, "(f5.1, 12f12.2)") (z(j),(loss(ii,j), ii=1,nex), j=1,Nalt)

!> energy bins
write(stdout, '(i4)') Nbins
write(stdout,'(1000f15.1)') ener
!> incident particle flux
write(stdout,'(1000f15.1)') phitop

!> excited / ionized densities
write(stdout,'(A)') ' alt.   O+(2P)   O+(2D)   O+(4S)   N+   N2+   O2+   NO+    N2(A)    N(2P)   N(2D)    O(1S)   O(1D)'
write(stdout, "(f5.1, 12f12.2)") (z(j), (zxden(ii,j), ii=1,nex), j=1,Nalt)

!> Te, Ti
write(stdout,'(A)') ' alt.    Te     Ti'
write(stdout, '(f5.1, 2f9.2)') (z(j), zte(j), zti(j), j=1,Nalt)


end program
