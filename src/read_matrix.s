.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
# Exceptions:
# - If malloc returns an error,
#   this function terminates the program with error code 88.
# - If you receive an fopen error or eof, 
#   this function terminates the program with error code 90.
# - If you receive an fread error or eof,
#   this function terminates the program with error code 91.
# - If you receive an fclose error or eof,
#   this function terminates the program with error code 92.
# ==============================================================================
read_matrix:
    
    # Prologue
	addi sp, sp, -20
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw ra, 16(sp)

    #save args
    mv s0, a0
    mv s1, a1
    mv s2, a2
    
    #prepare fopen
    mv a1, s0
    li a2, 0
    
    jal ra, fopen
    li t0, -1
    beq a0, t0, error_fopen 
    mv s0, a0 #save fileptr in s0

    #READ ROWS AND COLS
    #prepare malloc
    li a0, 8
    jal ra, malloc
    beq a0, x0, error_malloc
    mv s3, a0 #save malloc add in s3
    
    #prepare fread
    mv a1, s0
    mv a2, s3
    li a3, 8
    
    jal ra, fread
    li t0, 8
    bne a0, t0, error_fread

    #save rows and cols from heap
    lw t1, 0(s3)
    lw t2, 4(s3)
    #load rows and cols in reqd addresses
    sw t1, 0(s1)
    sw t2, 0(s2)
    #store rxc in s1
    mul s1, t1, t2

    #free first malloc
    mv a0, s3
    jal ra, free
    
    #READ MATRIX DATA
    #prepare malloc
    slli a0, s1, 2
    jal ra, malloc
    beq a0, x0, error_malloc
    mv s3, a0 #save malloc add in s3
    
    #prepare fread
    mv a1, s0
    mv a2, s3
    slli a3, s1, 2
    
    jal ra, fread
    slli t0, s1, 2
    bne a0, t0, error_fread
    
    #close file
    mv a1, s0
    jal ra, fclose
    bne a0, x0, error_fclose
    
    mv a0, s3
done:
    # Epilogue
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw ra, 16(sp)
    addi sp, sp, 20
    ret

error_malloc:
    li a1, 88
    jal exit2
error_fopen:
    li a1, 90
    jal exit2
error_fread:
    li a1, 91
    jal exit2
error_fclose:
    li a1, 92
    jal exit2
