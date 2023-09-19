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
