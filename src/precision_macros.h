#ifdef DOUBLE_PRECISION_REAL
#define M_elpa_transpose_vectors_real_PRECISSION elpa_transpose_vectors_real_double
#define M_elpa_reduce_add_vectors_real_PRECISSION elpa_reduce_add_vectors_real_double

#define M_bandred_real_PRECISSION bandred_real_double
#define M_trans_ev_band_to_full_real_PRECISSION trans_ev_band_to_full_real_double
#define M_tridiag_band_real_PRECISSION tridiag_band_real_double
#define M_trans_ev_tridi_to_band_real_PRECISSION trans_ev_tridi_to_band_real_double
#define M_band_band_real_PRECISSION band_band_real_double
#define M_tridiag_real_PRECISSION tridiag_real_double
#define M_trans_ev_real_PRECISSION trans_ev_real_double
#define M_solve_tridi_PRECISSION solve_tridi_double
#define M_solve_tridi_col_PRECISSION solve_tridi_col_double
#define M_solve_tridi_single_problem_PRECISSION solve_tridi_single_problem_double

#define M_qr_pdgeqrf_2dcomm_PRECISSION qr_pdgeqrf_2dcomm_double
#define M_hh_transform_real_PRECISSION hh_transform_real_double
#define M_symm_matrix_allreduce_PRECISSION symm_matrix_allreduce_double
#define M_redist_band_real_PRECISSION redist_band_real_double
#define M_unpack_row_real_cpu_PRECISSION unpack_row_real_cpu_double
#define M_unpack_row_real_cpu_openmp_PRECISSION unpack_row_real_cpu_openmp_double
#define M_unpack_and_prepare_row_group_real_gpu_PRECISSION unpack_and_prepare_row_group_real_gpu_double
#define M_extract_hh_tau_real_gpu_PRECISSION extract_hh_tau_real_gpu_double
#define M_compute_hh_dot_products_real_gpu_PRECISSION compute_hh_dot_products_real_gpu_double
#define M_compute_hh_trafo_real_cpu_openmp_PRECISSION compute_hh_trafo_real_cpu_openmp_double
#define M_compute_hh_trafo_real_cpu_PRECISSION compute_hh_trafo_real_cpu_double
#define M_pack_row_group_real_gpu_PRECISSION pack_row_group_real_gpu_double
#define M_pack_row_real_cpu_openmp_PRECISSION pack_row_real_cpu_openmp_double
#define M_pack_row_real_cpu_PRECISSION pack_row_real_cpu_double
#define M_wy_gen_PRECISSION wy_gen_double
#define M_wy_right_PRECISSION wy_right_double
#define M_wy_left_PRECISSION wy_left_double
#define M_wy_symm_PRECISSION wy_symm_double
#define M_merge_recursive_PRECISSION merge_recursive_double
#define M_merge_systems_PRECISSION merge_systems_double
#define M_distribute_global_column_PRECISSION distribute_global_column_double
#define M_check_monotony_PRECISSION check_monotony_double
#define M_global_gather_PRECISSION global_gather_double
#define M_resort_ev_PRECISSION resort_ev_double
#define M_transform_columns_PRECISSION transform_columns_double
#define M_solve_secular_equation_PRECISSION solve_secular_equation_double
#define M_global_product_PRECISSION global_product_double
#define M_add_tmp_PRECISSION add_tmp_double
#define M_v_add_s_PRECISSION v_add_s_double

#define M_PRECISSION_SYRK DSYRK
#define M_PRECISSION_TRMV DTRMV
#define M_PRECISSION_GEMM DGEMM
#define M_PRECISSION_GEMV DGEMV 
#define M_PRECISSION_TRMM DTRMM
#define M_PRECISSION_SYMV DSYMV
#define M_PRECISSION_SYMM DSYMM
#define M_PRECISSION_SYR2 DSYR2
#define M_PRECISSION_SYR2K DSYR2K
#define M_PRECISSION_GEQRF dgeqrf
#define M_PRECISSION_STEDC dstedc
#define M_PRECISSION_STEQR dsteqr
#define M_PRECISSION_LAMRG DLAMRG
#define M_PRECISSION_LAMCH DLAMCH
#define M_PRECISSION_LAPY2 DLAPY2
#define M_PRECISSION_LAED4 DLAED4
#define M_PRECISSION_LAED5 DLAED5

#define M_cublas_PRECISSION_gemm cublas_dgemm
#define M_cublas_PRECISSION_trmm cublas_dtrmm
#define M_cublas_PRECISSION_gemv cublas_dgemv

