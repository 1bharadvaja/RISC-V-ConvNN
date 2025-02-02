.globl write_matrix

.text



write_matrix:

    # Prologue
    
    addi sp sp -28
    sw ra 0(sp)
    sw s0 4(sp)                     # s0: file ptr
    sw s1 8(sp)                     # s1: matrix ptr
    sw s2 12(sp)                    # s2: counter
    sw s3 16(sp)                    # s3: num_elements

    mul t0 a2 a3
    mv s3 t0

    sw a2 20(sp)                    # save num_rows
    sw a3 24(sp)                    # save num_cols
    
    mv s1 a1

    # open the file
    li a1 1
    jal ra fopen
    #ebreak
    li t0 -1
    beq a0 t0 fopen_err
    mv s0 a0                        # save file ptr

    # write num_rows
    mv a0 s0
    addi a1 sp 20
    li a2 1
    li a3 4
    jal ra fwrite
    li t0 1
    bne a0 t0 fwrite_err

    # write num_cols
    mv a0 s0
    addi a1 sp 24
    li a2 1
    li a3 4
    jal ra fwrite
    li t0 1
    bne a0 t0 fwrite_err

    # write matrix
    mv a0 s0
    mv a1 s1
    mv a2 s3
    li a3 4
    jal ra fwrite
    bne a0 s3 fwrite_err
    #ebreak

    # close file
    mv a0 s0
    jal ra fclose
    li t0 -1
    beq a0 t0 fclose_err

    # Epilogue
    lw ra 0(sp)
    lw s0 4(sp)
    lw s1 8(sp)
    lw s2 12(sp)
    lw s3 16(sp)
    addi sp sp 28

    jr ra

fopen_err:
    li a0 27
    j exit

fwrite_err:
    li a0 30
    j exit
fclose_err:
    li a0 28
    j exit
