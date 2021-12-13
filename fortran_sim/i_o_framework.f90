module io_manager
    use vectors
    implicit none

    character(len = 1) :: path_sep = '/'

contains
    subroutine prettyprint_real(mat, n)
        real(rk), dimension(n, n), intent(in) :: mat
        integer(ik), intent(in) :: n
        integer(ik) :: i

        do i = 1, n
            write(6, *) mat(i, :)
        end do
        write(6, *) ""
    end subroutine prettyprint_real

    subroutine prettyprint_vec_mat(vecs, n)
        type(vec), dimension(n, n), intent(in) :: vecs
        integer(ik), intent(in) :: n
        integer(ik) :: i, j

        do i = 1, n
            do j = 1, n
                write(6, *) i, j, ': (', vecs(i, j)%x, vecs(i, j)%y, vecs(i, j)%z, ')'
            end do
        end do
        write(6, *) ""
    end subroutine prettyprint_vec_mat

    subroutine prettyprint_vec_arr(vecs, n)
        type(vec), dimension(n), intent(in) :: vecs
        integer(ik), intent(in) :: n
        integer(ik) :: i

        do i = 1, n
            write(6, *) i, ': (', vecs(i)%x, vecs(i)%y, vecs(i)%z, ')'
        end do
        write(6, *) ""
    end subroutine prettyprint_vec_arr

    subroutine prettyprint_vec_single(a)
        type(vec), intent(in) :: a

        write(6, *) '(', a%x, a%y, a%z, ')'
        write(6, *) ""
    end subroutine prettyprint_vec_single

    subroutine export_all_sim_results(lpos, lvel, lacc, lforces, nbody, nstep, savestep)
        type(vec), dimension(nbody, nstep), intent(in) :: lpos, lvel, lacc, lforces
        integer(ik), intent(in) :: nbody, nstep, savestep
        integer(ik) :: i, j, t, ios
        character(len = 100) :: dirname
        character(len = 120) :: cmd, saveloc

        dirname = prepare_subdir()

        do i = 1, nbody
            write(saveloc, '(a, a, a, i0, a)') trim(dirname), path_sep, 'body_', i, '.txt'
            write(6, *) saveloc
            open(12, file = saveloc, iostat = ios, action = 'write', status = 'new')
            if (ios /= 0) then
                write(6, '(a, a, a, i0)') 'Error while handling ', saveloc, ' Errorcode: ', ios
                stop
            end if
            do j = 1, nstep, savestep
                write(12, *) lpos(i, j), lvel(i, j), lacc(i, j), lforces(i, j)
            end do
            close(12)
        end do
    end subroutine export_all_sim_results

    function prepare_subdir() result(dirpath)
        character(len = 200) :: dirpath, cmd
        integer(ik) :: t

        t = time()
        write(dirpath, '(a, a, i0)') 'data', path_sep, t
        write(cmd, '(a, a)') 'mkdir ', trim(dirpath)
        call system(cmd)
        write(6, *) 'Created save directory: ', trim(dirpath)
    end function prepare_subdir

    subroutine save_sim_step(last_pos, last_vel, last_acc, last_forces, nbody, subdir_path)
        character(len = 100), intent(in) :: subdir_path
        character(len = 200) :: saveloc
        type(vec), dimension(nbody), intent(in) :: last_pos, last_vel, last_acc, last_forces
        integer(ik), intent(in) :: nbody
        integer(ik) :: i, j, t, ios
        logical :: fstat

        do i = 1, nbody
            write(saveloc, '(a, a, a, i0, a)') trim(subdir_path), path_sep, 'body_', i, '.txt'
            inquire(file = saveloc, exist = fstat)
            if (fstat) then
                open(1, file = saveloc, iostat = ios, action = 'write', status = 'old', position = 'append')
            else
                open(1, file = saveloc, iostat = ios, action = 'write', status = 'new')
            end if
            write(1, *) last_pos(i), last_vel(i), last_acc(i), last_forces(i)
            close(1)
        end do
    end subroutine save_sim_step

    subroutine print_sim_info(last_pos, nbody, nstep, cstep, dt, savestep)
        type(vec), dimension(nbody), intent(in) :: last_pos
        integer(ik), intent(in) :: nbody, nstep, cstep, savestep
        real(rk), intent(in) :: dt

        write(6, '(a, i0, a, i0, a, i0)') 'INFO AT STEP ', cstep, ' / ', nstep, '. Simulation time: Day ', nint(cstep*dt / 86400)
        write(6, '(a, i0, a)') 'Simulating ', nbody, ' objects.'
        write(6, '(a, i0, a)') 'Saved ', cstep/savestep, ' steps to file.'
        write(6, *) 'Current object positions: '
        call prettyprint_vec_arr(last_pos, nbody)
        ! write(6, *) '---------------------------------------------------'

    end subroutine print_sim_info
end module io_manager