program netcdftolittler

!     ... pressure is in Pa, height in m, temperature and dew point are in
!         K, speed is in m/s, and direction is in degrees

!     ... sea level pressure is in Pa, terrain elevation is in m, latitude
!         is in degrees N, longitude is in degrees E

!     ... to put in a surface observation, make only a single level "sounding"
!         and make the value of the height equal the terrain elevation -- PRESTO!

!     ... the first 40 character string may be used for the description of
!         the station (i.e. name city country, etc)

!     ... the second character string we use for our source

!     ... the third string should be left alone, it uses the phrase "FM-35 TEMP"
!         for an upper air station, and should use "FM-12 SYNOP" for surface data

!     ... the fourth string is unused, feel free to experiment with labels!

!     ... bogus data are not subject to quality control

! TODO: for surface data we need to write height to LITTLE_R file
! otherwise, we need to write pressure to LITTLE_R file

use readncdf
use write_littler

implicit none

integer, parameter :: kx=1

logical bogus
real :: slp, ter
integer :: idx
data bogus /.false./
integer:: iseq_num = 1

real,dimension(kx) :: p,z,t,td,spd,dir,u,v,rh,thick
integer,dimension(kx) :: p_qc,z_qc,t_qc,td_qc,spd_qc
integer, dimension(kx) :: dir_qc,u_qc,v_qc,rh_qc,thick_qc
! iseq_num: sequential number -> domain number
real, dimension(kx) :: dpressure, dheight, dtemperature, ddew_point
real, dimension(kx) ::  dspeed, ddirection, du, dv, drh, dthickness
integer, dimension(kx) :: dpressure_qc, dheight_qc, dtemperature_qc
integer, dimension(kx) ::  ddew_point_qc, dspeed_qc, ddirection_qc, du_qc
integer, dimension(kx) :: dv_qc, drh_qc, dthickness_qc
      
character(len=14) :: timechar
character *20 date_char
character *40 string1, string2 , string3 , string4
          
INTEGER :: timeLength, device
REAL,DIMENSION(:), ALLOCATABLE :: humidity, height, speed
REAL,DIMENSION(:), ALLOCATABLE :: temperature, dew_point
REAL,DIMENSION(:), ALLOCATABLE :: pressure, direction, thickness
REAL,DIMENSION(:), ALLOCATABLE :: uwind, vwind
      
character(len=14), dimension(:), allocatable :: time_littler
real,dimension(:), allocatable    :: time
character(len=100) :: timeunits

INTEGER:: pp
REAL :: lon, lat

character(len=30), dimension(2):: variable_name
character(len=30), dimension(2):: variable_mapping
character(len=30):: filename, outfile
integer :: devices, dimensions
real :: fill_value
      

! get filename, variable_names and variable_mappings from namelist
namelist /group_name/ filename, variable_name, variable_mapping, devices, &
    outfile, dimensions
  open(10,file='./wageningen.namelist')
  read(10,group_name)
  close(10)

! check if dimensions and namelist are correct in namelist
if (.not. ((dimensions==1 .AND. devices==1) .or. &
  (dimensions==2 .AND. devices>=1))) then
    STOP 'Error in namelist specification of dimensions and devices'
end if

call get_default_littler(dpressure, dheight, dtemperature, ddew_point, &
  dspeed, ddirection, du, dv, drh, dthickness,dpressure_qc, &
  dheight_qc, dtemperature_qc, ddew_point_qc, dspeed_qc, &
  ddirection_qc, du_qc, dv_qc, drh_qc, dthickness_qc, kx)
! get length of time axis and time axis
call readtimedim(filename, time, timeunits)
timeLength = size(time)
allocate(time_littler(timeLength))
call time_to_littler_date(time, timeunits, time_littler)

! loop over all devices
do device=1,devices
  ! read variable
  do idx=1,size(variable_name)
    call read_variables(humidity, height, speed, temperature, dew_point, &
      pressure, direction, thickness, uwind, vwind, variable_name, &
      variable_mapping, filename, fill_value, idx, device, dimensions)
  end do
  ! put this in a subroutine or function
  call write_obs_littler(p,z,t,td,spd,dir,u,v,rh,thick, &
    p_qc,z_qc,t_qc,td_qc,spd_qc,dir_qc,u_qc,v_qc,rh_qc,thick_qc, &
    slp , ter , lat , lon , variable_mapping, kx, bogus, iseq_num, time_littler, &
    outfile )
end do
stop 99999
end