#define M_PRECISSION_SUFFIX "_double"
#define M_CONST_0_0 0.0_rk8
#define M_CONST_0_5 0.5_rk8
#define M_CONST_1_0 1.0_rk8
#define M_CONST_2_0 2.0_rk8
#define M_CONST_8_0 8.0_rk8
#define M_size_of_PRECISSION_real size_of_double_real_datatype
#define M_MPI_REAL_PRECISSION MPI_REAL8

#else

#undef M_elpa_transpose_vectors_real_PRECISSION
#undef M_elpa_reduce_add_vectors_real_PRECISSION

#undef M_bandred_real_PRECISSION
#undef M_trans_ev_band_to_full_real_PRECISSION
#undef M_tridiag_band_real_PRECISSION 
#undef M_trans_ev_tridi_to_band_real_PRECISSION
#undef M_band_band_real_PRECISSION
#undef M_tridiag_real_PRECISSION 
#undef M_trans_ev_real_PRECISSION
#undef M_solve_tridi_PRECISSION
#undef M_solve_tridi_col_PRECISSION
#undef M_solve_tridi_single_problem_PRECISSION 

#undef M_qr_pdgeqrf_2dcomm_PRECISSION
#undef M_hh_transform_real_PRECISSION
#undef M_symm_matrix_allreduce_PRECISSION
#undef M_redist_band_real_PRECISSION
#undef M_unpack_row_real_cpu_PRECISSION 
#undef M_unpack_row_real_cpu_openmp_PRECISSION 
#undef M_unpack_and_prepare_row_group_real_gpu_PRECISSION 
#undef M_extract_hh_tau_real_gpu_PRECISSION 
#undef M_compute_hh_dot_products_real_gpu_PRECISSION 
#undef M_compute_hh_trafo_real_cpu_openmp_PRECISSION 
#undef M_compute_hh_trafo_real_cpu_PRECISSION 
#undef M_pack_row_group_real_gpu_PRECISSION
#undef M_pack_row_real_cpu_openmp_PRECISSION 
#undef M_pack_row_real_cpu_PRECISSION
#undef M_wy_gen_PRECISSION 
#undef M_wy_right_PRECISSION
#undef M_wy_left_PRECISSION
#undef M_wy_symm_PRECISSION
#undef M_merge_recursive_PRECISSION
#undef M_merge_systems_PRECISSION
#undef M_distribute_global_column_PRECISSION 
#undef M_check_monotony_PRECISSION
#undef M_global_gather_PRECISSION 
#undef M_resort_ev_PRECISSION
#undef M_transform_columns_PRECISSION
#undef M_solve_secular_equation_PRECISSION 
#undef M_global_product_PRECISSION 
#undef M_add_tmp_PRECISSION
#undef M_v_add_s_PRECISSION

#undef M_PRECISSION_SYRK 
#undef M_PRECISSION_TRMV 
#undef M_PRECISSION_GEMM 
#undef M_PRECISSION_GEMV
#undef M_PRECISSION_TRMM 
#undef M_PRECISSION_SYMV 
#undef M_PRECISSION_SYMM 
#undef M_PRECISSION_SYR2
#undef M_PRECISSION_SYR2K
#undef M_PRECISSION_GEQRF
#undef M_PRECISSION_STEDC 
#undef M_PRECISSION_STEQR 
#undef M_PRECISSION_LAMRG
#undef M_PRECISSION_LAMCH
#undef M_PRECISSION_LAPY2
#undef M_PRECISSION_LAED4
#undef M_PRECISSION_LAED5

#undef M_cublas_PRECISSION_gemm
#undef M_cublas_PRECISSION_trmm 
#undef M_cublas_PRECISSION_gemv

#undef M_PRECISSION_SUFFIX
#undef M_CONST_0_0 
#undef M_CONST_0_5 
#undef M_CONST_1_0 
#undef M_CONST_2_0
#undef M_CONST_8_0
#undef M_size_of_PRECISSION_real
#undef M_MPI_REAL_PRECISSION

#define M_elpa_transpose_vectors_real_PRECISSION elpa_transpose_vectors_real_single
#define M_elpa_reduce_add_vectors_real_PRECISSION elpa_reduce_add_vectors_real_single

