# Installation guide for the *ELPA* library#

## Preamble ##

This file provides documentation on how to build the *ELPA* library in **version ELPA-2017.11.001**.
With release of **version ELPA-2017.05.001** the build process has been significantly simplified,
which makes it easier to install the *ELPA* library

## How to install *ELPA *##

First of all, if you do not want to build *ELPA* yourself, and you run Linux,
it is worth having a look at the [*ELPA* webpage*] (http://elpa.mpcdf.mpg.de)
and/or the repositories of your Linux distribution: there exist
pre-build packages for a number of Linux distributions like Fedora,
Debian, and OpenSuse. More, will hopefully follow in the future.

If you want to build (or have to since no packages are available) *ELPA* yourself,
please note that *ELPA* is shipped with a typical "configure" and "make"
autotools procedure. This is the **only supported way** how to build and install *ELPA*.

If you obtained *ELPA* from the official git repository, you will not find
the needed configure script! Please look at the "**INSTALL_FROM_GIT_VERSION**" file
for the documentation how to proceed.


## (A): Installing *ELPA* as library with configure ##

*ELPA* can be installed with the build steps
- configure
- make
- make check   | or make check CHECK_LEVEL=extended
- make install

Please look at configure --help for all available options.

An excerpt of the most important (*ELPA* specific) options reads as follows:

  --disable-legacy        do not build legacy API, default yes
  --enable-openmp         use OpenMP threading, default no.
  --enable-redirect       for test programs, allow redirection of
                          stdout/stderr per MPI taks in a file (useful for
                          timing), default no.
  --enable-single-precision
                          build with single precision
  --disable-timings       more detailed timing, default yes
  --disable-band-to-full-blocking
                          build ELPA2 with blocking in band_to_full (default:
                          enabled)
  --disable-mpi-module    do not use the Fortran MPI module, get interfaces by
                          'include "mpif.h')
  --disable-generic       do not build GENERIC kernels, default: enabled
  --disable-sse           do not build SSE kernels, default: enabled
  --disable-sse-assembly  do not build SSE_ASSEMBLY kernels, default: enabled
  --disable-avx           do not build AVX kernels, default: enabled
  --disable-avx2          do not build AVX2 kernels, default: enabled
  --enable-avx512         build AVX512 kernels, default: disabled
  --enable-gpu            build GPU kernels, default: disabled
  --enable-bgp            build BGP kernels, default: disabled
  --enable-bgq            build BGQ kernels, default: disabled
  --with-mpi=[yes|no]     compile with MPI. Default: yes
  --with-cuda-path=PATH   prefix where CUDA is installed [default=auto]
  --with-cuda-sdk-path=PATH
                          prefix where CUDA SDK is installed [default=auto]
  --with-GPU-compute-capability=VALUE
                          use compute capability VALUE for GPU version,
                          default: "sm_35"
  --with-fixed-real-kernel=KERNEL
                          compile with only a single specific real kernel.
                          Available kernels are: generic generic_simple
                          sse_block2 sse_block4 sse_block6 sse_assembly
                          avx_block2 avx_block4 avx_block6 avx2_block2
                          avx2_block4 avx2_block6 avx512_block2 avx512_block4
                          avx512_block6 bgp bgq
  --with-fixed-complex-kernel=KERNEL
                          compile with only a single specific complex kernel.
                          Available kernels are: generic generic_simple
                          sse_block1 sse_block2 sse_assembly avx_block1
                          avx_block2 avx2_block1 avx2_block2 avx512_block1
                          avx512_block2 bgp bgq
  --with-gpu-support-only Compile and always use the GPU version


