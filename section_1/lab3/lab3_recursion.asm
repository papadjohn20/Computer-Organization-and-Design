.data
     array: .word 17, 12, 6, 19, 23, 8, 5, 10
     length: .word 8
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
	la $a3, array
	lw $s0, length
	jal print_array
	
	subi $t0, $s0, 1
	mul $t4, $t0, 4
	lw $a0, array($t4) 
	la $a1, array 
	la $a2, array($t4) 
	
	jal super_fast_sorting
	
   end_program:
	jal print_array
	done

super_fast_sorting: # a0 = base, a1 = left, a2 = right
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	blt $a1, $a2, L1 #if left < right sunexise thn anadromh
	#if left >= right stop
	addi $sp, $sp, 4
	jr $ra
    
    L1: lw $t1, 0($a1) # *left
    	lw $t2, 0($a2) # *right
    	ble $t1, $a0, recursion #if *left <= base 
    	#if *left > base 
    	sw $t2, 0($a1)	# *right = *left
    	sw $t1, 0($a2)	# *left = *right , ta kanw SWAP ousiastika 
    	addi $a2, $a2, -4 # right -= 1
    recursion:
    	addi $a1, $a1, 4 # left += 1   
    	jal  super_fast_sorting	
    
    LL:	lw $ra, 0($sp)
    	addi $sp, $sp, 4
    	jr $ra	
    	
print_array:#a3 = array , s0 = length
	la $t0, 0($a3)
	li $t2, 1 #counter
	print_str(newline)
   loop: 
   	lw $t1, 0($t0)
	bgt $t2, $s0, exit #if counter == length
	#else 
	print_int($t1)
	print_str(space)
    	
	addi $t0, $t0, 4
	addi $t2, $t2, 1
	j loop
   exit:
   	jr $ra
	
		
