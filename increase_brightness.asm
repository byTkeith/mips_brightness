#Tendai K Nyevedzanai
#nyvten001
#19/09/2023
#programm that increments all the colour codes by 10
.data
    originalPrompt: .asciiz "Average pixel value of the original image:\n"
    finalPrompt: .asciiz "Average pixel value of new image:\n"
    input_file:  .asciiz "sample_images (1)/house_64_in_ascii_crlf.ppm"     #input file name
    output_file:   .asciiz "house_64_in_ascii_crlf_output.ppm"    # New output file name
    image_width:         .space 1024             # image_width for reading and writing 

.text
    main:
        # Open the original file for reading
        li $v0, 13             #syscall 13 opens the file
        la $a0, input_file #loadsthe address of the file
        li $a1, 0              #reads e the file 
        li $a2, 0             
        syscall