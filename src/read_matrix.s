.globl read_matrix

.text
# ===
#returns a pointer starting at the matrix given the filepath in a0. a1 and a2 are num rows and num cols
# ===

read_matrix:
    # Prologue
    #jal ra, randomizeCalleeSavedRegs     # put values in saved registers

    addi sp sp -32
    sw ra 0(sp)                     # store return address
    sw s0 4(sp)                     # s0 : file descriptor
    sw s1 8(sp)                     # s1 : ptr to num_rows
    sw s2 12(sp)                    # s2 : ptr to num_cols
    sw s3 16(sp)                    # s3 : ptr to matrix (for return)
    sw s4 20(sp)                    # s4 : ptr to matrix (for iteration))
    sw s5 24(sp)                    # s5 : reading loop counter
    sw s6 28(sp)                    # s6 : number of matrix elements

    mv s1 a1
    mv s2 a2

    # open file
    li a1 0
    jal ra fopen
    #jal ra randomizeCallerSavedRegsBesidesA0

    li t3 -1
    beq a0 t3 fopen_eof_error
    mv s0 a0

    # read num_rows
    mv a0 s0
    mv a1 s1
    li a2 4
    jal ra fread
    #jal ra randomizeCallerSavedRegsBesidesA0

    li t3 4
    bne a0 t3 fread_eof_error

    # read num_cols
    mv a0 s0
    mv a1 s2
    li a2 4
    jal ra fread
    #jal ra randomizeCallerSavedRegsBesidesA0

    li t3 4
    bne a0 t3 fread_eof_error

    # allocate heap space for matrix
    li a0 4
    lw t1 0(s1)
    lw t2 0(s2)
    mul s6 t1 t2                # calculate num_elements and save total number of elements
    mul a0 s6 a0

    #addi sp sp -4
    #sw ra 0(sp)

    jal ra malloc

    
    #jal ra randomizeCallerSavedRegsBesidesA0
    beq a0 x0 malloc_error
    mv s3 a0                    # save ptr to return
    mv s4 a0                    # save ptr to iterate
    li s5 0                     # init counter

    j read_loop_start

read_loop_start:
    beq s6 s5 read_loop_end
    j read_loop_continue

read_loop_continue:
    mv a0 s0
    mv a1 s4
    li a2 4
    jal ra fread
    #jal ra randomizeCallerSavedRegsBesidesA0
    li t0 4
    bne a0 t0 fread_eof_error

    addi s4 s4 4                   # increment iterator pointer
    addi s5 s5 1                   # increment counter

    j read_loop_start

read_loop_end:
    # close file
    mv a0 s0
    jal ra fclose
    #jal ra randomizeCallerSavedRegsBesidesA0

    li t0 -1
    beq a0 t0 fclose_eof_error

    mv a0 s3

    # Epilogue
    lw ra 0(sp)
    lw s0 4(sp)
    lw s1 8(sp)
    lw s2 12(sp)
    lw s3 16(sp)
    lw s4 20(sp)
    lw s5 24(sp)
    lw s6 28(sp)
    addi sp sp 32
   # jal ra, checkCalleeSavedRegs    
    jr ra

malloc_error:
    li a0 26
    j exit

fopen_eof_error:
    li a0 27
    j exit

fclose_eof_error:
    li a0 28
    j exit

fread_eof_error:
    li a0 29
    j exit
