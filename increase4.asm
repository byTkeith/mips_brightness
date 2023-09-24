.data
    inputFileName: .asciiz "D:\arch_ass\house_64_in_ascii_crlf.ppm" # replace with your PPM file path
    outputFileName: .asciiz "D:\arch_ass\house_64_in_ascii_crlf_result.ppm" # replace with your output file path
    buffer: .space 47434 # buffer to read data into

.text
    .globl main
    main:
        # Open the input file
        li $v0, 13 # system call for open file
        la $a0, inputFileName # input string
        li $a1, 0 # flag for read mode
        li $a2, 0 # mode is ignored 
        syscall # open file

        move $s6, $v0 # save the input file descriptor

        # Open the output file
        li $v0, 13 # system call for open file
        la $a0, outputFileName # output string
        li $a1, 1 # flag for write mode
        li $a2, 0 # mode is ignored 
        syscall # open file

        move $s7, $v0 # save the output file descriptor

        

        # Read from the input file and write to the output file
        li $v0, 14 # system call for read from file
        move $a0, $s6 # input file descriptor
        la $a1, buffer # address of buffer to which to read
        li $a2, 47434 # hardcoded buffer length
        syscall # read from file

        move $t4, $v0 # save the number of bytes read

        li $v0, 15 # system call for write to file
        move $a0, $s7 # output file descriptor
        la $a1, buffer # address of buffer from which to write
        move $a2, $t4 # number of bytes to write
        syscall # write to file

        # Close the input file
        li $v0, 16 # system call for close file
        move $a0, $s6 # input file descriptor to close
        syscall # close file

        # Close the output file
        li $v0, 16 # system call for close file
        move $a0, $s7 # output file descriptor to close
        syscall # close file
        
        #exit program
        li $v0, 10
        syscall