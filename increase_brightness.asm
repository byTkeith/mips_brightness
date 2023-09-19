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

    
        bnez $v0, fileAccessed  # Checks if e file was opened 

        
        li $v0, 10    #exit If the file not  opened       
        syscall  

    fileAccessed:
        move $s0, $v0          #Saves file to $s0

        # Open the new file for writing with 13
        li $v0, 13             
        la $a0, output_file  # Load the address of the new file name
        li $a1, 1              # writing to file 
        li $a2, 0             
        syscall

        # Check of access made to file 
        bnez $v0, file_to_operate

        # syscall 16 closes thefile
        li $v0, 16            
        move $a0, $s0         
        syscall

        li $v0, 10             #exit
        syscall

    file_to_operate:
        move $s1, $v0          # Saving the file $s1

        #reads the 3 lines
        li $t0, 0              # Initialize a counter
        la $t1, image_width         # Load the address of the image_width

    read_header_loop:
        beq $t0, 3, readPixels # If 3 lines are read, proceed to read pixels
        li $v0, 14             #load syscall code for reading
        move $a0, $s0         
        move $a1, $t1          #destination image_width
        li $a2, 512            #read up to 512 characters
        syscall
        addi $t0, $t0, 1       #increment the counter
        addi $t1, $t1, 512     #move image_width pointer to the next position
        b read_header_loop

    readPixels:
        li $t2, 0              #Initialize the counter for the number of pixels to zeo

    readPixels_loop:
        beq $t2, 512, create_image #If 512 pixels ar reached, proceed to write the new image

        # Read a 3 RGB values
        li $v0, 14            
        move $a0, $s0         
        move $a1, $t1         
        li $a2, 3              #read 3 bytes (RGB values)
        syscall

        # Increment image_width pointer
        addi $t1, $t1, 3

        # Calculate new RGB values with a cap at 255
        lb $t3, -3($t1)        #for R component
        lb $t4, -2($t1)        # "  G component
        lb $t5, -1($t1)        # "  B component

        addi $t3, $t3, 10      # Increments R by 10
        addi $t4, $t4, 10      #     "      G by 10
        addi $t5, $t5, 10      #     "      B by 10

        # Check for cap at 255
        li $t6, 255            # Load 255 into $t6 so we can check if its exceeded
        min $t3, $t3, $t6      # max  R at 255
        min $t4, $t4, $t6      #  "  G at 255
        min $t5, $t5, $t6      #   "   B at 255

        # Write the new RGB values
        sb $t3, -3($t1)        #the new R component
        sb $t4, -2($t1)        #the new G component
        sb $t5, -1($t1)        #the new B component

        # Increment the pixel counter
        addi $t2, $t2, 1
        b readPixels_loop

    create_image:
        # Write the modified image to the new file
        li $v0, 15             # syscall code for write
        move $a0, $s1         
        la $a1, image_width         # Source image_width
        li $a2, 512            
        syscall

        # Close both files
        li $v0, 16             # Load syscall code for close
        move $a0, $s0          # Original file descriptor
        syscall
        move $a0, $s1          
        syscall

        # Calculate and display the average pixel values
        li $t7, 0              #counter for  the original image
        li $t8, 0              # counter for  RGB values in the new image
        la $t1, image_width  

        calculate_averages:
            beq $t1, $t2, display_averages  # If the image_width pointer reaches the end, calculate and display averages

            # Calculate the sum of RGB values in the original image
            lb $t9, -3($t1)        
            lb $t10, -2($t1)       
            lb $t11, -1($t1)       

            add $t7, $t7, $t9      # Add R component to the total for original image
            add $t7, $t7, $t10     # Add G component to the total for original image
            add $t7, $t7, $t11     # Add B component to the total for original image

            # Calculate the sum of RGB values in the new image
            lb $t12, -3($t1)       # Load the modified R component
            lb $t13, -2($t1)       # Load the modified G component
            lb $t14, -1($t1)       # Load the modified B component

            add $t8, $t8, $t12     # Add modified R component to the total for new image
            add $t8, $t8, $t13     # Add modified G component to the total for new image
            add $t8, $t8, $t14     # Add modified B component to the total for new image

            addi $t1, $t1, 3       # Move image_width pointer to the next pixel
            j calculate_averages

        display_averages:
            # Calculate the number of pixels
            div $t2, $t7
            mflo $f0               # Store the result in $f0

            # Display the average pixel value of the original image
            li $v0, 2              # Load syscall code for "print float" (2)
            syscall

            # Calculate the number of pixels
            div $t2, $t8
            mflo $f0               # Store the result in $f0

            # Display the average pixel value of the new image
            li $v0, 2              # Load syscall code for "print float" (2)
            syscall

        # Exit the program
        li $v0, 10             # Load syscall code for "exit" (10)
        syscall


         