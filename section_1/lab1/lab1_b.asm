.data
	newline: .asciiz "\n"
	space: .asciiz " "
	lbracket: .asciiz "["
	rbracket: .asciiz "]"
	comma: .asciiz ","
	ask_n1: .asciiz "Enter N1: "
	ask_n2: .asciiz "Enter N2: "
	
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
	
.macro print_n1_n2(%x, %y)
    print_str(lbracket)
    print_int(%x)
    print_str(comma)
    print_int(%y)
    print_str(rbracket)  
.end_macro
   
.macro new_line
    li $v0, 4
    la $a0, newline
    syscall
.end_macro

.macro scan_index
    li $v0, 5
    syscall
.end_macro

.macro done
    li $v0, 10
    syscall
.end_macro

.text 
.globl main

#to s1 kai to s2 ksekina panta me 0 value
main:
	# s1 = max_N1 KAI s2 = max_N2
	# t1 = N1' KAI t2 = N2'
	# t3 = N2 - N1 KAI t4 = N2' - N1 
	print_n1_n2($s1, $s2)
	new_line
	
	print_str(ask_n1)
	scan_index
	move $t1, $v0
	new_line
	bltz $t1, end_programm
	
	print_str(ask_n2)
	scan_index
	move $t2, $v0
	new_line
	bltz $t2, end_programm
	
	j check_n1
	
check_n1: 
	bltu $t1, $s1, second_n1_check #ama N1' < N1
	j check_n2
	
second_n1_check:
	bltu $t2, $s2, check_extend_n1 #ama N2' < N2
	#alliws olikh epikalupsh
	move $s1, $t1
	move $s2, $t2
	j main

check_extend_n1:
	bltu $t2, $s1, check_kamia_epikalupsh #ama N2' < N1
	#alliws apla ginetai extend pros to n1 dhlada [N1' , N2]
	move $s1, $t1
	j main
	
check_kamia_epikalupsh: 
	sub $t3, $s2, $s1
	sub $t4, $t2, $t1
	
	bgtu $t3, $t4, main #ama N2 - N1 > N2' - N1' tpt den tha allaksei dhladh
	#alliws
	move $s1, $t1
	move $s2, $t2
	j main
	
check_n2:
	bgtu $t2, $s2, check_extend_n2 #ama N2' > N2
	j main # menoun apla ta palia N1 kai N2

check_extend_n2: # den uparxei logos na kanw second_n2_check
	bgtu $t1, $s2, check_kamia_epikalupsh
	move $s2, $t2
	j main
	
	
#END			
end_programm:
	print_n1_n2($s1, $s2)
	new_line
	
	done
	
	
	
	
	
	