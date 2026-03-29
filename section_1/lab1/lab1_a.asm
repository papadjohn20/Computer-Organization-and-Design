.macro done
    li $v0, 10
    syscall
.end_macro

.macro print_index
    li $v0, 1
    syscall
.end_macro

.text
.globl main

main:
    li $s0, 0x811F56AB
    #li $s0, 0x7FF6701
    li $s1, 8
    li $t1, 0xf0000000
   
    addi $t2, $s1, -4
    
    srav $t3, $t1, $t2 
    
    srav $s2, $s0, $s1
    xor $s3, $s2, $t3
    
    #to unsigned apotelsma einai sto s2
    #to signed apotelsma einai sto s3
    
    done