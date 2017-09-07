#!/usr/bin/env python
from __future__ import print_function
from itertools import product

domain_flag = {
        "real"   : "-DTEST_REAL",
        "complex": "-DTEST_COMPLEX",
}
prec_flag = {
        "double" : "-DTEST_DOUBLE",
        "single" : "-DTEST_SINGLE",
}
solver_flag = {
        "1stage" : "-DTEST_SOLVER_1STAGE",
        "2stage" : "-DTEST_SOLVER_2STAGE",
        "scalapack_all" : "-DTEST_SCALAPACK_ALL",
        "scalapack_part" : "-DTEST_SCALAPACK_PART",
}
gpu_flag = {
        0 : "-DTEST_GPU=0",
        1 : "-DTEST_GPU=1",
}
matrix_flag = {
        "random" : "-DTEST_MATRIX_RANDOM",
        "analytic" : "-DTEST_MATRIX_ANALYTIC",
        "toeplitz" : "-DTEST_MATRIX_TOEPLITZ",
        "frank" : "-DTEST_MATRIX_FRANK",
}

test_type_flag = {
        "eigenvectors" : "-DTEST_EIGENVECTORS",
        "eigenvalues"  : "-DTEST_EIGENVALUES",
        "solve_tridiagonal"  : "-DTEST_SOLVE_TRIDIAGONAL",
        "cholesky"  : "-DTEST_CHOLESKY",
        "hermitian_multiply"  : "-DTEST_HERMITIAN_MULTIPLY",
        "qr"  : "-DTEST_QR_DECOMPOSITION",
}

layout_flag = {
        "all_layouts" : "-DTEST_ALL_LAYOUTS",
        "square" : ""
}

for m, g, t, p, d, s, l in product(
                             sorted(matrix_flag.keys()),
                             sorted(gpu_flag.keys()),
                             sorted(test_type_flag.keys()),
                             sorted(prec_flag.keys()),
                             sorted(domain_flag.keys()),
                             sorted(solver_flag.keys()),
                             sorted(layout_flag.keys())):

    # exclude some test combinations

    # analytic tests only for "eigenvectors" and not on GPU
    if(m == "analytic" and (g == 1 or t != "eigenvectors")):
        continue

    # Frank tests only for "eigenvectors" and real case
    if(m == "frank" and (t != "eigenvectors" or d !="real")):
        continue

    if(s in ["scalapack_all", "scalapack_part"]  and (g == 1 or t != "eigenvectors" or m != "analytic")):
        continue

    if (t == "solve_tridiagonal" and (s == "2stage" or d == "complex")):
        continue

    if (t == "cholesky" and (s == "2stage")):
        continue

    if (t == "cholesky" and (m == "random")):
        continue

    if (t == "eigenvalues" and (m == "random")):
        continue

    if (t == "solve_tridiagonal" and (m == "random")):
        continue


    if (t == "hermitian_multiply" and (s == "2stage")):
        continue

    if (t == "hermitian_multiply" and (m == "toeplitz")):
        continue

    if (t == "qr" and (s == "1stage" or d == "complex")):
        continue

    for kernel in ["all_kernels", "default_kernel"] if s == "2stage" else ["nokernel"]:
        endifs = 0
        extra_flags = []

        if (t == "eigenvalues" and kernel == "all_kernels"):
           continue

        if (g == 1):
            print("if WITH_GPU_VERSION")
            endifs += 1

        if (l == "all_layouts"):
            print("if WITH_MPI")
            endifs += 1

        if (s in ["scalapack_all", "scalapack_part"]):
            print("if WITH_SCALAPACK_TESTS")
            endifs += 1

        if kernel == "default_kernel":
            extra_flags.append("-DTEST_KERNEL=ELPA_2STAGE_{0}_DEFAULT".format(d.upper()))
        elif kernel == "all_kernels":
            extra_flags.append("-DTEST_ALL_KERNELS")

        if layout_flag[l]:
            extra_flags.append(layout_flag[l])

        if (p == "single"):
            if (d == "real"):
                print("if WANT_SINGLE_PRECISION_REAL")
            elif (d == "complex"):
                print("if WANT_SINGLE_PRECISION_COMPLEX")
            else:
                raise Exception("Oh no!")
            endifs += 1

        name = "test_{0}_{1}_{2}_{3}{4}_{5}{6}{7}".format(
                    d, p, t, s,
                    "" if kernel == "nokernel" else "_" + kernel,
                    "_gpu" if g else "",
                    m,
                    "_all_layouts" if l == "all_layouts" else "")
        print("noinst_PROGRAMS += " + name)
        print("check_SCRIPTS += " + name + ".sh")
        print(name + "_SOURCES = test/Fortran/test.F90")
        print(name + "_LDADD = $(test_program_ldadd)")
        print(name + "_FCFLAGS = $(test_program_fcflags) \\")
        print("  -DTEST_CASE=\\\"{0}\\\" \\".format(name))
        print("  " + " \\\n  ".join([
            domain_flag[d],
            prec_flag[p],
            test_type_flag[t],
            solver_flag[s],
            gpu_flag[g],
            matrix_flag[m]] + extra_flags))

        print("endif\n" * endifs)
