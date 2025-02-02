.globl matmul

.text
#a0, a3 are pointers to the matrices we want to multiply, output stored starting at a6
#a1, a4 are num rows in a0 and a3
#a2, a5 are num cols in a0 and a3
#obv, output matrix dimensions are alr given bc a1 and a5
matmul:

    # Error checks
    li t0 1
    blt a1 t0 exception
    blt a2 t0 exception
    blt a4 t0 exception
    blt a5 t0 exception
    bne a2 a4 exception

    # Prologue

    addi sp sp -40  # allocate stack space

    # save s registers on stack
    sw s0 0(sp)
    sw s1 4(sp)
    sw s2 8(sp)
    sw s3 12(sp)
    sw s4 16(sp)
    sw s5 20(sp)
    sw s6 24(sp)
    sw s7 28(sp)
    sw a3 32(sp)
    sw ra 36(sp)



    mv s0 a0    # row pointer
    mv s1 a3    # column pointer
    mv s2 a2    # num_elements (given by num_cols(m0) = num_rows(m1))

    mv s3 a5    # store num_cols(m1) to use as the stride

    li s4 0     # row counter
    
    li s5 0     # col counter

    mv s6 a1    # num_rows(m0)

    mv s7 a6    # save address of result matrix

    #sw x0 0(s7)

outer_loop_start:
    beq s6 s4 outer_loop_end        # exit outer loop if row_counter = num_rows(m0)
    sw x0 0(s7)                     # initialize dot product at the new address

    j inner_loop_start


inner_loop_start:
    beq s5 s3 outer_loop_continue      # exit inner loop if col_counter = num_cols(m1)

    j inner_loop_end


inner_loop_end:

    mv a0 s0
    mv a1 s1

    mv a2 s2        # copy num_elements to a2

    li a3 1         # store stride of arr0

    mv a4 s3        # copy stride of arr1

    jal ra dot
    #jal ra, randomizeCallerSavedRegsBesidesA0 

    #lw t2 0(s7)     # read the value at the at the address of the result matrix
    #add t2 t2 a0    # add the current dot product
    add t2 x0 a0

    sw t2 0(s7)     # store updated dot product
    addi s7 s7 4    # increment pointer to result matrix

    addi s1 s1 4        # increment col ptr to m1 by 1.

    addi s5 s5 1        # increment col_counter


    j inner_loop_start

outer_loop_continue:
    addi s4 s4 1    # increment row counter

    mv s5 x0        # reset col counter to 0
    lw s1 32(sp)    # reset column pointer to m1


    # increment row ptr to m0 by 4 * (m0 row length)).
    li t0 4
    mul t0 s2 t0
    add s0 s0 t0


    j outer_loop_start


outer_loop_end:

    # Epilogue
    #lw t0 32(sp)

    lw s0 0(sp) 
    lw s1 4(sp) 
    lw s2 8(sp) 
    lw s3 12(sp)
    lw s4 16(sp)
    lw s5 20(sp) 
    lw s6 24(sp)
    lw s7 28(sp)
    lw ra 36(sp)

    addi sp sp 40

    jr ra

exception:

    li a0 38
    j exit
