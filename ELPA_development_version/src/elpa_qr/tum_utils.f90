module tum_utils
 
    implicit none

    PRIVATE

    public :: local_size_offset_1d
    public :: reverse_vector_local
    public :: reverse_matrix_local
    public :: reverse_matrix_1dcomm
    public :: reverse_matrix_2dcomm_ref

    public :: tsqr_groups_size
    public :: tsqr_groups_initialize
    public :: tsqr_groups_finalize

contains

! rev parameter is critical, even in rev only mode!
! pdgeqrf_2dcomm uses rev=0 version to determine the process columns 
! involved in the qr decomposition
subroutine local_size_offset_1d(n,nb,baseidx,idx,rev,rank,nprocs, &
                                lsize,baseoffset,offset)
    use ELPA1

    implicit none

    ! input
    integer n,nb,baseidx,idx,rev,rank,nprocs

    ! output
    integer lsize,baseoffset,offset

    ! local scalars
    integer rank_idx

    rank_idx = MOD((idx-1)/nb,nprocs)

    ! calculate local size and offsets
    if (rev .eq. 1) then
        if (idx > 0) then
            lsize = local_index(idx,rank,nprocs,nb,-1)
        else 
            lsize = 0
        end if

        baseoffset = 1
        offset = 1
    else
        offset = local_index(idx,rank,nprocs,nb,1)
        baseoffset = local_index(baseidx,rank,nprocs,nb,1)

        lsize = local_index(n,rank,nprocs,nb,-1)
        !print *,'baseidx,idx',baseidx,idx,lsize,n

        lsize = lsize - offset + 1
 
        baseoffset = offset - baseoffset + 1
    end if

end subroutine


subroutine reverse_vector_local(n,x,incx,work,lwork)
    implicit none

    ! input
    integer incx,n,lwork
    double precision x(*),work(*)

    ! local scalars
    double precision temp
    integer srcoffset,destoffset,ientry

    if (lwork .eq. -1) then
        work(1) = 0.0d0
        return
    end if
    
    do ientry=1,n/2
        srcoffset=1+(ientry-1)*incx
        destoffset=1+(n-ientry)*incx
        
        temp = x(srcoffset)
        x(srcoffset) = x(destoffset)
        x(destoffset) = temp
    end do

end subroutine

subroutine reverse_matrix_local(trans,m,n,a,lda,work,lwork)
    implicit none

    ! input
    integer lda,m,n,lwork,trans
    double precision a(lda,*),work(*)

    ! local scalars
    double precision temp,dworksize(1)
    integer srcoffset,destoffset,ientry
    integer incx
    integer dimsize
    integer i

    if (trans .eq. 1) then
        incx = lda
        dimsize = n
    else
        incx = 1
        dimsize = m
    end if

    if (lwork .eq. -1) then
        call reverse_vector_local(dimsize,a,incx,dworksize,-1)
        work(1) = dworksize(1)
        return
    end if

    if (trans .eq. 1) then
        do i=1,m
            call reverse_vector_local(dimsize,a(i,1),incx,work,lwork)
        end do
    else
        do i=1,n
            call reverse_vector_local(dimsize,a(1,i),incx,work,lwork)
        end do
    end if
    
end subroutine

subroutine reverse_matrix_2dcomm_ref(m,n,mb,nb,a,lda,work,lwork,mpicomm_cols,mpicomm_rows)
    implicit none

    ! input
    integer m,n,lda,lwork,mpicomm_cols,mpicomm_rows,mb,nb
    double precision a(lda,*),work(*)

    ! local scalars
    double precision reverse_column_size(1)
    double precision reverse_row_size(1)

    integer mpirank_cols,mpirank_rows
    integer mpiprocs_cols,mpiprocs_rows
    integer mpierr
    integer lrows,lcols,offset,baseoffset

    call MPI_Comm_rank(mpicomm_cols,mpirank_cols,mpierr)
    call MPI_Comm_rank(mpicomm_rows,mpirank_rows,mpierr)
    call MPI_Comm_size(mpicomm_cols,mpiprocs_cols,mpierr)
    call MPI_Comm_size(mpicomm_rows,mpiprocs_rows,mpierr)
 
    call local_size_offset_1d(m,mb,1,1,0,mpirank_cols,mpiprocs_cols, &
                                  lrows,baseoffset,offset)
  
    call local_size_offset_1d(n,nb,1,1,0,mpirank_rows,mpiprocs_rows, &
                                  lcols,baseoffset,offset)
 
    if (lwork .eq. -1) then
        call reverse_matrix_1dcomm(0,m,lcols,mb,a,lda,reverse_column_size,-1,mpicomm_cols)
        call reverse_matrix_1dcomm(1,lrows,n,nb,a,lda,reverse_row_size,-1,mpicomm_rows)
        work(1) = max(reverse_column_size(1),reverse_row_size(1))
        return
    end if
 
    call reverse_matrix_1dcomm(0,m,lcols,mb,a,lda,work,lwork,mpicomm_cols)
    call reverse_matrix_1dcomm(1,lrows,n,nb,a,lda,work,lwork,mpicomm_rows)
