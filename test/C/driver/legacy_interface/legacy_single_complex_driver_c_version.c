/*     This file is part of ELPA. */
/*  */
/*     The ELPA library was originally created by the ELPA consortium, */
/*     consisting of the following organizations: */
/*  */
/*     - Max Planck Computing and Data Facility (MPCDF), formerly known as */
/*       Rechenzentrum Garching der Max-Planck-Gesellschaft (RZG), */
/*     - Bergische Universität Wuppertal, Lehrstuhl für angewandte */
/*       Informatik, */
/*     - Technische Universität München, Lehrstuhl für Informatik mit */
/*       Schwerpunkt Wissenschaftliches Rechnen , */
/*     - Fritz-Haber-Institut, Berlin, Abt. Theorie, */
/*     - Max-Plack-Institut für Mathematik in den Naturwissenschaften, */
/*       Leipzig, Abt. Komplexe Strukutren in Biologie und Kognition, */
/*       and */
/*     - IBM Deutschland GmbH */
/*  */
/*  */
/*     More information can be found here: */
/*     http://elpa.mpcdf.mpg.de/ */
/*  */
/*     ELPA is free software: you can redistribute it and/or modify */
/*     it under the terms of the version 3 of the license of the */
/*     GNU Lesser General Public License as published by the Free */
/*     Software Foundation. */
/*  */
/*     ELPA is distributed in the hope that it will be useful, */
/*     but WITHOUT ANY WARRANTY; without even the implied warranty of */
/*     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the */
/*     GNU Lesser General Public License for more details. */
/*  */
/*     You should have received a copy of the GNU Lesser General Public License */
/*     along with ELPA.  If not, see <http://www.gnu.org/licenses/> */
/*  */
/*     ELPA reflects a substantial effort on the part of the original */
/*     ELPA consortium, and we ask you to respect the spirit of the */
/*     license that we chose: i.e., please contribute any changes you */
/*     may have back to the original ELPA library distribution, and keep */
/*     any derivatives of ELPA under the same license that we chose for */
/*     the original distribution, the GNU Lesser General Public License. */
/*  */
/*  */

#include "config-f90.h"

#include <stdio.h>
#include <stdlib.h>
#ifdef WITH_MPI
#include <mpi.h>
#endif
#include <math.h>

#include <elpa/elpa_legacy.h>
#include <test/shared/generated.h>
#include <complex.h>

