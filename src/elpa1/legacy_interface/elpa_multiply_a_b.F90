!    This file is part of ELPA.
!
!    The ELPA library was originally created by the ELPA consortium,
!    consisting of the following organizations:
!
!    - Max Planck Computing and Data Facility (MPCDF), formerly known as
!      Rechenzentrum Garching der Max-Planck-Gesellschaft (RZG),
!    - Bergische Universität Wuppertal, Lehrstuhl für angewandte
!      Informatik,
!    - Technische Universität München, Lehrstuhl für Informatik mit
!      Schwerpunkt Wissenschaftliches Rechnen ,
!    - Fritz-Haber-Institut, Berlin, Abt. Theorie,
!    - Max-Plack-Institut für Mathematik in den Naturwissenschaften,
!      Leipzig, Abt. Komplexe Strukutren in Biologie und Kognition,
!      and
!    - IBM Deutschland GmbH
!
!    This particular source code file contains additions, changes and
!    enhancements authored by Intel Corporation which is not part of
!    the ELPA consortium.
!
!    More information can be found here:
!    http://elpa.mpcdf.mpg.de/
!
!    ELPA is free software: you can redistribute it and/or modify
!    it under the terms of the version 3 of the license of the
!    GNU Lesser General Public License as published by the Free
!    Software Foundation.
!
!    ELPA is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU Lesser General Public License for more details.
!
!    You should have received a copy of the GNU Lesser General Public License
!    along with ELPA.  If not, see <http://www.gnu.org/licenses/>
!
!    ELPA reflects a substantial effort on the part of the original
!    ELPA consortium, and we ask you to respect the spirit of the
!    license that we chose: i.e., please contribute any changes you
!    may have back to the original ELPA library distribution, and keep
!    any derivatives of ELPA under the same license that we chose for
!    the original distribution, the GNU Lesser General Public License.
!
!
! ELPA1 -- Faster replacements for ScaLAPACK symmetric eigenvalue routines
!
! Copyright of the original code rests with the authors inside the ELPA
! consortium. The copyright of any additional modifications shall rest
! with their original authors, but shall adhere to the licensing terms
! distributed along with the original code in the file "COPYING".
!
! Author: A. Marek, MPCDF


#include "../../general/sanity.F90"
      use elpa
!      use elpa1_compute
      use elpa_mpi
      use precision
      implicit none

      character*1                   :: uplo_a, uplo_c

      integer(kind=ik), intent(in)  :: na, lda, ldaCols, ldb, ldbCols, ldc, ldcCols, nblk
      integer(kind=ik)              :: ncb, mpi_comm_rows, mpi_comm_cols
#if REALCASE == 1
#ifdef USE_ASSUMED_SIZE
      real(kind=REAL_DATATYPE)                 :: a(lda,*), b(ldb,*), c(ldc,*)
#else
      real(kind=REAL_DATATYPE)                 :: a(lda,ldaCols), b(ldb,ldbCols), c(ldc,ldcCols)
#endif
#endif
#if COMPLEXCASE == 1
#ifdef USE_ASSUMED_SIZE
      complex(kind=COMPLEX_DATATYPE)           ::  a(lda,*), b(ldb,*), c(ldc,*)
#else
      complex(kind=COMPLEX_DATATYPE)           :: a(lda,ldaCols), b(ldb,ldbCols), c(ldc,ldcCols)
#endif
#endif
  !    integer(kind=ik)                         :: my_prow, my_pcol, np_rows, np_cols, mpierr
  !    integer(kind=ik)                         :: l_cols, l_rows, l_rows_np
!      integer(kind=ik)                         :: np, n, nb, nblk_mult, lrs, lre, lcs, lce
!      integer(kind=ik)                         :: gcol_min, gcol, goff
!      integer(kind=ik)                         :: nstor, nr_done, noff, np_bc, n_aux_bc, nvals
!      integer(kind=ik), allocatable            :: lrs_save(:), lre_save(:)

!      logical                                     :: a_lower, a_upper, c_lower, c_upper
!#if REALCASE == 1
!      real(kind=REAL_DATATYPE), allocatable       :: aux_mat(:,:), aux_bc(:), tmp1(:,:), tmp2(:,:)
!#endif
!#if COMPLEXCASE == 1
!      complex(kind=COMPLEX_DATATYPE), allocatable :: aux_mat(:,:), aux_bc(:), tmp1(:,:), tmp2(:,:)
!#endif
!      integer(kind=ik)                            :: istat
!      character(200)                              :: errorMessage
      logical                                     :: success
      integer(kind=ik)                            :: successInternal, error
      class(elpa_t), pointer                      :: e

      !call timer%start("elpa_mult_at_b_&
      !&MATH_DATATYPE&
      !&_&
      !&PRECISION&
      !&_legacy_interface")

      success = .true.

      !call mpi_comm_rank(mpi_comm_rows,my_prow,mpierr)
      !call mpi_comm_size(mpi_comm_rows,np_rows,mpierr)
      !call mpi_comm_rank(mpi_comm_cols,my_pcol,mpierr)
      !call mpi_comm_size(mpi_comm_cols,np_cols,mpierr)

      !l_rows = local_index(na,  my_prow, np_rows, nblk, -1) ! Local rows of a and b
      !l_cols = local_index(ncb, my_pcol, np_cols, nblk, -1) ! Local cols of b

      if (elpa_init(CURRENT_API_VERSION) /= ELPA_OK) then
        print *, "ELPA API version not supported"
        success = .false.
        return
      endif

      e => elpa_allocate()

      call e%set("na", na, error)
      if (error .ne. ELPA_OK) then
         print *,"Problem setting option. Aborting..."
         stop
      endif
      call e%set("local_nrows", lda, error)
      if (error .ne. ELPA_OK) then
         print *,"Problem setting option. Aborting..."
         stop
      endif
      call e%set("local_ncols", ldaCols, error)
      if (error .ne. ELPA_OK) then
         print *,"Problem setting option. Aborting..."
         stop
      endif
      call e%set("nblk", nblk, error)
      if (error .ne. ELPA_OK) then
         print *,"Problem setting option. Aborting..."
         stop
      endif

      call e%set("mpi_comm_rows", mpi_comm_rows, error)
      if (error .ne. ELPA_OK) then
         print *,"Problem setting option. Aborting..."
         stop
      endif
      call e%set("mpi_comm_cols", mpi_comm_cols, error)
      if (error .ne. ELPA_OK) then
         print *,"Problem setting option. Aborting..."
         stop
      endif

      if (e%setup() .ne. ELPA_OK) then
        print *, "Cannot setup ELPA instance"
        success = .false.
      endif

      call e%hermitian_multiply(uplo_a, uplo_c, ncb, a(1:lda,1:ldaCols), &
                                b(1:ldb,1:ldbCols), ldb, ldbCols, &
                                c(1:ldc,1:ldcCols), ldc, ldcCols, successInternal)

      if (successInternal .ne. ELPA_OK) then
        print *, "Cannot run multiply_a_b"
        success = .false.
        return
      endif
      call elpa_deallocate(e)

      call elpa_uninit()

      !call timer%stop("elpa_mult_at_b_&
      !&MATH_DATATYPE&
      !&_&
      !&PRECISION&
      !&_legacy_interface")

#undef REALCASE
#undef COMPLEXCASE
#undef DOUBLE_PRECISION
#undef SINGLE_PRECISION

