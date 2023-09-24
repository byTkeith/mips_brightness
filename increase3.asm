.data
    originalPrompt: .asciiz "Average pixel value of the original image:\n"
    finalPrompt: .asciiz "Average pixel value of new image:\n"
    
    output_file:   .asciiz "house_64_in_ascii_crlf_output.ppm"    # New output file name
    fileName: .asciiz "c:\Users\Admin\Downloads\sample_images\house_64_in_ascii_crlf.ppm" # replace with your PPM file path
    buffer: .space 1024 # buffer to read data into

.text
    # Open the file
    li $v0, 13 # system call for open file
    la $a0, fileName # input string
    li $a1, 0 # flag for read mode
    li $a2, 0 # mode is ignored 
    syscall # open file

    move $s6, $v0 # save the file descriptor

    # Read from the file
    li $v0, 14 # system call for read from file
    move $a0, $s6 # file descriptor
    la $a1, buffer # address of buffer to which to read
    li $a2, 1024 # hardcoded buffer length
    syscall # read from file

    # Process the pixel data (increase brightness)
    la $t0, buffer # load address of buffer into $t0
    li $t1, 1024 # load length of buffer into $t1

process_loop:
    lbu $t2, 0($t0) # load byte from buffer into $t2
    addiu $t2, $t2, 10 # increase brightness by 10
    sltiu $t3, $t2, 256 # check if value is less than 256
    beqz $t3, clamp_value # if value is not less than 256, clamp it to 255
    sb $t2, 0($t0) # store byte back into buffer

clamp_value:
    li $t2, 255 # clamp value to 255
    sb $t2, 0($t0) # store byte back into buffer

    addiu $t0, $t0, 1 # increment buffer address by 1
    addiu $t1, $t1, -1 # decrement remaining length by 1
    bnez $t1, process_loop # if remaining length is not zero, continue loop

    # Close the file
    li $v0, 16 # system call for close file
    move $a0, $s6 # file descriptor to close
    syscall # close file
exit:
    li $v0, 10
    syscall


