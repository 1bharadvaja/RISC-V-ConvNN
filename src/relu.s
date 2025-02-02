.globl relu

.text
# ===
# in place ReLU on array
# ===

relu:
    # Prologue
    
    # check if passed length is less than 1. if so, exit
    li t0, 1
    blt a1, t0, exception

    # initialize counter in a2
    li t1, 0

    # place int array pointer to another register to free a0
    mv t2, a0
    mv t3, a0

    j loop_start

loop_start:
    # break out the loop if counter = a2
    beq a1, t1, loop_end
    j loop_continue

loop_continue:
    # get arr[i]
    lw t4, 0(t3)

    # if t4 < 0: 
    blt t4, x0, zero_out

    sw t4, 0(t3)

    # increment index
    addi t3, t3, 4

    # increment counter
    addi t1, t1, 1
 
    j loop_start

zero_out:
    # arr[i] is negative, so store 0 @ index i
    sw x0, 0(t3)
    addi t3, t3, 4
    addi t1, t1, 1
    j loop_start

exception:
    li a0 36
    j exit

loop_end:

    # Epilogue


    jr ra
