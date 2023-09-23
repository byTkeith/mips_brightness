.data
    newline: .asciiz "\n"
    inputFile: .asciiz "house_64_in_ascii_crlf.ppm"
    outputfile: .asciiz "output.ppm"
    buffer: .space 2
.text
    .globl main


main:
    #openning the file 
    li $v0, 13
    la $a0, inputFile
    li $a1, 0 #reads the file 
    syscall

    #to handle the file error
    bnez $v0, fileOpened
    li $v0, 10 #exit if error exists
    syscall
fileOpened:
    move $s0, $v0 #to save the file

    #open file for writing
    li $v0, 13
    la $a0, outputfile
    li $a1, 1 write #to file
    syscall

    #handling error
    bnez $v0, Second_fileOpened
    li $v0, 10
    syscall

Second_fileOpened:
    move $s1, $v0 #save opened file

    #intializing variables
    li $t0, 0 #rows
    li $t1, 0 #column
    li $t2, 0 #pixel count

    #to read thhe file
    readFile:
        li $v0, 14
        move $a0, $s0
        la $a1, buffer 
        li $a2,1 #read one characters
        syscall

        #check new lines
        lb $t3, buffer
        lb $t4, buffer+1
        beq $t3, 10, afterHeader
        bne $t3, 35, readFile
        j readFile
    afterHeader:
        #write output to output file
        li $v0, 15 #to write to file
        move $a0, $s1
        la $a1, bufffer
        li $a2, 1
        li $a2, 1 write one characters
        syscall

        #checking for end
        lb $t3, buffer
        lb $t4, buffer+1
        beq $t3, 10, header_written
        bne $t3, 35, afterHeader
        j afterHeader

        header_written:
            #initialize sums
            li $t5, 0 #for red
            li $t6, 0 #for green
            li $t7, 0 #for blue
            #for new values
            li $t8, 0 
            li $t9, 0
            li $t10, 0

        pixel_search:
            #reading from the input file
            li $v0, 14
            move $a0, $s0
            lb $t3, 0($a1)
            li $a2, 1      #read one byte at a time
            syscall

            li $v0, 14
            move $a0, $s0
            lb $t4, 0($a1)
            li $a2, 1      #read one byte at a time
            syscall

            li $v0, 14
            move $a0, $s0
            lb $t5, 0($a1)
            li $a2, 1      #read one byte at a time
            syscall


exit:
    li $v0,10
    syscall