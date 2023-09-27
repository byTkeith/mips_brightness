.data
    originalPrompt: .asciiz "Average pixel value of the original image:\n"
    finalPrompt: .asciiz "Average pixel value of new image:\n"
    
    input_file:   .asciiz "D:/arch_ass/test.txt"    
    output_file: .asciiz "D:/arch_ass/Result.ppm" 
    buffer: .space 100 #47434 # buffer to read data into
    buffer_output: .space 100 #47434 #buffer for upadated values
    offset: .word 4 #pixel offset
    HEADER_SIZE: .space 18

    newLine: .asciiz "\n"
.globl main
.text
    main:
        # Open the file
        li $v0, 13 # system call for open file
        la $a0, input_file # input string
        li $a1, 0 # flag for read mode
        syscall # open file
        move $s6, $v0 # save the file descriptor

        bltz $v0, exit #if our $v0 is less than 0

        #read the header from input file
        li $v0, 14
        move $a0, $s6
        la $a1, buffer #adresss to read from
        li $a2, 47434 #hard coded header size
        syscall
	move $s2, $v0
	
        #open output file
        li $v0, 13
        la $a0, output_file
        li $a1, 1 #flag fro write mode
        syscall
        move $s7, $v0 #save file discriptor

        #write header to output_file
        li $v0, 15
        move $a0, $s7
        la $a1, buffer
        li $a2, 23
        syscall

        #skip the header
        la $t0, buffer
#        la $t6, buffer_output
        addiu $t0, $t0, 23 #skip header
        
        #compute the number of pixels
        li $t8, '\n'
        li $t7, '0' 
        
        addi $s2, $s2, -18
    process_loop:
        lbu $t2, 0($t0) # load byte from buffer into $t2
        
        #initialize pixel value to 0
        li $t5, 0
    convert_loop:
    	beq $s2, $zero, process_pixel_value
        beq $t2, $t8, process_pixel_value #if we have reached a space or newline character
        sub $t2,$t2, $t7 #convert ascii to into

        addi $s2, $s2, -1
        mul $t5, $t5, 10
        addu $t5, $t5,  $t2
          
        addiu $t0,$t0, 1
        lbu $t2, ($t0) #load next character

        j convert_loop

    process_pixel_value:
        move $t2, $t5 #move converted integr value to $t2
        addiu $t2,$t2, 10 #increment pixel by 10
      	addi $s2, $s2, -1
      	
  	bge $t2, 255, inc_set  #check if pixel less than 255
    start_string:    
	la $t6, buffer_output
	addiu $t6, $t6, 11
	
	sb $zero, ($t6)
	
    store_value:
        #convert back to string
        convert_back_loop:
            beqz $t2, end_convert_back
            remu $t4, $t2, 10
            addu $t4, $t4,'0'
            sb $t4, -1($t6) #store in the correct order
            addiu $t6,$t6, -1
            divu $t2, $t2, 10
            j convert_back_loop
    end_convert_back:
        #add line after each number
 #       sb $t4, 0($t6)
 #       addiu $t6, $t6, 1

    max_value:
        #to write to file
        li $v0, 15
        move $a0, $s7 #output file discriptor
        move $a1, $t6 #use bufferoutput instead
        li $a2, 47434
        syscall
        
        move $s7, $zero
        blez $s2, exit
        #li $v0, 15
        #move $a0, $s7 #output file discriptor
        #la $a1, newLine
        #li $a2, 1
        #syscall
	
	#move $t6, $zero
	#move $t5, $zero
	
	#blez $s2, exit
	
	j process_loop
    exit:
    	li $v0, 16
        move $a0, $s7
        syscall
           
        li $v0, 10
        syscall
        
#li $v0, 10
  #      syscall
    inc_set:
    	li $t2, 255		# set RGB value to 255, if over 255
    	j start_string