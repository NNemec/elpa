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
#include "config-f90.h"
!>
!> Fortran test programm to demonstrates the use of
!> ELPA 1 complex case library.
!> If "HAVE_REDIRECT" was defined at build time
!> the stdout and stderr output of each MPI task
!> can be redirected to files if the environment
!> variable "REDIRECT_ELPA_TEST_OUTPUT" is set
!> to "true".
!>
!> By calling executable [arg1] [arg2] [arg3] [arg4]
!> one can define the size (arg1), the number of
!> Eigenvectors to compute (arg2), and the blocking (arg3).
!> If these values are not set default values (500, 150, 16)
!> are choosen.
!> If these values are set the 4th argument can be
!> "output", which specifies that the EV's are written to
!> an ascii file.
!>
program test_complex_gpu_version_double_precision

!-------------------------------------------------------------------------------
! Standard eigenvalue problem - COMPLEX version
!
! This program demonstrates the use of the ELPA module
! together with standard scalapack routines
!
! Copyright of the original code rests with the authors inside the ELPA
! consortium. The copyright of any additional modifications shall rest
! with their original authors, but shall adhere to the licensing terms
! distributed along with the original code in the file "COPYING".
!-------------------------------------------------------------------------------
   use elpa1
   use elpa_utilities, only : error_unit

   use test_util
   use test_read_input_parameters
   use test_check_correctness
   use test_setup_mpi
   use test_blacs_infrastructure
   use test_prepare_matrix
#ifdef HAVE_REDIRECT
   use test_redirect
#endif

  use test_output_type
   implicit none

   !-------------------------------------------------------------------------------
   ! Please set system size parameters below!
   ! na:   System size
   ! nev:  Number of eigenvectors to be calculated
   ! nblk: Blocking factor in block cyclic distribution
   !-------------------------------------------------------------------------------

   integer(kind=ik)              :: nblk
   integer(kind=ik)              :: na, nev

   integer(kind=ik)              :: np_rows, np_cols, na_rows, na_cols

   integer(kind=ik)              :: myid, nprocs, my_prow, my_pcol, mpi_comm_rows, mpi_comm_cols
   integer(kind=ik)              :: i, mpierr, my_blacs_ctxt, sc_desc(9), info, nprow, npcol

   real(kind=rk8), allocatable    :: ev(:)

   complex(kind=ck8), allocatable :: a(:,:), z(:,:), as(:,:)

   complex(kind=ck8), parameter   :: CZERO = (0._rk8,0.0_rk8), CONE = (1._rk8,0._rk8)

   integer(kind=ik)              :: STATUS
#ifdef WITH_OPENMP
   integer(kind=ik)              :: omp_get_max_threads,  required_mpi_thread_level, provided_mpi_thread_level
#endif
   type(output_t)                :: write_to_file
   logical                       :: success
   character(len=8)              :: task_suffix
   integer(kind=ik)              :: j
   logical                       :: useGPU
#define DOUBLE_PRECISION_COMPLEX 1

   success = .true.
   ! read input parameters if they are provided
   call read_input_parameters(na, nev, nblk, write_to_file)

   !-------------------------------------------------------------------------------
   !  MPI Initialization
   call setup_mpi(myid, nprocs)

   STATUS = 0