end subroutine

! b: if trans = 'N': b is size of block distribution between rows
! b: if trans = 'T': b is size of block distribution between columns
subroutine reverse_matrix_1dcomm(trans,m,n,b,a,lda,work,lwork,mpicomm)
    use mpi

    implicit none

    ! input
    integer trans
    integer m,n,b,lda,lwork,mpicomm
    double precision a(lda,*),work(*)

    ! local scalars
    integer mpirank,mpiprocs,mpierr,mpistatus(MPI_STATUS_SIZE)
    integer nr_blocks,dest_process,src_process,step
    integer src_block,dest_block
    integer lsize,baseoffset,offset
    integer current_index,destblk,srcblk,icol,next_index
    integer sendcount,recvcount
    integer sendoffset,recvoffset
    integer newmatrix_offset,work_offset
    integer lcols,lrows,lroffset,lcoffset,dimsize,fixedsize
    double precision dworksize(1)

    call MPI_Comm_rank(mpicomm, mpirank, mpierr)
    call MPI_Comm_size(mpicomm, mpiprocs, mpierr)
  
    if (trans .eq. 1) then
        call local_size_offset_1d(n,b,1,1,0,mpirank,mpiprocs, &
                                  lcols,baseoffset,lcoffset)
        lrows = m
    else
        call local_size_offset_1d(m,b,1,1,0,mpirank,mpiprocs, &
                                  lrows,baseoffset,lroffset)
        lcols = n
    end if
                          
    if (lwork .eq. -1) then
        call reverse_matrix_local(trans,lrows,lcols,a,max(lrows,lcols),dworksize,-1)
        work(1) = DBLE(3*lrows*lcols) + dworksize(1)
        return
    end if

    sendoffset = 1
    recvoffset = sendoffset + lrows*lcols
    newmatrix_offset = recvoffset + lrows*lcols
    work_offset = newmatrix_offset + lrows*lcols

    if (trans .eq. 1) then
        dimsize = n
        fixedsize = m
    else
        dimsize = m
        fixedsize = n
    end if

    if (dimsize .le. 1) then
        return ! nothing to do
    end if
 
    ! 1. adjust step size to remainder size
    nr_blocks = dimsize / b
    nr_blocks = nr_blocks * b
    step = dimsize - nr_blocks
    if (step .eq. 0) step = b

    ! 2. iterate over destination blocks starting with process 0
    current_index = 1
    do while (current_index .le. dimsize)
        destblk = (current_index-1) / b
        dest_process = mod(destblk,mpiprocs)
        srcblk = (dimsize-current_index) / b
        src_process = mod(srcblk,mpiprocs)

        next_index = current_index+step

        ! block for dest_process is located on mpirank if lsize > 0
        call local_size_offset_1d(dimsize-current_index+1,b,dimsize-next_index+2,dimsize-next_index+2,0, &
                                  src_process,mpiprocs,lsize,baseoffset,offset)

        sendcount = lsize*fixedsize
        recvcount = sendcount

        ! TODO: this send/recv stuff seems to blow up on BlueGene/P 
        ! TODO: is there actually room for the requested matrix part? the target
        ! process might not have any parts at all (thus no room)
        if ((src_process .eq. mpirank) .and. (dest_process .eq. src_process)) then
                ! 5. pack data
                if (trans .eq. 1) then
                    do icol=offset,offset+lsize-1
                        work(sendoffset+(icol-offset)*lrows:sendoffset+(icol-offset+1)*lrows-1) = &
                            a(1:lrows,icol)
                    end do
                else
                    do icol=1,lcols
                        work(sendoffset+(icol-1)*lsize:sendoffset+icol*lsize-1) = &
                            a(offset:offset+lsize-1,icol)
                    end do
                end if
 
                ! 7. reverse data
                if (trans .eq. 1) then
                    call reverse_matrix_local(1,lrows,lsize,work(sendoffset),lrows,work(work_offset),lwork)
                else
                    call reverse_matrix_local(0,lsize,lcols,work(sendoffset),lsize,work(work_offset),lwork)
                end if

                ! 8. store in temp matrix
                if (trans .eq. 1) then
                    do icol=1,lsize
                        work(newmatrix_offset+(icol-1)*lrows:newmatrix_offset+icol*lrows-1) = &
                            work(sendoffset+(icol-1)*lrows:sendoffset+icol*lrows-1)
                    end do

                    newmatrix_offset = newmatrix_offset + lsize*lrows
                else
                    do icol=1,lcols
                        work(newmatrix_offset+(icol-1)*lrows:newmatrix_offset+(icol-1)*lrows+lsize-1) = &
                            work(sendoffset+(icol-1)*lsize:sendoffset+icol*lsize-1)
                    end do

                    newmatrix_offset = newmatrix_offset + lsize
                end if
        else

            if (dest_process .eq. mpirank) then
                ! 6b. call MPI_Recv
                call MPI_Recv(work(recvoffset), recvcount, mpi_real8, &
                              src_process, current_index, mpicomm, mpistatus, mpierr)

                ! 7. reverse data
                if (trans .eq. 1) then
                    call reverse_matrix_local(1,lrows,lsize,work(recvoffset),lrows,work(work_offset),lwork)
                else
                    call reverse_matrix_local(0,lsize,lcols,work(recvoffset),lsize,work(work_offset),lwork)
                end if

                ! 8. store in temp matrix
                if (trans .eq. 1) then
                    do icol=1,lsize
                        work(newmatrix_offset+(icol-1)*lrows:newmatrix_offset+icol*lrows-1) = &
                            work(recvoffset+(icol-1)*lrows:recvoffset+icol*lrows-1)
                    end do

                    newmatrix_offset = newmatrix_offset + lsize*lrows
                else
                    do icol=1,lcols
                        work(newmatrix_offset+(icol-1)*lrows:newmatrix_offset+(icol-1)*lrows+lsize-1) = &
                            work(recvoffset+(icol-1)*lsize:recvoffset+icol*lsize-1)
                    end do

                    newmatrix_offset = newmatrix_offset + lsize
                end if
            end if

            if (src_process .eq. mpirank) then
                ! 5. pack data
                if (trans .eq. 1) then
                    do icol=offset,offset+lsize-1
                        work(sendoffset+(icol-offset)*lrows:sendoffset+(icol-offset+1)*lrows-1) = &
                            a(1:lrows,icol)
                    end do
                else
                    do icol=1,lcols
                        work(sendoffset+(icol-1)*lsize:sendoffset+icol*lsize-1) = &
                            a(offset:offset+lsize-1,icol)
                    end do
                end if

                ! 6a. call MPI_Send
                call MPI_Send(work(sendoffset), sendcount, mpi_real8, &
                                  dest_process, current_index, mpicomm, mpierr)
            end if
        end if

        current_index = next_index
    end do

   ! 9. copy temp matrix to real matrix
   newmatrix_offset = recvoffset + lrows*lcols
   do icol=1,lcols
        a(1:lrows,icol) = &
            work(newmatrix_offset+(icol-1)*lrows:newmatrix_offset+icol*lrows-1)
   end do
