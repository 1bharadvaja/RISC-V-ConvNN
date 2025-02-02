.globl classify

.text
# arguments:
#   a0 (int)        argc
#   a1 (char**)     argv
#   a1[1] (char*)   pointer to the filepath string of m0
#   a1[2] (char*)   pointer to the filepath string of m1
#   a1[3] (char*)   pointer to the filepath string of input matrix
#   a1[4] (char*)   pointer to the filepath string of output
#   a2 (int)        silent mode, don't print anything is this is 1
# Returns:
#   a0 (int)        Classification
# Exceptions:
#   - If there are an incorrect number of command line args,
#     this function terminates the program with exit code 31
#   - If malloc fails, this function terminates the program with exit code 26
#
# Usage:
#   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>
classify:
    #ebreak
    li t0 4
    blt a0 t0 incorrect_args

    addi sp sp -112
    sw ra 0(sp)
    sw s0 4(sp)
    sw s1 8(sp)
    sw s2 12(sp)
    sw s3 16(sp)
    sw s4 20(sp)
    sw s5 24(sp)
    sw s6 28(sp)
    sw s7 32(sp)

    #ebreak

    mv s2 a1
    mv s7 a2
    
    # Read pretrained m0
    
    ## malloc pointer to num_rows of m0
    li a0 4
    jal ra malloc
    #ebreak
    beq a0 x0 malloc_err
    mv s0 a0
    sw a0 80(sp)

    ## malloc pointer to num_cols of m0
    li a0 4
    jal ra malloc
    beq a0 x0 malloc_err
    #ebreak
    mv s1 a0
    sw a0 84(sp)
    
    ### at this point, s0 and s1 contain pointers to num_rows and num_cols vals respectively.
    addi a0 s2 4
    lw a0 0(a0)
    mv a1 s0
    mv a2 s1
    jal ra read_matrix
    #ebreak
    sw a0 36(sp)            # store m0 at sp + 36
    lw t0 0(s0)
    sw t0 40(sp) #num rows m0
    lw t0 0(s1)
    sw t0 44(sp) #num cols m0

    # Read pretrained m1
    li a0 4
    jal ra malloc
    beq a0 x0 malloc_err
    #ebreak
    sw a0 88(sp)
    mv s0 a0
    li a0 4
    jal ra malloc
    beq a0 x0 malloc_err
    sw a0 92(sp)
    #ebreak
    mv s1 a0

    addi a0 s2 8
    lw a0 0(a0)
    mv a1 s0
    mv a2 s1
    jal ra read_matrix
    #ebreak
    sw a0 48(sp) #m1
    lw t0 0(s0)
    sw t0 52(sp) #num rows m1
    lw t0 0(s1)
    sw t0 56(sp) #num cols m1
    
    # Read input matrix
    li a0 4
    jal ra malloc
    beq a0 x0 malloc_err
    sw a0 96(sp)
    #ebreak

    mv s0 a0
    li a0 4
    jal ra malloc
    beq a0 x0 malloc_err
    sw a0 100(sp)
   # ebreak
    mv s1 a0

    addi a0 s2 12
    lw a0 0(a0)
    mv a1 s0
    mv a2 s1
    jal ra read_matrix
    #ebreak
    sw a0 60(sp) #input
    lw t0 0(s0)
    sw t0 64(sp) #num rows input
    lw t0 0(s1)
    sw t0 68(sp) #num cols input

    # Compute h = matmul(m0, input)
    #malloc space for h (num_rows of m0 * num_cols of input * 4 bytes per int)

   # ebreak
    
    lw t0 40(sp)
    lw t1 68(sp)
    mul t0 t0 t1        
    sw t0 72(sp)        # num_rows(m0) * num_cols(input)
    li t1 4             # size(h)
    mul a0 t0 t1
    jal ra malloc
    beq a0 x0 malloc_err
    sw a0 104(sp)
    #ebreak
    mv a6 a0

    sw a0 76(sp)        # ptr -> h matrix    

    lw a0 36(sp)
    lw a1 40(sp)
    lw a2 44(sp)
    lw a3 60(sp)
    lw a4 64(sp)
    lw a5 68(sp)
    #ebreak

    jal ra matmul
    #ebreak

    # Compute h = relu(h)
    lw a0 76(sp)
    lw a1 72(sp)
    jal ra relu
    #ebreak


    # Compute o = matmul(m1, h)
    # a0: ptr to m1
    # a1: num_rows(m1)
    # a2: num_cols(m1)
    # a3: ptr to h
    # a4: num_rows(h)
    # a5: num_cols(h)
    # a6: ptr to o


    #malloc space for o
    # dim(o) = num_rows(m1) x num_cols(input)
    lw t0 52(sp)    # num_rows(o)
    lw t1 68(sp)    # num_cols(o)
    li t2 4
    mul t0 t0 t1
    mul t0 t0 t2
    mv a0 t0
    jal ra malloc
    beq a0 x0 malloc_err
    sw a0 108(sp)
    #ebreak
    mv s0 a0        # ptr -> o

    lw a0 48(sp) #a0 = m1
    lw a1 52(sp)
    lw a2 56(sp)
    lw a3 76(sp) #moves relu result into a3
    lw a4 40(sp)
    lw a5 68(sp)
    mv a6 s0
    
    jal ra matmul
    #ebreak

    # Write output matrix o

    addi a0 s2 16
    lw a0 0(a0)
    mv a1 s0
    lw a2 52(sp)
    lw a3 68(sp)
    mul s1 a2 a3
    
    jal ra write_matrix
    #ebreak

    # Compute and return argmax(o)
    mv a0 s0
    mv a1 s1

    jal ra argmax
    mv s5 a0

    # free memory
    lw a0 36(sp)
    jal ra free
    lw a0 48(sp)
    jal ra free
    lw a0 60(sp)
    jal ra free
    lw a0 80(sp)
    jal ra free
    lw a0 84(sp)
    jal ra free
    lw a0 88(sp)
    jal ra free
    lw a0 92(sp)
    jal ra free
    lw a0 96(sp)
    jal ra free
    lw a0 100(sp)
    jal ra free
    lw a0 104(sp)
    jal ra free
    lw a0 108(sp)
    jal ra free

    # If enabled, print argmax(o) and newline
    beq s7 x0 print_argmax



    j epilogue
print_argmax:
    mv a0 s5
    jal ra print_int
    li a0 '\n'
    jal ra print_char
    j epilogue


epilogue:
    mv a0 s5

    lw ra 0(sp)
    lw s0 4(sp)
    lw s1 8(sp)
    lw s2 12(sp)
    lw s3 16(sp)
    lw s4 20(sp)
    lw s5 24(sp)
    lw s6 28(sp)
    lw s7 32(sp)
    addi sp sp 112
    

    jr ra

malloc_err:
    # free memory
    li a0 26
    j exit

incorrect_args:
    li a0 31
    j exit
