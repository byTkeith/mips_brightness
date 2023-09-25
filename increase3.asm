.data
    originalPrompt: .asciiz "Average pixel value of the original image:\n"
    finalPrompt: .asciiz "Average pixel value of new image:\n"
    
    input_file:   .asciiz "D:\\arch_ass\\house_64_in_ascii_lf.ppm"    
    output_file: .asciiz "D:\\arch_ass\\Result.ppm" 
    buffer: .space 47434 # buffer to read data into
    offset: .word 4 #pixel offset
.globl main
.text
    main:
        # Open the file
        li $v0, 13 # system call for open file
        la $a0, input_file # input string
        li $a1, 0 # flag for read mode
        li $a2, 0 # mode is ignored 
        syscall # open file

        move $s6, $v0 # save the file descriptor

        bltz $v0, exit #if our $v0 is less than 0

        # Read from the file
        li $v0, 14 # system call for read from file
        move $a0, $s6 # file descriptor
        la $a1, buffer # address of buffer to which to read
        li $a2, 47434 # hardcoded buffer length
        syscall # read from file

        move $t4, $v0 #save the number of bytes
 
        bltz $v0, exit #checks if less than zero
        
        # Process the pixel data (increase brightness)
        la $t0, buffer # load address of buffer into $t0
        la $t5,  offset #skip the header and comment
        lw $t5, 0($t5) #load word from offset into $t5

        addu $t0, $t0, $t5 #add offset to buffer address
        move $t1, $t4 #load length of buffer into t1
        subu $t1, $t1, $t5 #subtract offset from length

    process_loop:
        li $t2, 0
        lbu $t2, 0($t0) # load byte from buffer into $t2
        subu $t2, $t2, 48 #convert ascii value to integer
        addiu $t2, $t2, 10 # increase brightness by 10
        sltiu $t3, $t2, 256 # check if value is less than 256
        beqz $t3, clamp_value # if value is not less than 256, clamp it to 255
        addiu $t2, $t2, 48 #covert back to ascii
        sb $t2, 0($t0) # store byte back into buffer

    digit_loop:
        lbu $t3, 0($t0)#load byte from buffer to t3
        beqz $t3, done #if byte = null end of string exit loop
        subu $t3, $t3, 48 #convert ascii digit to integer
        mul $t2, $t2, 10 #shift current one place left
        addiu $t0, $t0, 1 #increment bufer adress by 1
        lbu $t3, 0($t0) #load next byte from buffer
        bne $t3, 32, digit_loop 


    done:
        addiu $t2, $t2, 10 #increase brightness by 10
        sltiu $t3, $t3, 256 #check if less then 256
        beqz $t3, clamp_value #if value is above 255
        li $t2, 255+48 #cap to 255 and covert back to ascii
        sb $t2, -1($t0) #store back into buffe
        addiu $t1, $t1, -1 #decrement length by 1
        bnez $t1, process_loop #if not zero continue loop

        

    clamp_value:
        li $t2, 255+48 # clamp value to 255 and convert back to ascii
        sb $t2, -1($t0) # store byte back into buffer

        addiu $t0, $t0, -1 #decrement length by 4
        bnez $t1, process_loop # if remaining length is not zero, continue loop

        li $v0, 16
        move $a0, $s6
        syscall

        bltz $v0, exit

        #open output file
        li $v0, 13
        la $a0, output_file
        li $a1, 1 #flag for write mode
        li $a2, 0
        syscall #open file

        bltz $v0, exit

        move $s7, $v0

        #to write to file
        li $v0, 15
        move $a0, $s7 #output file discriptor
        la $a1, buffer
        move $a2, $t4
        syscall

        bltz $v0, exit

        li $v0, 16
        move $a0, $s7
        syscall


    exit:
        li $v0, 10
        syscall


