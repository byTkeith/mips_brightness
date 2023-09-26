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
        lbu $t2, 0($t0) # load byte from buffer into $t2
        subu $t2, $t2, 48
        addiu $t2, $t2, 10

    clamp_value: 
        #clamp the value to 255
        sltiu $t3, $t3, 256
        beqz $t3, cap_value
        

    cap_value:
        #convert to ascii then store
        li $t3, 100
        div $t2, $t3
        mflo $t3
        addiu $t3, $t3, 48
        sb $t3, -3($t0) #store modified value at same position

        li $t3, 10
        rem $t6, $t2, $t3
        mflo $t3

        addiu $t3, $t3, 48
        sb $t3, -2($t0) #stored at next position

        mfhi $t2
        addiu $t2, $t2, 48
        sb $t2, -1($t0) #store at follow up position

    next_pixel:
        addiu $t1, $t1, -1 #decrement length by 3
        bnez $t1, process_loop #if not zero 0r - continue loop

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


