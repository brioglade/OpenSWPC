!! ----------------------------------------------------------------------------------------------------------------------------- !!
!>
!! User-routines for defining velocity/attenuation structure
!!
!! @copyright
!!   Copyright 2013-2018 Takuto Maeda. All rights reserved. This project is released under the MIT license.
!<
!! ----

#include "m_debug.h"
module m_vmodel_uni

  use m_std
  use m_debug
  use m_readini
  use m_global
  implicit none
  private
  save

  public :: vmodel_uni

contains

  !! --------------------------------------------------------------------------------------------------------------------------- !!
  !>
  !! Define meidum velocity, density and attenuation
  !<
  !! ----
  subroutine vmodel_uni( io_prm, i0, i1, k0, k1, xc, zc, vcut, rho, lam, mu, Qp, Qs, bd )

    !! -- Arguments
    integer,  intent(in)  :: io_prm
    integer,  intent(in)  :: i0, i1                  !< i-region
    integer,  intent(in)  :: k0, k1                  !< k-region
    real(SP), intent(in)  :: xc  ( i0:i1 )           !< x-coordinate location
    real(SP), intent(in)  :: zc  ( k0:k1 )           !< z-coordinate location
    real(SP), intent(in)  :: vcut                    !< cut-off minimum velocity
    real(SP), intent(out) :: rho ( k0:k1, i0:i1 )    !< mass density [g/cm^3]
    real(SP), intent(out) :: lam ( k0:k1, i0:i1 )    !< Lame's parameter lambda [ (g/cm^3) * (km/s) ]
    real(SP), intent(out) :: mu  ( k0:k1, i0:i1 )    !< Lame's parameter mu     [ (g/cm^3) * (km/s) ]
    real(SP), intent(out) :: qp  ( k0:k1, i0:i1 )    !< P-wave attenuation
    real(SP), intent(out) :: qs  ( k0:k1, i0:i1 )    !< S-wave attenuation
    real(SP), intent(out) :: bd  ( i0:i1, 0:NBD )    !< Boundary depths
    !! --

    integer  :: i, k
    real(SP) :: vp0, vs0, rho0, qp0, qs0, topo0
    real(SP) :: vp1, vs1
    real(SP) :: dum
    !! ----

    call readini( io_prm, 'vp0',    vp0, 5.0 )
    call readini( io_prm, 'vs0',    vs0, vp0/sqrt(3.0) )
    call readini( io_prm, 'rho0',   rho0, 2.7 )
    call readini( io_prm, 'qp0',    qp0, 1000000.0 )
    call readini( io_prm, 'qs0',    qs0, 1000000.0 )
    call readini( io_prm, 'topo0',  topo0, 0.0 )

    if( fullspace_mode ) then
      rho(:,:) = rho0
      mu (:,:) = rho0 * vs0 * vs0
      lam(:,:) = rho0 * ( vp0*vp0 - 2*vs0*vs0 )
      qp (:,:) = qp0
      qs (:,:) = qs0
      bd(:,0) = -9999
    else    
      do i = i0, i1

        bd(i,0) = topo0

        do k = k0, k1

          if( zc( k ) > bd(i,0) ) then

            !! elastic medium

            rho(k,i) = rho0
            mu (k,i) = rho0 * vs0 * vs0
            lam(k,i) = rho0 * ( vp0*vp0 - 2*vs0*vs0 )
            qp (k,i) = qp0
            qs (k,i) = qs0

          else if ( zc (k) > 0.0 ) then

            !! ocean column

            vp1 = 1.5
            vs1 = 0.0

            rho(k,i) = 1.0
            mu (k,i) = rho(k,i) * vs1 * vs1
            lam(k,i) = rho(k,i) * ( vp1*vp1 - 2*vs1*vs1 )
            qp (k,i) = 1000000.0 ! effectively no attenuation in ocean column
            qs (k,i) = 1000000.0

          else

            !! air column

            vp1 = 0.0
            vs1 = 0.0

            rho(k,i) = 0.001
            mu (k,i) = rho(k,i) * vs1 * vs1
            lam(k,i) = rho(k,i) * ( vp1*vp1 - 2*vs1*vs1 )
            qp (k,i) = 10.0 ! artificially strong attenuation in air-column
            qs (k,i) = 10.0 ! artificially strong attenuation in air-column

          end if
        end do
      end do
    end if
    

    ! dummy value
    bd(:,1:NBD) = -9999
    dum = xc(i0)
    dum = zc(i0)
    dum = vcut

  end subroutine vmodel_uni
  !! --------------------------------------------------------------------------------------------------------------------------- !!


end module m_vmodel_uni
!! ----------------------------------------------------------------------------------------------------------------------------- !!