int main(int argc, char** argv) {
   int myid;
   int nprocs;
#ifndef WITH_MPI
   int MPI_COMM_WORLD;
#endif
   int na, nev, nblk;

   int status;

   int np_cols, np_rows, np_colsStart;

   int my_blacs_ctxt, my_prow, my_pcol;

   int mpierr;

   int my_mpi_comm_world;
   int mpi_comm_rows, mpi_comm_cols;

   int info, *sc_desc;

   int na_rows, na_cols;
   float startVal;

   complex float *a, *z, *as;

   float *ev;

   int success;
   int i;

   int useGPU, THIS_COMPLEX_ELPA_KERNEL_API;
#ifdef WITH_MPI
   MPI_Init(&argc, &argv);
   MPI_Comm_size(MPI_COMM_WORLD, &nprocs);
   MPI_Comm_rank(MPI_COMM_WORLD, &myid);
#else
   nprocs = 1;
   myid =0;
   MPI_COMM_WORLD=1;
#endif
   na = 1000;
   nev = 500;
   nblk = 16;

   if (myid == 0) {
     printf("This is the c version of an ELPA test-programm\n");
     printf("\n");
     printf("It will call the ELPA complex solver for a matrix\n");
     printf("of matrix size %d. It will compute %d eigenvalues\n",na,nev);
     printf("and uses a blocksize of %d\n",nblk);
     printf("\n");
     printf("This is an example program with much less functionality\n");
     printf("as it's Fortran counterpart. It's only purpose is to show how \n");
     printf("to evoke ELPA1 from a c programm\n");

     printf("\n");

   }

   status = 0;

   startVal = sqrt((float) nprocs);
   np_colsStart = (int) round(startVal);
   for (np_cols=np_colsStart;np_cols>1;np_cols--){
     if (nprocs %np_cols ==0){
     break;
     }
   }

   np_rows = nprocs/np_cols;

   if (myid == 0) {
     printf("\n");
     printf("Number of processor rows %d, cols %d, total %d \n",np_rows,np_cols,nprocs);
   }

   /* set up blacs */
   /* convert communicators before */
#ifdef WITH_MPI
   my_mpi_comm_world = MPI_Comm_c2f(MPI_COMM_WORLD);
#else
   my_mpi_comm_world = 1;
#endif
   set_up_blacsgrid_f(my_mpi_comm_world, np_rows, np_cols, 'C', &my_blacs_ctxt, &my_prow, &my_pcol);

   if (myid == 0) {
     printf("\n");
     printf("Past BLACS_Gridinfo...\n");
     printf("\n");
   }

   /* get the ELPA row and col communicators. */
   /* These are NOT usable in C without calling the MPI_Comm_f2c function on them !! */
#ifdef WITH_MPI
   my_mpi_comm_world = MPI_Comm_c2f(MPI_COMM_WORLD);
#endif
   mpierr = elpa_get_communicators(my_mpi_comm_world, my_prow, my_pcol, &mpi_comm_rows, &mpi_comm_cols);

   if (myid == 0) {
     printf("\n");
     printf("Past split communicator setup for rows and columns...\n");
     printf("\n");
   }

   sc_desc = malloc(9*sizeof(int));

   set_up_blacs_descriptor_f(na, nblk, my_prow, my_pcol, np_rows, np_cols, &na_rows, &na_cols, sc_desc, my_blacs_ctxt, &info);

   if (myid == 0) {
     printf("\n");
     printf("Past scalapack descriptor setup...\n");
     printf("\n");
   }

   /* allocate the matrices needed for elpa */
   if (myid == 0) {
     printf("\n");
     printf("Allocating matrices with na_rows=%d and na_cols=%d\n",na_rows, na_cols);
     printf("\n");
   }

   a  = malloc(na_rows*na_cols*sizeof(complex float));
   z  = malloc(na_rows*na_cols*sizeof(complex float));
   as = malloc(na_rows*na_cols*sizeof(complex float));
   ev = malloc(na*sizeof(float));

   prepare_matrix_random_complex_single_f(na, myid, na_rows, na_cols, sc_desc, a, z, as);

   if (myid == 0) {
     printf("\n");
     printf("Entering ELPA 1stage complex solver\n");
     printf("\n");
   }
#ifdef WITH_MPI
   mpierr = MPI_Barrier(MPI_COMM_WORLD);
#endif
   useGPU = 0;
   THIS_COMPLEX_ELPA_KERNEL_API = ELPA_2STAGE_COMPLEX_DEFAULT;
   success = elpa_solve_evp_complex_single(na, nev, a, na_rows, ev, z, na_rows, nblk, na_cols, mpi_comm_rows, mpi_comm_cols, my_mpi_comm_world, THIS_COMPLEX_ELPA_KERNEL_API, useGPU, "1stage");

   if (success != 1) {
     printf("error in ELPA solve \n");
#ifdef WITH_MPI
     mpierr = MPI_Abort(MPI_COMM_WORLD, 99);
#else
     exit(99);
#endif
   }


   if (myid == 0) {
     printf("\n");
     printf("1stage ELPA complex solver complete\n");
     printf("\n");
   }

   for (i=0;i<na_rows*na_cols;i++){
      a[i] = as[i];
      z[i] = as[i];
   }
   if (myid == 0) {
     printf("\n");
     printf("Entering ELPA 2stage complex solver\n");
     printf("\n");
   }
#ifdef WITH_MPI
   mpierr = MPI_Barrier(MPI_COMM_WORLD);
#endif
   useGPU =0;
   THIS_COMPLEX_ELPA_KERNEL_API = ELPA_2STAGE_COMPLEX_DEFAULT;
   success = elpa_solve_evp_complex_single(na, nev, a, na_rows, ev, z, na_rows, nblk, na_cols, mpi_comm_rows, mpi_comm_cols, my_mpi_comm_world, THIS_COMPLEX_ELPA_KERNEL_API, useGPU, "2stage");

   if (success != 1) {
     printf("error in ELPA solve \n");
#ifdef WITH_MPI
     mpierr = MPI_Abort(MPI_COMM_WORLD, 99);
#else
     exit(99);
#endif
   }

   if (myid == 0) {
     printf("\n");
     printf("2stage ELPA complex solver complete\n");
     printf("\n");
   }

   for (i=0;i<na_rows*na_cols;i++){
      a[i] = as[i];
      z[i] = as[i];
   }
   if (myid == 0) {
     printf("\n");
     printf("Entering auto-chosen ELPA complex solver\n");
     printf("\n");
   }
#ifdef WITH_MPI
   mpierr = MPI_Barrier(MPI_COMM_WORLD);
#endif
   useGPU = 0;
   THIS_COMPLEX_ELPA_KERNEL_API = ELPA_2STAGE_COMPLEX_DEFAULT;
   success = elpa_solve_evp_complex_single(na, nev, a, na_rows, ev, z, na_rows, nblk, na_cols, mpi_comm_rows, mpi_comm_cols, my_mpi_comm_world, THIS_COMPLEX_ELPA_KERNEL_API, useGPU, "auto");

   if (success != 1) {
     printf("error in ELPA solve \n");
#ifdef WITH_MPI
     mpierr = MPI_Abort(MPI_COMM_WORLD, 99);
#else
     exit(99);
#endif
   }

   if (myid == 0) {
     printf("\n");
     printf("Auto-chosen ELPA complex solver complete\n");
     printf("\n");
   }

   /* check the results */
   status = check_correctness_evp_numeric_residuals_complex_single_f(na, nev, na_rows, na_cols, as, z, ev, sc_desc, myid);

   if (status !=0){
     printf("The computed EVs are not correct !\n");
   }
   if (status ==0){
     if (myid == 0) {
       printf("All ok!\n");
     }
   }

   free(sc_desc);
   free(a);
   free(z);
   free(as);
   free(ev);

#ifdef WITH_MPI
   MPI_Finalize();
#endif
   return 0;
}
