.globl dot

.text
#returns a0 as the dot product of 2 arrays
#input a0, a1 as the ptr to the start of arr0 and arr1, a2 is the number of elements to use
#a3, a4 are arr0 and arr1 respective strides


dot:

    # Prologue
    mv t5 x0
    addi t5 t5 1
    blt a2 t5 exception1
    blt a3 t5 exception2
    blt a4 t5 exception2

    mv a5 a0    # arr0 pointer
    mv a6 a1    # arr1 pointer

    mv t6 x0    # dot product result

    mv t0 x0    # offset i
    mv t1 x0    # offset j
    mv t2 x0    # curr_num_elements

loop_start:
    beq t2 a2 loop_end
    j loop_continue

loop_continue:
    lw t3 0(a0)    # get arr0[i]
    lw t4 0(a1)    # get arr1[j]

    mul t3 t3 t4    # arr0[i] * arr1[j]
    add t6 t6 t3

    addi t2 t2 1    # increment counter

    mul t0 t2 a3   # i = counter * stride1
    mul t1 t2 a4    # j = counter * stride2

    mv t5 x0
    addi t5 t5 4

    mul t3 t0 t5    # offset1 = i * 4
    mul t4 t1 t5     # offset_2 = j * 4
    
    add a0 a5 t3    # add offset to arr0 start
    add a1 a6 t4    # add offset to arr1 start

    j loop_start


loop_end:

    # Epilogue
    mv a0 t6
    jr ra

exception1:
    li a0 36
    j exit

exception2:
    li a0 37
    j exit
