#Tendai k Nyevedzanai
#NYVTEN001
#20/09/2023
.data
    originalAverage: .asciiz "Average pixel value of the original image:\n"
    finalAverage: .asciiz "Average pixel value of new image:\n"
    
    input_file:   .asciiz "D:/arch_ass/tree_64_in_ascii_lf.ppm"    
    output_file: .asciiz "D:/arch_ass/Result_tree.ppm" 
    words_buffer: .space 47434
  
    pixel_buffer: .space 47434 #buffer for upadated values
   
    float_size: .float 255.0

    offset: .word 4 #pixel offset
    HEADER_SIZE: .space 18

    newLine: .asciiz "\n"
.globl main
.text
    main:
        # Open the file
         move $t3, $zero #pointer for where to start

        li $v0, 13 # system call for open file
        la $a0, input_file # input string
        li $a1, 0 # flag for read mode
        syscall # open file
        move $s0, $v0 # save the file descriptor

        move $s5, $zero # initialising the pixel count
        move $s6, $zero # lines containing pixels

        move $s7, $zero #total value for pixels

        #open output file
        li $v0, 13
        la $a0, output_file
        li $a1, 1 #flag fro write mode
        syscall

        move $s3, $v0 # the number of bytes in the buffer

        li $v0, 14
        move $a0, $s0
        la $a1, words_buffer #adresss to read from
        li $a2, 47434 #hard coded header size
        syscall

        move $s2, $v0 #file descriptor

        la $t0, words_buffer #address of buffer
        li $t5, 10 # new line
        li $t7, '0'
        li $t8, 10 

        move $t4, $zero
        
    pixel_loop:
        beq $t3, 4, process_loop #skipping the header to were the pixels start
        lb $s1, 0($t0) #load byte of address

        #write header to output_file
        li $v0, 15
        move $a0, $s3
        move $a1, $t0
      
        li $a2, 1 
        syscall

        addi $s2, $s2, -1 #decrementing the byte of the buffer
        addi $t0, $t0, 1 # increment addresss
        beq $s1, $t5, increase_by
        j pixel_loop

    process_loop:
        #from string to integer
        beq $s2, $zero, end_point #reached the end of file
        lb $s1, 0($t0)
        addi $t0, $t0, 1

        beq $s1, $t5, endloop_2 #if values equal branch to the endloop_2
        addi $s2, $s2, -1
        sub $s1, $s1, $t7
        mul $t4, $t4, 10
        add $t4, $t4, $s1

        j process_loop

    increase_by:
        addi $t3, $t3, 1
        j pixel_loop

    endloop_2:
        addi $s2, $s2, -1 #decreasing size of the buffer
        add $s7, $s7, $t4
        addi $t4, $t4, 10 #incrementing values by 10
        bge $t4, 255, increase_count #branch if value exceeds 255
        add $s5, $s5, $t4 #adding total number of pixels
        addi $s6, $s6,1

    reverse_loop:
        la $t1, pixel_buffer #pointer to output buffer
        addiu $t1, $t1, 11 #pointer to last byte
        sb $zero, ($t1) #null terminator

        jal convert_loop
        move $t6, $zero #moving length of string
        move $s4, $t1 #move address of string to $s4
        jal maxLength

    copy_to_output:
        #write  to output_file
        li $v0, 15
        move $a0, $s3 #file descriptor
        move $a1, $t1 #values written to output
        move $a2, $t6 #length of string
        syscall

        #write new pixel to output_file
        li $v0, 15
        move $a0, $s3
        la $a1, newLine
        li $a2, 1
        syscall

        move $t1, $zero
        move $t4, $zero
        blez $s2, final_loop

        j process_loop

    end_point:
        j endloop_2

    final_loop:
        #convert int to floating pointer
        lwc1 $f6, float_size
        mtc1 $s7, $f4 #move $s7 to floating point reg f4, for old values
        mtc1 $s5, $f0 #move the new values to $f0
        mtc1 $s6, $f2 #move s6 to fp reg f2

        div.s $f4 , $f4, $f2 #f4/f2=f4 for old image
        div.s $f4 $f4, $f6 #f4/255=f4

        div.s $f0, $f0, $f2 #f0/f2=f0
        div.s $f0, $f0, $f6

        #print out the old average prompt 
        li $v0, 4
        la $a0, originalAverage
        syscall

        li $v0, 2
        mov.s $f12, $f4 #to print the float of old values
        syscall
        
        #print new line
        li $v0, 4
        la $a0, newLine
        syscall

        #print out the new average prompt 
        li $v0, 4
        la $a0, finalAverage
        syscall

        li $v0, 2
        mov.s $f12, $f0 #to print the float of old values
        syscall

        li $v0, 16
        move $a0, $s0
        syscall

        li $v0, 16
        move $a0, $s3
        syscall

        li $v0, 10 #exit
        syscall
    out_of_bounds:
        negu $t4, $t4
        sb $t4, -1($t1)
        j convert_loop

    convert_loop:
        #get next digit
        remu $t2, $t4, 10
        addiu $t2, $t2, '0' #conert to ascii
        addiu $t1, $t1, -1 #move the pointer
        sb $t2, 0($t1)  #store value in the buffer
        divu $t4, $t4, 10 #
        bnez $t4, convert_loop

        jr $ra

    maxLength:
        lb $t2, 0($s4)
        beq $t2, $zero, , copy_to_output
        addi $t6, $t6, 1
        addi $s4, $s4, 1
        j maxLength

    increase_count:
        li $t4, 255 #clamp values to 255
        j reverse_loop 
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    #inc_sets
        li $t4, 255
        j out_of_bounds #end strt



        