#define COMPLEXCASE
#define ELPA1
#include "../../elpa_print_headers.F90"

   !-------------------------------------------------------------------------------
   ! Selection of number of processor rows/columns
   ! We try to set up the grid square-like, i.e. start the search for possible
   ! divisors of nprocs with a number next to the square root of nprocs
   ! and decrement it until a divisor is found.

   do np_cols = NINT(SQRT(REAL(nprocs))),2,-1
      if(mod(nprocs,np_cols) == 0 ) exit
   enddo
   ! at the end of the above loop, nprocs is always divisible by np_cols

   np_rows = nprocs/np_cols

   if(myid==0) then
      print *
      print '(a)','Standard eigenvalue problem - COMPLEX version'
      print *
      print '((a,i0))', 'Matrix size: ', na 
      print '((a,i0))', 'Num eigenvectors: ', nev
      print '((a,i0))', 'Blocksize: ', nblk 
      print '((a,i0))', 'Num MPI proc: ', nprocs 
      print '((a))', 'Using gpu: YES'
      print '((a))', 'Number type: complex'
      print '((a))', 'Number precision: double'
      print *
      print '(3(a,i0))','Number of processor rows=',np_rows,', cols=',np_cols,', total=',nprocs
      print *
   endif

   !-------------------------------------------------------------------------------
   ! Set up BLACS context and MPI communicators
   !
   ! The BLACS context is only necessary for using Scalapack.
   !
   ! For ELPA, the MPI communicators along rows/cols are sufficient,
   ! and the grid setup may be done in an arbitrary way as long as it is
   ! consistent (i.e. 0<=my_prow<np_rows, 0<=my_pcol<np_cols and every
   ! process has a unique (my_prow,my_pcol) pair).

   call set_up_blacsgrid(mpi_comm_world, np_rows, np_cols, 'C', &
                         my_blacs_ctxt, my_prow, my_pcol)

   if (myid==0) then
     print '(a)','| Past BLACS_Gridinfo.'
   end if

   ! All ELPA routines need MPI communicators for communicating within
   ! rows or columns of processes, these are set in elpa_get_communicators.

   mpierr = elpa_get_communicators(mpi_comm_world, my_prow, my_pcol, &
                                   mpi_comm_rows, mpi_comm_cols)

   if (myid==0) then
     print '(a)','| Past split communicator setup for rows and columns.'
   end if

   ! Determine the necessary size of the distributed matrices,
   ! we use the Scalapack tools routine NUMROC for that.

   call set_up_blacs_descriptor(na ,nblk, my_prow, my_pcol, np_rows, np_cols, &
                                na_rows, na_cols, sc_desc, my_blacs_ctxt, info)

   if (myid==0) then
     print '(a)','| Past scalapack descriptor setup.'
   end if

   !-------------------------------------------------------------------------------
   ! Allocate matrices and set up a test matrix for the eigenvalue problem

   allocate(a (na_rows,na_cols))
   allocate(z (na_rows,na_cols))
   allocate(as(na_rows,na_cols))

   allocate(ev(na))

   call prepare_matrix_random(na, myid, sc_desc, a, z, as)

   !-------------------------------------------------------------------------------
   ! Calculate eigenvalues/eigenvectors

   if (myid==0) then
     print '(a)','| Entering one-step ELPA solver ... '
     print *
   end if
#ifdef WITH_MPI
   call mpi_barrier(mpi_comm_world, mpierr) ! for correct timings only
#endif
   useGPU = .true.
   success = solve_evp_complex_1stage_double(na, nev, a, na_rows, ev, z, na_rows, nblk, &
                               na_cols, mpi_comm_rows, mpi_comm_cols, mpi_comm_world, useGPU)

   if (.not.(success)) then
      write(error_unit,*) "solve_evp_complex produced an error! Aborting..."
#ifdef WITH_MPI
      call MPI_ABORT(mpi_comm_world, 1, mpierr)
#else
      call exit(1)
#endif
   endif

   if (myid==0) then
     print '(a)','| One-step ELPA solver complete.'
     print *
   end if

   if(myid == 0) print *,'Time tridiag_complex  :',time_evp_fwd
   if(myid == 0) print *,'Time solve_tridi      :',time_evp_solve
   if(myid == 0) print *,'Time trans_ev_complex :',time_evp_back
   if(myid == 0) print *,'Total time (sum above):',time_evp_back+time_evp_solve+time_evp_fwd

   if(write_to_file%eigenvectors) then
     write(unit = task_suffix, fmt = '(i8.8)') myid
     open(17,file="EVs_complex_out_task_"//task_suffix(1:8)//".txt",form='formatted',status='new')
     write(17,*) "Part of eigenvectors: na_rows=",na_rows,"of na=",na," na_cols=",na_cols," of na=",na

     do i=1,na_rows
       do j=1,na_cols
         write(17,*) "row=",i," col=",j," element of eigenvector=",z(i,j)
       enddo
     enddo
     close(17)
   endif

   if(write_to_file%eigenvalues) then
      if (myid == 0) then
         open(17,file="Eigenvalues_complex_out.txt",form='formatted',status='new')
         do i=1,na
            write(17,*) i,ev(i)
         enddo
         close(17)
      endif
   endif


   !-------------------------------------------------------------------------------
   ! Test correctness of result (using plain scalapack routines)
   status = check_correctness_evp_numeric_residuals(na, nev, as, z, ev, sc_desc, nblk, myid, np_rows, np_cols, my_prow, my_pcol)

   deallocate(a)
   deallocate(as)
   deallocate(z)
   deallocate(ev)

#ifdef WITH_MPI
   call blacs_gridexit(my_blacs_ctxt)
   call mpi_finalize(mpierr)
#endif
   call EXIT(STATUS)
end

!-------------------------------------------------------------------------------