We recommend that you do not build ELPA in it`s main directory but that you use it
in a sub-directory:

mkdir build
cd build

../configure [with all options needed for your system, see below]

In this way, you have a clean separation between original *ELPA* source files and the compiled
object files

Please note, that it is necessary to set the **compiler options** like optimisation flags etc.
for the Fortran and C part.
For example sth. like this is a usual way: ./configure FCFLAGS="-O2 -mavx" CFLAGS="-O2 -mavx"
For details, please have a look at the documentation for the compilers of your choice.


### Choice of building with or without MPI ###

It is possible to build the *ELPA* library with or without MPI support

Normally *ELPA* is build with MPI, in order to speed-up calculations by using distributed
parallelisation over several nodes. This is, however, only reasonably if the programs
calling the *ELPA* library are already MPI parallized, and *ELPA* can use the same
block-cyclic distribution of data as in the calling program.

Programs which do not support MPI parallelisation can still make use of the *ELPA* library if it
has also been build without MPI support.

If you want to build *ELPA* with MPI support, please have a look at "A) Setting of MPI compiler and libraries".
For builds without MPI support, please have a look at "B) Building *ELPA* without MPI support".

Please note, that it is absolutely supported that both versions of the *ELPA* library are build
and installed in the same directory.

### A) Setting of MPI compiler and libraries ###

In the standard case *ELPA* needs a MPI compiler and MPI libraries. The configure script
will try to set this by itself. If, however, on the build system the compiler wrapper
cannot automatically found, it is recommended to set it by hand with a variable, e.g.

configure FC=mpif90

Please note, thate setting a C MPI-compiler is NOT necessary, and in most case even harmful.

In some cases, on your system different MPI libraries and compilers are installed. Then it might happen
that during the build step an error like "no module mpi" or "cannot open module mpi" is given.
You can disable that the  *ELPA* library uses MPI modules (and instead uses MPI header files) by
adding

--disable-mpi-module

to the configure call.

Please continue reading at "C) Enabling GPU support"


### B) Building *ELPA* without MPI support ###

If you want to build *ELPA* without MPI support, add

--with-mpi=0

to your configure call.

You have to specify which compilers should be used with e.g.,

configure FC=gfortran --with-mpi=0

DO NOT specify a MPI compiler here!

Note, that the the installed *ELPA* library files will be suffixed with
"_onenode", in order to descriminate this build from possible ones with MPI.


Please continue reading at "C) Enabling GPU support"

### C) Enabling GPU support ###

The *ELPA* library can be build with GPU support. If *ELPA* is build with GPU
support, users can choose at RUNTIME, whether to use the GPU version or not.

For GPU support, NVIDIA GPUs with compute capability >= 3.5 are needed.

GPU support is set with

--enable-gpu

It might be necessary to also set the options (please see configure --help)

--with-cuda-path
--with-cuda-sdk-path
--with-GPU-compute-capability

Please continue reading at "D) Enabling OpenMP support".


### D) Enabling OpenMP support ###

The *ELPA* library can be build with OpenMP support. This can be support of hybrid
MPI/OpenMP parallelization, since *ELPA* is build with MPI support (see A ) or only
shared-memory parallization, since *ELPA* is build without MPI support (see B).

To enable OpenMP support, add

"--enable-openmp"

as configure option.

Note that as in case with/without MPI, you can also build and install versions of *ELPA*
with/without OpenMP support at the same time.

However, the GPU choice at runtime, is not compatible with OpenMP support

Please continue reading at "E) Standard libraries in default installation paths".


### E) Standard libraries in default installation paths###

In order to build the *ELPA* library, some (depending on the settings during the
configure step) libraries are needed.

Typically these are:
  - Basic Linear Algebra Subroutines (BLAS)                   (always needed)
  - Lapack routines                                           (always needed)
  - Basic Linear Algebra Communication Subroutines (BLACS)    (only needed if MPI support was set)
  - Scalapack routines                                        (only needed if MPI support was set)
  - a working MPI library                                     (only needed if MPI support was set)
  - a working OpenMP library                                  (only needed if OpenMP support was set)
  - a working CUDA/cublas library                             (only needed if GPU support was set)

If the needed library are installed on the build system in standard paths (e.g. /usr/lib64)
in the most cases the *ELPA* configure step will recognize the needed libraries
automatically. No setting of any library paths should be necessary.

If your configure steps finish succcessfully, please continue at "G) Choice of ELPA2 compute kernels".
If your configure step aborts, or you want to use libraries in non standard paths please continue at
"F) Non standard paths or non standard libraries".

### F) Non standard paths or non standard libraries ###

If standard libraries are on the build system either installed in non standard paths, or
special non standard libraries (e.g. *Intel's MKL*) should be used, it might be necessary
to specify the appropriate link-line with the **SCALAPACK_LDFLAGS** and **SCALAPACK_FCFLAGS**
variables.

For example, due to performance reasons it might be benefical to use the *BLAS*, *BLACS*, *LAPACK*,
and *SCALAPACK* implementation from *Intel's MKL* library.

Togehter with the Intel Fortran Compiler the call to configure might then look like:

configure SCALAPACK_LDFLAGS="-L$MKL_HOME/lib/intel64 -lmkl_scalapack_lp64 -lmkl_intel_lp64 -lmkl_sequential \
                             -lmkl_core -lmkl_blacs_intelmpi_lp64 -lpthread -lm -Wl,-rpath,$MKL_HOME/lib/intel64" \
	  SCALAPACK_FCFLAGS="-L$MKL_HOME/lib/intel64 -lmkl_scalapack_lp64 -lmkl_intel_lp64 -lmkl_sequential \
	                      -lmkl_core -lmkl_blacs_intelmpi_lp64 -lpthread -lm -I$MKL_HOME/include/intel64/lp64"

and for *INTEL MKL* togehter with *GNU GFORTRAN* :

configure SCALAPACK_LDFLAGS="-L$MKL_HOME/lib/intel64 -lmkl_scalapack_lp64 -lmkl_gf_lp64 -lmkl_sequential \
                             -lmkl_core -lmkl_blacs_intelmpi_lp64 -lpthread -lm -Wl,-rpath,$MKL_HOME/lib/intel64" \
	  SCALAPACK_FCFLAGS="-L$MKL_HOME/lib/intel64 -lmkl_scalapack_lp64 -lmkl_gf_lp64 -lmkl_sequential \
	                     -lmkl_core -lmkl_blacs_intelmpi_lp64 -lpthread -lm -I$MKL_HOME/include/intel64/lp64"


Please, for the correct link-line refer to the documentation of the correspondig library. In case of *Intel's MKL* we
sugest the [Intel Math Kernel Library Link Line Advisor] (https://software.intel.com/en-us/articles/intel-mkl-link-line-advisor).


### G) Choice of ELPA2 compute kernels ###

ELPA 2stage can be used with different implementations of compute intensive kernels, which are architecture dependent.
Some kernels (all for x86_64 architectures) are enabled by default (and must be disabled if you do not want them),
others are disabled by default and must be enabled if they are wanted.

One can enable or disable "kernel classes" by setting e.g.

--enable-avx2

This will try to build all the AVX2 kernels. Please see configure --help for all options

During the configure step all possible kernels will be printed, and whether they will be enabled or not.

It is possible to build *ELPA* with as many kernels as desired, the user can then choose at runtime which
kernels should be used.

It this is not desired, it is possible to build *ELPA* with only one (not necessary the same) kernel for the
real and complex valued case, respectively. This can be done with the "--with-fixed-real-kernel=NAME" or
"--with-fixed-complex-kernel=NAME" configure options. For details please do a "configure --help"

### Doxygen documentation ###
A doxygen documentation can be created with the "--enable-doxygen-doc" configure option

### Some examples ###

#### Intel cores supporting AVX2 (Hasell and newer) ####

We recommend that you build ELPA with the Intel compiler (if available) for the Fortran part, but
with GNU compiler for the C part.

1. Building with Intel Fortran compiler and GNU C compiler:

Remarks: - you have to know the name of the Intel Fortran compiler wrapper
         - you do not have to specify a C compiler (with CC); GNU C compiler is recognized automatically
	 - you should specify compiler flags for Intel Fortran compiler; in the example only "-O3 -xAVX2" is set
	 - you should be carefull with the CFLAGS. The example shows typical flags

FC=wrapper_for_intel_compiler ./configure FCFLAGS="-O3 -xAVX2" CFLAGS="-O3 -march=native -mavx2 -mfma funsafe-loop-optimizations -funsafe-math-optimizations -ftree-vect-loop-version -ftree-vectorize" --enable-option-checking=fatal SCALAPACK_LDFLAGS="L$MKLROOT/lib/intel64 -lmkl_scalapack_lp64 -lmkl_intel_lp64 -lmkl_sequential -lmkl_core -lmkl_blacs_intelmpi_lp64 -lpthread " SCALAPACK_FCFLAGS="-I$MKL_HOME/include/intel64/lp64"


2. Building with GNU Fortran compiler and GNU C compiler:

Remarks: - you have to know the name of the GNU Fortran compiler wrapper
         - you do not have to specify a C compiler (with CC); GNU C compiler is recognized automatically
	 - you should specify compiler flags for GNU Fortran compiler; in the example only "-O3 -march=native -mavx2 -mfma" is set
	 - you should be carefull with the CFLAGS. The example shows typical flags

FC=wrapper_for_gnu_compiler ./configure FCFLAGS="-O3 -march=native -mavx2 -mfma" CFLAGS="-O3 -march=native -mavx2 -mfma funsafe-loop-optimizations -funsafe-math-optimizations -ftree-vect-loop-version -ftree-vectorize" --enable-option-checking=fatal SCALAPACK_LDFLAGS="L$MKLROOT/lib/intel64 -lmkl_scalapack_lp64 -lmkl_gf_lp64 -lmkl_sequential -lmkl_core -lmkl_blacs_intelmpi_lp64 -lpthread " SCALAPACK_FCFLAGS="-I$MKL_HOME/include/intel64/lp64"


2. Building with Intel Fortran compiler and Intel C compiler:

Remarks: - you have to know the name of the Intel Fortran compiler wrapper
         - you have to specify the Intel C compiler
	 - you should specify compiler flags for Intel Fortran compiler; in the example only "-O3 -xAVX2" is set
	 - you should be carefull with the CFLAGS. The example shows typical flags

FC=wrapper_for_gnu_compiler CC=icc ./configure FCFLAGS="-O3 -xAVX2" CFLAGS="-O3 -xAVX2" --enable-option-checking=fatal SCALAPACK_LDFLAGS="L$MKLROOT/lib/intel64 -lmkl_scalapack_lp64 -lmkl_intel_lp64 -lmkl_sequential -lmkl_core -lmkl_blacs_intelmpi_lp64 -lpthread " SCALAPACK_FCFLAGS="-I$MKL_HOME/include/intel64/lp64"









