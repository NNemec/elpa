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


function elpa_mult_ah_b_&
  &MATH_DATATYPE&
  &_wrapper_&
  &PRECISION&
  & ( uplo_a, uplo_c, na, ncb, a, lda, ldaCols, b, ldb, ldbCols,  nblk, mpi_comm_rows, &
     mpi_comm_cols, c, ldc, ldcCols) result(success) bind(C,name="elpa_mult_ah_b_&
     &MATH_DATATYPE&
     &_&
     &PRECISION&
     &")
    use, intrinsic :: iso_c_binding
    use elpa1_auxiliary, only : elpa_mult_ah_b_&
    &MATH_DATATYPE&
    &_&
    &PRECISION

    implicit none

    character(1,C_CHAR), value     :: uplo_a, uplo_c
    integer(kind=c_int), value     :: na, ncb, lda, ldb, nblk, mpi_comm_rows, mpi_comm_cols, ldc
    integer(kind=c_int)            :: success
    integer(kind=c_int), value     :: ldaCols, ldbCols, ldcCols
#ifdef USE_ASSUMED_SIZE
    complex(kind=C_DATATYPE_KIND)  :: a(lda,*), b(ldb,*), c(ldc,*)
#else
    complex(kind=C_DATATYPE_KIND)  :: a(lda,ldaCols), b(ldb,ldbCols), c(ldc,ldcCols)
#endif
    logical                        :: successFortran

    successFortran = elpa_mult_ah_b_&
    &MATH_DATATYPE&
    &_&
    &PRECISION&
    & (uplo_a, uplo_c, na, ncb, a, lda, ldaCols, b, ldb, ldbCols, nblk, mpi_comm_rows, mpi_comm_cols, c, ldc, ldcCols)

    if (successFortran) then
      success = 1
    else
      success = 0
     endif

  end function

