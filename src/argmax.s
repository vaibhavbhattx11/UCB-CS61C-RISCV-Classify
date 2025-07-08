.globl argmax

.text
# =================================================================
# FUNCTION: Given a int vector, return the index of the largest
#	element. If there are multiple, return the one
#	with the smallest index.
# Arguments:
# 	a0 (int*) is the pointer to the start of the vector
#	a1 (int)  is the # of elements in the vector
# Returns:
#	a0 (int)  is the first index of the largest element
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 77.
# =================================================================
argmax:
    li t0, 1
    blt a1, t0, length_error
    # Prologue
    addi sp,sp,-12
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    
    mv s0, a0
    mv s1, a1
    mv t1, x0
    mv s2, s0
    
loop_start:
    bge t1, s1, loop_end
    slli t2, t1, 2
    add a0, s0, t2
    lw t2, 0(a0)
    lw t3, 0(s2)
    bge t3,t2,loop_continue
    mv s2, a0
loop_continue:
    addi t1,t1,1
    j loop_start
loop_end:
    sub a0, s2, s0
    srli a0,a0,2
    # Epilogue
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    addi sp,sp,12
    ret
length_error:
    li a1, 77
    jal exit2
