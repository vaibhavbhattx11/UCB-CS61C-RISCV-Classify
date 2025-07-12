.globl classify

.text
classify:
    # =====================================
    # COMMAND LINE ARGUMENTS
    # =====================================
    # Args:
    #   a0 (int)    argc
    #   a1 (char**) argv
    #   a2 (int)    print_classification, if this is zero, 
    #               you should print the classification. Otherwise,
    #               this function should not print ANYTHING.
    # Returns:
    #   a0 (int)    Classification
    # Exceptions:
    # - If there are an incorrect number of command line args,
    #   this function terminates the program with exit code 89.
    # - If malloc fails, this function terminats the program with exit code 88.
    #
    # Usage:
    #   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>


    #Prologue
    addi sp, sp, -48
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    sw s5, 20(sp)
    sw s6, 24(sp)
    sw s7, 28(sp)
    sw s8, 32(sp)
    sw s9, 36(sp)
    sw s10, 40(sp)
    sw ra, 44(sp)
    
    mv s4, a0
    mv s5, a1
    mv s10, a2


    li t0, 5
    bne s4, t0, error_args

    lw s0, 4(s5)  #pointer to m0_path
    lw s1, 8(s5)  #pointer to m1_path
    lw s2, 12(s5)  #pointer to input_path
    lw s3, 16(s5) #pointer to output_path 

	# =====================================
    # LOAD MATRICES
    # =====================================

    addi sp, sp, -24

    # Load pretrained m0
    mv a0, s0
    addi a1, sp, 0
    addi a2, sp, 4

    jal read_matrix
    mv s0, a0

    # Load pretrained m1
    mv a0, s1
    addi a1, sp, 8
    addi a2, sp, 12

    jal read_matrix
    mv s1, a0

    # Load input matrix
    mv a0, s2
    addi a1, sp, 16
    addi a2, sp, 20

    jal read_matrix
    mv s2, a0


    # =====================================
    # RUN LAYERS
    # =====================================
    # 1. LINEAR LAYER:    m0 * input
    # 2. NONLINEAR LAYER: ReLU(m0 * input)
    # 3. LINEAR LAYER:    m1 * ReLU(m0 * input)


    lw s4, 0(sp)
    lw s5, 20(sp)
    mul t2, s4, s5

    slli a0, t2, 2
    jal malloc 
    beq a0, x0, error_malloc

    mv s6, a0

    mv a0, s0
    lw a1, 0(sp)
    lw a2, 4(sp) 
    mv a3, s2
    lw a4, 16(sp)
    lw a5, 20(sp)
    mv a6, s6
    
    jal matmul



    mv a0, s6
    mul a1, s4, s5

    jal relu
    



    lw s7, 8(sp)
    mv s8, s5
    mul t2, s7, s8
    slli a0, t2, 2
    jal malloc
    beq a0, x0, error_malloc
    mv s9, a0

    mv a0, s1
    lw a1, 8(sp)
    lw a2, 12(sp) 
    mv a3, s6
    mv a4, s4
    mv a5, s5
    mv a6, s9
    
    jal matmul

    mv a0, s6
    jal free

    addi sp, sp, 24

    # =====================================
    # WRITE OUTPUT
    # =====================================
    # Write output matrix

    bne s10, x0, dont_write_matrix

    mv a0, s3
    mv a1, s9
    mv a2, s7
    mv a3, s8
    jal write_matrix

dont_write_matrix:
    # =====================================
    # CALCULATE CLASSIFICATION/LABEL
    # =====================================
    # Call argmax
    mv a0, s9
    mul a1, s7, s8
    jal argmax

    # Print classification
    
    mv s10, a0
    mv a1, s10
    jal print_int

    # Print newline afterwards for clarity
    
    li a1, 10
    jal print_char


    # free heap memory

    mv a0, s9
    jal free

    # Epilogue
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw s5, 20(sp)
    lw s6, 24(sp)
    lw s7, 28(sp)
    lw s8, 32(sp)
    lw s9, 36(sp)
    lw s10, 40(sp)
    lw ra, 44(sp)
    addi sp, sp, 48

    mv a0, s10
    ret

error_malloc:
    li a1, 88
    jal exit2
error_args:
    li a1, 89
    jal exit2