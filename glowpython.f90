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
! jmax    number of altitude levels
! nbins   number of energetic electron energy bins
! lmax    number of wavelength intervals for solar flux
! nmaj    number of major species
! nst     number of states produced by photoionization/dissociation
! nei     number of states produced by electron impact
! nex     number of ionized/excited species
! nw      number of airglow emission wavelengths
! nc      number of component production terms for each emission

use, intrinsic :: iso_fortran_env, only: stdout=>output_unit

use cglow,only: jmax,nbins,nex
use cglow,only: idate,utsec=>ut,glat,glong,f107a,f107,f107p,ap,ef,ec
use cglow,only: iscale,jlocal,kchem,xuvfac
use cglow,only: zz,zo,zn2,zo2,zns,znd,zno,ztn,ze,zti,zte
use cglow,only: ener,del,phitop
use cglow,only: tir,ecalc,zxden,zeta
use cglow,only: cglow_init
use cglow,only: data_dir
! aglw, dflx, dip, efrac,,pespec ,tei,tpi, uflx,wave1,wave2,zceta,zlbh, photoi,photod,phono
! sflux, sion, sza,sespec, lmax,nei,nc,nmaj,,nst,nw

implicit none

character(:), allocatable :: iri90_dir

character(1024) :: buf

real,allocatable :: z(:)                    ! glow height coordinate in km (jmax)
real,allocatable :: zun(:), zvn(:)          ! neutral wind components (not in use)
real,allocatable :: pedcond(:), hallcond(:) ! Pederson and Hall conductivities in S/m (mho)
real,allocatable :: outf(:,:)               ! iri output (11,jmax)
real :: stl,fmono,emono
real :: sw(25)
integer :: j,ii,itail

data sw/25*1./

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
iri90_dir = data_dir // 'iri90/'

!> Set number of altitude levels:
jmax = 102

!> Allocate local arrays:
allocate(z(jmax))
allocate(zun(jmax))
allocate(zvn(jmax))
allocate(pedcond(jmax))
allocate(hallcond(jmax))
allocate(outf(11,jmax))
!
! Call CGLOW_INIT (module CGLOW) to set array dimensions and allocate use-associated variables:
! (This was formerly done using common blocks, including common block /cglow/.)
!
call cglow_init
!
! Call EGRID to set up electron energy grid:
!
call egrid (ener, del, nbins)


! Get input values:
! date, UTsec, lat, lon, F107a, F107, F107p, Ap, Ef, Ec
! idate  Date in yyyyddd or yyddd format

if (command_argument_count() /= 10) error stop "yyyyddd UTsec glat glon F107a F107 F107p Ap Ef Ec"

call get_command_argument(1, buf)
read(buf, *) idate

call get_command_argument(2, buf)
read(buf, *) utsec

call get_command_argument(3, buf)
read(buf, *) glat

call get_command_argument(4, buf)
read(buf, *) glong

call get_command_argument(5, buf)
read(buf, *) f107a

call get_command_argument(6, buf)
read(buf, *) f107

call get_command_argument(7, buf)
read(buf, *) f107p

call get_command_argument(8, buf)
read(buf, *) ap

call get_command_argument(9, buf)
read(buf, *) ef

call get_command_argument(10, buf)
read(buf, *) ec

! Calculate local solar time:

stl = utsec/3600. + glong/15.
stl = modulo(stl, 24.)

! Call MZGRID to use MSIS/NOEM/IRI inputs

z =[80.,  81.,  82.,  83.,  84.,  85.,  86.,  87.,  88.,  89., &
    90.,  91.,  92.,  93.,  94.,  95.,  96.,  97.,  98.,  99., &
   100., 101., 102., 103., 104., 105., 106., 107., 108., 109., &
   110.,111.5, 113.,114.5, 116., 118., 120., 122., 124., 126., &
   128., 130., 132., 134., 137., 140., 144., 148., 153., 158., &
   164., 170., 176., 183., 190., 197., 205., 213., 221., 229., &
   237., 245., 254., 263., 272., 281., 290., 300., 310., 320., &
   330., 340., 350., 360., 370., 380., 390., 400., 410., 420., &
   430., 440., 450., 460., 470., 480., 490., 500., 510., 520., &
   530., 540., 550., 560., 570., 580., 590., 600., 610., 620., &
   630., 640. ]

call mzgrid (jmax,nex,idate,utsec,glat,glong,stl,f107a,f107,f107p,ap,iri90_dir, &
             z,zo,zo2,zn2,zns,znd,zno,ztn,zun,zvn,ze,zti,zte,zxden)
!
! Call MAXT to put auroral electron flux specified into phitop array:
!
phitop(:) = 0.
if (ef>.001 .and. ec>1.) call maxt (ef,ec,ener,del,nbins,itail,fmono,emono,phitop)
!
! Fill altitude array, converting to cm:
!
zz(:) = z(:) * 1.e5     ! km to cm at all jmax levels
!
! Call GLOW to calculate ionized and excited species, airglow emission rates,
! and vertical column brightnesses:
!
call glow
!
! Call CONDUCT to calculate Pederson and Hall conductivities:
!
do j=1,jmax
  call conduct (glat, glong, z(j), zo(j), zo2(j), zn2(j), &
                zxden(3,j), zxden(6,j), zxden(7,j), ztn(j), zti(j), zte(j), &
                pedcond(j), hallcond(j))
enddo

!! Output

write(stdout,"(1x,i7,9f8.1)") idate,utsec,glat,glong,f107a,f107,f107p,ap,ef,ec
write(stdout,"('   Z     Tn       O        N2        NO      Ne(in)    Ne(out)  Ionrate" //&
  "      O+       O2+      NO+       N(2D)    Pederson   Hall')")
write(stdout,"(1x,0p,f5.1,f6.0,1p,12e10.2)") (z(j),ztn(j),zo(j),zn2(j),zno(j),ze(j), &
  ecalc(j),tir(j),zxden(3,j),zxden(6,j),zxden(7,j),zxden(10,j),pedcond(j),hallcond(j),j=1,jmax)

!> Optical emissions  (Rayleighs)
write(stdout,"('   Z      3371    4278    5200    5577    6300    7320   10400    " //&
  "3644    7774    8446    3726    LBH     1356    1493    1304')")
write(stdout,"(1x,f5.1,15f8.2)")(z(j),(zeta(ii,j),ii=1,15),j=1,jmax)

!> energy bins
write(stdout,'(1000f15.1)') ener


contains

pure function dirname(instr,  delm)

character(*), intent(in) :: instr
character(*), intent(in) :: delm
character(:),allocatable :: dirname
integer :: idx

idx = scan(instr, delm, back=.true.)
dirname = instr(1:idx-1)

end function dirname

end program