end subroutine

integer function tsqr_groups_size(comm,treeorder)
    use mpi

    implicit none

    ! input
    integer comm,treeorder

    ! local scalars
    integer mpiprocs,mpierr
    integer nr_groups,depth,treeprocs

    call MPI_Comm_size(comm,mpiprocs,mpierr)

    ! integer logarithm with base treeorder
    depth=1
    treeprocs=treeorder
    do while(treeprocs .lt. mpiprocs)
        treeprocs = treeprocs * treeorder
        depth = depth + 1
    end do

    tsqr_groups_size = nr_groups

end function

subroutine tsqr_groups_initialize(comm,treeorder,groups)
    use mpi
 
    implicit none

    ! input
    integer comm,treeorder

    ! output
    integer, allocatable :: groups(:)

    ! local scalars
    integer nr_groups,igroup,mpierr,mpirank
    integer split_color,split_key
    integer prev_treeorder,temp_treeorder

    nr_groups = tsqr_groups_size(comm,treeorder)
    allocate(groups(nr_groups))

    groups(1) = comm

    call MPI_Comm_rank(comm,mpirank,mpierr)
 
    prev_treeorder = 1
    temp_treeorder = treeorder
    do igroup=2,nr_groups
        if (mod(mpirank,prev_treeorder) .eq. 0) then
            split_color=mpirank / temp_treeorder
            split_key=mod(mpirank / prev_treeorder,treeorder)
        else
            split_color = MPI_UNDEFINED
            split_key = 0 ! ignored due to MPI_UNDEFINED color
        end if

        call MPI_Comm_split(comm,split_color,split_key,groups(igroup),mpierr)

        prev_treeorder = temp_treeorder
        temp_treeorder = temp_treeorder * treeorder
    end do

end subroutine

subroutine tsqr_groups_finalize(groups,treeorder)
    use mpi
 
    implicit none

    ! input
    integer, allocatable :: groups(:)
    integer treeorder

    ! local scalars
    integer nr_groups,igroup,mpierr

    nr_groups = tsqr_groups_size(groups(1),treeorder)

    do igroup=2,nr_groups
       call MPI_Comm_free(groups(igroup),mpierr)
    end do

    deallocate(groups)
end subroutine

end module
