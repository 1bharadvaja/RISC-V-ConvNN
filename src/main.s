.import read_matrix.s
.import write_matrix.s
.import matmul.s
.import dot.s
.import relu.s
.import argmax.s
.import utils.s
.import classify.s

.globl main
#dummy fn to call main classify fn, lol
main:
    # initialize register a2 to zero
    mv a2, zero

    # call classify function
    jal classify

    # exit program normally
    li a0 0
    jal exit
