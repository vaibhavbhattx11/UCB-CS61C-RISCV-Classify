.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
# 	a0 (int*) is the pointer to the array
#	a1 (int)  is the # of elements in the array
# Returns:
#	None
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 78.
# ==============================================================================
relu:
    addi t0, x0, 1
    blt a1, t0, length_error
    #Prologue
    addi sp, sp, -8
    sw s0, 0(sp)
    sw s1, 4(sp)
    
    mv s0, a0
    mv s1, a1
    mv t1, x0
loop_start:
    bge t1, s1, loop_end
    slli t2, t1, 2
    add a0, s0, t2
    lw t2, 0(a0)
    bge t2,x0,loop_continue
    sw x0, 0(a0)
loop_continue:
    addi t1,t1,1
    j loop_start
loop_end:
    # Epilogue
    lw s0, 0(sp)
    lw s1, 4(sp)
    addi sp, sp, 8
    
	ret
length_error:
    li a1, 78
    jal exit2