#define M_bandred_real_PRECISSION bandred_real_single
#define M_trans_ev_band_to_full_real_PRECISSION trans_ev_band_to_full_real_single
#define M_tridiag_band_real_PRECISSION tridiag_band_real_single
#define M_trans_ev_tridi_to_band_real_PRECISSION trans_ev_tridi_to_band_real_single
#define M_band_band_real_PRECISSION band_band_real_single
#define M_tridiag_real_PRECISSION tridiag_real_single
#define M_trans_ev_real_PRECISSION trans_ev_real_single
#define M_solve_tridi_PRECISSION solve_tridi_single
#define M_solve_tridi_col_PRECISSION solve_tridi_col_single
#define M_solve_tridi_single_problem_PRECISSION solve_tridi_single_problem_single

#define M_qr_pdgeqrf_2dcomm_PRECISSION qr_pdgeqrf_2dcomm_single
#define M_hh_transform_real_PRECISSION hh_transform_real_single
#define M_symm_matrix_allreduce_PRECISSION symm_matrix_allreduce_single
#define M_redist_band_real_PRECISSION redist_band_real_single
#define M_unpack_row_real_cpu_PRECISSION unpack_row_real_cpu_single
#define M_unpack_row_real_cpu_openmp_PRECISSION unpack_row_real_cpu_openmp_single
#define M_unpack_and_prepare_row_group_real_gpu_PRECISSION unpack_and_prepare_row_group_real_gpu_single
#define M_extract_hh_tau_real_gpu_PRECISSION extract_hh_tau_real_gpu_single
#define M_compute_hh_dot_products_real_gpu_PRECISSION compute_hh_dot_products_real_gpu_single
#define M_compute_hh_trafo_real_cpu_openmp_PRECISSION compute_hh_trafo_real_cpu_openmp_single
#define M_compute_hh_trafo_real_cpu_PRECISSION compute_hh_trafo_real_cpu_single
#define M_pack_row_group_real_gpu_PRECISSION pack_row_group_real_gpu_single
#define M_pack_row_real_cpu_openmp_PRECISSION pack_row_real_cpu_openmp_single
#define M_pack_row_real_cpu_PRECISSION pack_row_real_cpu_single
#define M_wy_gen_PRECISSION wy_gen_single
#define M_wy_right_PRECISSION wy_right_single
#define M_wy_left_PRECISSION wy_left_single
#define M_wy_symm_PRECISSION wy_symm_single
#define M_merge_recursive_PRECISSION merge_recursive_single
#define M_merge_systems_PRECISSION merge_systems_single
#define M_distribute_global_column_PRECISSION distribute_global_column_single
#define M_check_monotony_PRECISSION check_monotony_single
#define M_global_gather_PRECISSION global_gather_single
#define M_resort_ev_PRECISSION resort_ev_single
#define M_transform_columns_PRECISSION transform_columns_single
#define M_solve_secular_equation_PRECISSION solve_secular_equation_single
#define M_global_product_PRECISSION global_product_single
#define M_add_tmp_PRECISSION add_tmp_single
#define M_v_add_s_PRECISSION v_add_s_single

#define M_PRECISSION_SYRK SSYRK
#define M_PRECISSION_TRMV STRMV
#define M_PRECISSION_GEMM SGEMM
#define M_PRECISSION_GEMV SGEMV
#define M_PRECISSION_TRMM STRMM
#define M_PRECISSION_SYMV SSYMV
#define M_PRECISSION_SYMM SSYMM
#define M_PRECISSION_SYR2 SSYR2
#define M_PRECISSION_SYR2K SSYR2K
#define M_PRECISSION_GEQRF sgeqrf
#define M_PRECISSION_STEDC sstedc
#define M_PRECISSION_STEQR ssteqr
#define M_PRECISSION_LAMRG SLAMRG
#define M_PRECISSION_LAMCH SLAMCH
#define M_PRECISSION_LAPY2 SLAPY2
#define M_PRECISSION_LAED4 SLAED4
#define M_PRECISSION_LAED5 SLAED5

#define M_cublas_PRECISSION_gemm cublas_sgemm
#define M_cublas_PRECISSION_trmm cublas_strmm
#define M_cublas_PRECISSION_gemv cublas_sgemv

#define M_PRECISSION_SUFFIX "_single"
#define M_CONST_0_0 0.0_rk4
#define M_CONST_0_5 0.5_rk4
#define M_CONST_1_0 1.0_rk4
#define M_CONST_2_0 2.0_rk4
#define M_CONST_8_0 8.0_rk4
#define M_size_of_PRECISSION_real size_of_single_real_datatype
#define M_MPI_REAL_PRECISSION MPI_REAL4
#endif
