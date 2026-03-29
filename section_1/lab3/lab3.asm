.data
     array: .word 17, 12, 6, 19, 23, 8, 5, 10
     #array: .word 17, 12 ,6, 19, 23, 40, 5, 10
     #array: .word 17, 1, 13, 19, 23, 8, 5, 10
     #array: .word  1, 1, 3, 4, 5, 6, 3, 1
     #array: .word  1, 2, 3, 4, 5, 6, 7, 8
     length: .word 8
     #array: .word 17,12,6,19,23
     #array: .word 17,17,17,17,17
     #length: .word 5
     space: .asciiz " "
     newline: .asciiz "\n"
	
.macro print_str(%x)
    li $v0, 4
    la $a0, %x
    syscall
.end_macro

.macro print_int(%x)
    li $v0, 1
    move $a0, %x
    syscall
.end_macro

.macro done
    li $v0, 10
    syscall
.end_macro

.text
.globl main

main: 
	# a0 = base, a1 = left, a2 = right, $a3 = array
	lw $s0, length
	la $a3, array
	jal print_array
	
	subi $t0, $s0, 1
	mul $t4, $t0, 4
	move $a1, $a3 
	la $a2, array($t4) 
	
	
	jal super_fast_sorting
	
    end_program:
	jal print_array
	done
	
	
super_fast_sorting: #a3 array, a1 = start and a2 stop
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	bge $a1, $a2, return #if (start >= stop) { return; } stop the recursion
	#else 
	lw $t0, 0($a2) # t0 = base = array[stop]
	move $t1, $a1 # t1 = left = start
	move $t2, $a2 # t2 = right = stop
	
    
    while_loop: # while(left < right)
	bge $t1, $t2, recursion_left_array #the case of while_loop 
	
	while_loop_left: # while(array[left] <= base && left < right)
    	    lw $t3, 0($t1) # t3 = array[left]
    	    bgt $t3, $t0, while_loop_right
    	    bge $t1, $t2, while_loop_right
    	    #else
    	    addi $t1, $t1, 4 # left++
    	    j while_loop_left
        
        while_loop_right: # while(array[right] > base && left < right)
 	    lw $t3, 0($t2) # t3 = array[right]
    	    ble $t3, $t0, swap
    	    bge $t1, $t2, swap  
    	    #else
    	    addi $t2, $t2, -4 # right++
    	    j while_loop_right 
    	
        swap: #if (left < right) { swap(...) }
            bge $t1, $t2, while_loop
            lw $t3, 0($t1) # t3 = array[left]
    	    lw $t4, 0($t2) # t4 = array[right]
    	    sw $t4, 0($t1)
    	    sw $t3, 0($t2)
    	    j while_loop	
    
    recursion_left_array: #super_fast_sorting(array, start, right - 1);
    	# a0 and a1 same
    	add $t2, $t2, -4
    	addi $sp, $sp, -4
    	sw $a2, 0($sp)
    	move $a2, $t2
    	jal super_fast_sorting	
    	
    recursion_right_array: #super_fast_sorting(array, right, stop);
    	lw $a2, 0($sp)
    	addi $sp, $sp, 4
    	lw $t4, 0($t2) # t4 = array[right]
    	print_int($t4)
    	print_str(space)
    	#lw $t3, 0($a2)
    	print_int($a2)
    	print_str(newline)
    	add $t2, $t2, 4
    	lw $t4, 0($t2) # t4 = array[right]
    	print_int($t4)
    	print_str(space)
    	lw $t3, 0($a2)
    	print_int($t3)
    	print_str(newline)
    	move $a1, $t2
    	jal super_fast_sorting
    return:  
    	lw $ra, 0($sp)
    	addi $sp, $sp, 4
    	jr $ra	
	
	#############################	
	
print_array:#a3 = array , s0 = length
	la $t0, 0($a3)
	li $t2, 1 #counter
	print_str(newline)
    print_loop: 
   	lw $t1, 0($t0)
	bgt $t2, $s0, exit #if counter == length
	#else 
	print_int($t1)
	print_str(space)
    	
	addi $t0, $t0, 4
	addi $t2, $t2, 1
	j print_loop
    exit:
        print_str(newline)
   	jr $ra	
