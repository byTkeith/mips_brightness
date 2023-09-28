#Tendai k Nyevedzanai
#NYVTEN001
#20/09/2023
.data 
    input_file:   .asciiz "D:/arch_ass/tree_64_in_ascii_lf.ppm"    
    output_file: .asciiz "D:/arch_ass/Result_greyscale_tree.ppm" 
    words_buffer: .space 47434
   
    pixel_buffer: .space 47434 #buffer for upadated values
    outcome: .space 64

    float_size: .float 255.0
    file_type: .asciiz "P2\n"

   
    HEADER_SIZE: .space 18

    newLine: .asciiz "\n"
    end_prompt: .asciiz "file written"
.globl main
.text
    main:
        #open the file
        li $v0, 13 # system call for open file
        la $a0, input_file # input string
        li $a1, 0 # flag for read mode
        syscall # open file
        move $s0, $v0 # save the file descriptor

        li $v0, 13 # system call for open file
        la $a0, output_file # input string
        li $a1, 1 # flag for read mode
        syscall # open file
        move $s3, $v0 # save the file descriptor

        la $t2, file_type

        #write  to output_file
        li $v0, 15
        move $a0, $s3 #file descriptor
        move $a1, $t2 #values written to output
        li $a2, 3
        syscall

        li $v0, 14
        move $a0, $s0
        la $a1, words_buffer #adresss to read from
        li $a2, 47434 #hard coded header size
        syscall

        move $s2, $v0 #file descriptor
        la $t0, words_buffer #address of the buffer
        li $t7, '0'
        move $t4, $zero #our output integer
        move $t3, $zero

        addi $s2, $s2, -3
        addi $t0, $t0, 3
        move $t1, $zero

    pixel_loop:
        beq $t3, 3, process_loop #skipping the header to were the pixels start
        lb $s1, 0($t0) #load byte of address

        #write  to output_file
        li $v0, 15
        move $a0, $s3
        move $a1, $t0
        li $a2, 1
        syscall

        addi $s2, $s2, -1 #decrementing the byte of the buffer
        addi $t0, $t0, 1 # increment addresss
        beq $s1, 10, increase_by #if the byte is equal to '\n'
        j pixel_loop

    increase_by:
        addi $t3, $t3, 1
        j pixel_loop

    process_loop:
        #from string to integer
        beq $s2, $zero, final_loop #reached the end of file
        lb $s1, 0($t0)
        addi $t0, $t0, 1

        beq $s1, 10, endloop_2 #if values equal branch to the endloop_2
        addi $s2, $s2, -1
        sub $s1, $s1, $t7
        mul $t4, $t4, 10
        add $t4, $t4, $s1

        beqz $s2, end_pointer

        j process_loop

    endloop_2:
        addi $s2, $s2, -1 #decreasing size of the buffer
        add $t5, $t5, $t4

        move $t4, $zero
        addi $t1, $t1, 1 #incrementing counter for the three numbers
        beq $t1, 3, brunch_three
        j process_loop

    end_pointer:
        add $t5, $t5, $t4
        move $t4, $zero
        addi $t1, $t1, 1
        beq $t1, 3, brunch_three
        j process_loop 

    brunch_three:
        move $t1, $zero
        move $t4, $zero

        div $t5, $t5, 3 #to find the average of the numbers
        la $t6, pixel_buffer
        addiu $t6, $t6, 11 #pointer to the lasst pointer
        sb $zero, 0($t6) #null terminator

        jal convert_loop

        move $t8, $zero
        move $s1, $t6
        jal maxLength

    copy_to_output:
        #write  to output_file
        li $v0, 15
        move $a0, $s3 #file descriptor
        move $a1, $t6 #values written to output
        move $a2, $t8 #length of string
        syscall

        #write new pixel to output_file
        li $v0, 15
        move $a0, $s3
        la $a1, newLine #print new string
        li $a2, 1 #length of the string
        syscall

        move $t6, $zero
        move $t5, $zero
        beqz $s2, final_loop

        j process_loop

    convert_loop:
        #get next digit
        remu $t3, $t5, 10
        addiu $t3, $t3, '0' #conert to ascii
        addiu $t6, $t6, -1 #move the pointer
        sb $t3, 0($t6)  #store value in the buffer
        divu $t5, $t5, 10 #
        bnez $t5, convert_loop

        jr $ra

    maxLength:
        lb $t3, 0($s1)
        beq $t3, $zero, , copy_to_output
        addi $t8, $t8, 1
        addi $s1, $s1, 1
        j maxLength

    final_loop:
        li $v0, 16
        move $a0, $s0
        syscall

        li $v0, 16
        move $a0, $s3
        syscall

        li $v0, 10
        syscall
    



       
