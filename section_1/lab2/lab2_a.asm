.data
	array: .byte 
	'a','b','c','c','c','d','d','d','d','d','d','b','b','c','c','c','c',
	'a','e','e','e','e','e','e','e','e','e','e','e','e','f',0x1B
	
	#array: .byte 
	#'a','a','a','a','a','a','d','d','d','d','d','b','b','c','c','c','c',
	#'a','e','e','e','t','e','e','e','e','e','e','e','e','f',0x1B
	#array: .byte 
	#'a','a','a','a','a','a','a','a','a','a','a','a','a','a','a','a',  DEN DOULEVEI H PERIPTWSH POU EINAI IDIA ||| giati den allazei pote to temp sto telos(kane label gia eidikh periptwsh)
	#0x1B
	
	compressed: .space 40 
	decompressed: .space 60 
	newline: .asciiz "\n"
	space: .asciiz "  "
	comma: .asciiz ","
	compression_time: .asciiz "Time to compress the array\n\n"
	decompression_time: .asciiz "Time to decompress the array\n\n"
	
.macro print_char(%x)
    li $v0, 11
    move $a0, %x
    syscall
.end_macro
	
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

.macro print_hex(%x)
    li $v0, 34
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
	li $t0, 0
	la $a0, array
	la $a1, compressed
	#j print_array
	
	print_str(compression_time)
	jal compress
	print_str(newline)
	print_str(newline)
	
	print_str(decompression_time)
	jal decompress
	print_str(newline)
	
	j end_programm
	
print_array:
	lb $t1, array($t0)
	beq $t1	, 0x1B, end_programm
	print_char($t1)
	print_str(comma)
	addi $t0, $t0, 1
	j print_array
		
compress:#a0 = &array kai a1 = &compressed array
	#to t1 kai to t2 tha leitourgoun san pointers kai tha xrhsimopoioyntai gia na allazoyn toys pinakes
	la $t1, array
	la $t2, compressed
	lb $t3, 0($a1)#tha doulevei ws temp, mono kai mono gia na ginei h sugrkish
	li $t4, 0 #counter gia tis poses fores epanalambanetai ena gramma sunexomena
	li $t5, 0x1B
	
	loop1:#loop gia na allazei ana gramma to t0
	    lb $t0, 0($t1)
	    beq $t0, 0x1B, exit_print1 #EXIT
		
		bne $t0, $t3, check_counter1 # if t0 != t3
		sb $t0, 0($t2)
		addi $t4, $t4, 1 # t4 += 1 
		addi $t1, $t1, 1 # t1 += 1 
		addi $t2, $t2, 1 # t2 += 1 
		j loop1
		
	
	check_counter1:# checkarei thn timh tou counter kai pratei analoga
		blt $t4, 4, reset_counter1 #if t4 < 4
		sub $t2, $t2, $t4
		sb $t5, 0($t2)
		addi $t2, $t2, 1
		sb $t3, 0($t2) # einai to gramma pou kwdikopoiw to t3
		addi $t2, $t2, 1
		andi $t4, $t4, 0xFF #kanei to t4 se 8bit hex dld t4 = 6 => 0x06 h t4 = 12 => 0x0C
		sb $t4, 0($t2)
		addi $t2, $t2, 1
		j reset_counter1 # prepei na ginei reset to counter etsi kai alliws
	
	reset_counter1: 
		li $t4, 1 #reset se 1 giati allakse to gramma alla to kainourgio gramma exei 1 emfanish hdh
		li $t3, 0
    		#oxi t2 += 1 gt tha kseperasei mia thesh (exei hdh ginei pio panw to += 1)
		sb $t0, 0($t2)
		addi $t2, $t2, 1 # twra prepei na ginei gia na mhn paei to epomeno kai kanei overwrite sto prohgoumeno
		addi $t3, $t0, 0  #update to temp
		addi $t1, $t1, 1
		j loop1
		
	exit_print1: 
	   #vazw ta 2 0x1B sto telo 
	   #addi $t2, $t2, 1  exei ginei hdh pio panw
	   sb $t5, 0($t2)
	   addi $t2, $t2, 1
	   sb $t5, 0($t2)
	   
	   la $t6, compressed
	   print1:
		lb $t7, 0($t6)
		beq $t7	, 0x1B, check_end1#na tsekarw ama einai to telos tis lista h kwdikopoihsh
		print_char($t7)
		print_str(space)
		addi $t6, $t6, 1
		j print1
	  
	   check_end1:
	   	addi $t6, $t6, 1 
	   	lb $t7, 0($t6)
	   	beq $t7	, 0x1B, evacuate1 # ama einai kai meta apo to prwto 0x1B ksana 0x1B einai to telos
	   	#esle print 0x1B, 'x', 0x0X
	   	print_hex($t5)#t5 = 0x1B
	   	print_str(space)
	   	print_char($t7)# t7 = 'x'
	   	print_str(space)
	   	addi $t6, $t6, 1 
	   	lb $t7, 0($t6) 
	   	print_hex($t7)# t7 = 0x0X
	   	print_str(space)
	   	addi $t6, $t6, 1
	   	j print1 #sunexizei me ta epomena  	
	   
	   evacuate1:
	    	jr $ra
	    	
	    	
decompress:#a1 = &compressed array kai a2 = &decompressed array
	#to t1 kai to t2 tha leitourgoun san pointers kai tha xrhsimopoioyntai gia na allazoyn toys pinakes
	la $t1, compressed
	la $t2, decompressed
	li $t3, 0 #tha einai to gramma pou exei kwdikopoihthei
	li $t4, 0 #counter gia tis poses fores prepei naepanalhfthei ena gramma sunexomena
	li $t5, 0x1B
	
	loop2:
	   lb $t0, 0($t1)
	   beq $t0, 0x1B, check_end2# checkarw ama einai kwdikopoihsh h ama einai to telos	
		
		sb $t0, 0($t2)
		addi $t1, $t1, 1 # t1 += 1 
		addi $t2, $t2, 1 # t2 += 1 
		j loop2
		
	check_end2:
		addi $t1, $t1, 1
		lb $t0, 0($t1)
		beq $t0, 0x1B, exit_print2 #EXIT giati brethikan duo fores sunexomena 0x1B
		move $t3, $t0 #to t3 einai to gramma pou prepei na epanalhfthei
		addi $t1, $t1, 1
		lb $t8, 0($t1) #edw to t0 apokta to 16diko counter p.x. 0x06.
		addi $t1, $t1, 1 # gia na parei to t0 to epomeno gramma otan xreiastei
		j sb_loop2
	
	sb_loop2:# kanei store ena gramma oses fores prepei sunexomena
		beqz $t8, loop2 #if t0 == 0
		sb $t3, 0($t2)
		addi $t2, $t2, 1
		addi $t8, $t8, -1
		j sb_loop2
	
	exit_print2:
	     sb $t5, 0($t2)
	     
	     la $t6, decompressed
	     print2:
	     	lb $t7, 0($t6)
		beq $t7	, 0x1B, evacuate2 #brhke to telos
		print_char($t7)
		print_str(comma)
		print_str(space)
		addi $t6, $t6, 1
		
		j print2#sunexizei me ta epomena  
			
	evacuate2:
	    	jr $ra
#END
end_programm: 
	done
