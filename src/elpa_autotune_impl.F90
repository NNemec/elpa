#include "config-f90.h"

module elpa_autotune_impl
  use elpa_abstract_impl
  use, intrinsic :: iso_c_binding
  implicit none

  type, extends(elpa_autotune_t) :: elpa_autotune_impl_t
    class(elpa_abstract_impl_t), pointer :: parent => NULL()
    integer :: i = 0
    real(kind=C_DOUBLE) :: min_val = 0.0_C_DOUBLE
    integer :: min_loc = 0
    integer :: N = 0
    integer :: level = 0
    integer :: domain = 0
    contains
      procedure, public :: print => elpa_autotune_print
      procedure, public :: destroy => elpa_autotune_destroy
  end type

  contains

    !> \brief function to print the autotuning
    !> Parameters
    !> \param   self  class(elpa_autotune_impl_t) the allocated ELPA autotune object
    subroutine elpa_autotune_print(self)
      implicit none
      class(elpa_autotune_impl_t), intent(in) :: self
      !print *, "Print me"
    end subroutine

    !> \brief function to destroy an elpa autotune object
    !> Parameters
    !> \param   self  class(elpa_autotune_impl_t) the allocated ELPA autotune object
    subroutine elpa_autotune_destroy(self)
      implicit none
      class(elpa_autotune_impl_t), intent(inout) :: self
      ! nothing to do atm
    end subroutine

end module
