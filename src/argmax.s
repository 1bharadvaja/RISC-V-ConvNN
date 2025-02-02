.globl argmax
.text

# ===========
# given an in array, return index of the largest element
# a0 is an int pointer to the start of the array
# a1 is the number of elements in the array
# returns a0, first index of the largest element
# ===========


argmax:
    # Prologue
    li t0 1
    blt a1, t0, exception
    # index of current max
    li t1 0
    # index counter 
    li t2 0
    # pointer to current index
    mv t3 a0
    # current max
    lw t4 0(a0)
    j loop_start
    
loop_start:
    beq t2, a1, loop_end
    j loop_continue

loop_continue:
    # get arr[i]
    lw t5 0(t3)
    # if arr[i] > curr_max: 
    bge t5 t4, if_greater_than
    # else: 
    j if_less_than_or_eq

loop_end:
    # Epilogue
    mv a0 t1
    jr ra

exception:
    li a0 36
    j exit

if_greater_than:
    beq t5, t4, if_less_than_or_eq
    mv t1 t2
    lw t4 0(t3)
    addi t2 t2 1
    addi t3 t3 4

    j loop_start


if_less_than_or_eq:
    addi t2 t2 1
    addi t3 t3 4
    j loop_start
