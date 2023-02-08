.eqv	error_binary -1 # error loading the binary
.eqv	error_LBMP	-2 # error loading the bitmap template
.eqv	error_SBMP	-3 # error saving the bitmap result
.eqv	error_op	-4 # error interpretting the OP

.eqv 	WIDTH	    600
.eqv	HEIGHT	    50
.eqv	ROW_SIZE	1800
.eqv	BMP_PIXELS	54			#minimal header size for 24-bit bmp

.eqv	BMP_SIZE	90122
.eqv 	OP_EOF		-1
.eqv	OP_POS		3
.eqv	OP_DIR		2
.eqv	OP_MOV		1
.eqv	OP_PEN		0


.eqv	RFILE	s0	# file handle
.eqv	RPEN	s1	# pen state
.eqv	RPOSX	s2	# position.x
.eqv	RPOSY	s3	# position.y
.eqv	RDIRX	s4	# direction.x
.eqv	RDIRY	s5	# direction.y
.eqv	R_MVAMT	s6	# movement amount
.eqv	OP		s7 	# OP value
.eqv	PIXEL	s8 	# pixel address within the bitmap (temp)

.data
.align 4  #word size
res:		.space 	2	
bitmap:		.space 	BMP_SIZE							#reserves space in memory that is the same size as bmp file
optemp:		.byte	0x00								#reserves a byte in memory
binpath:	.asciz 	"turtle.bin"
tplpath:	.asciz 	"input.bmp"
rstpath:	.asciz 	"output.bmp"

temp1:	    .asciz	"Trying to load the input bmp..."
temp2:	    .asciz	"OK\n"

bin1:	   .asciz	"Trying to open the program..."
bin2:	   .asciz	"OK!\n\tRunning...\n"
bin3:	   .asciz	"DONE\n"

str_pos:	.asciz 	"Position: "
str_dir:	.asciz 	"Direction: "
str_mov:	.asciz 	"Move: "
str_pen:	.asciz 	"Pen State: "

infbmp1:	.asciz	"Trying to save the output..."
infbmp2:	.asciz	"OK\n"

strmid:		.asciz 	", "		

inferr:		.asciz 	"ERROR\n"				
		        # 	00 01 10 11
Y:	.word	0, 1, 0, -1 #we create vectors for the position, 
X:	.word	1, 0, -1, 0

.macro print_str(%addr)
	li		a7, 4
	la		a0, %addr
	ecall
.end_macro

.macro print_int(%value)
	li		a7, 1
	li		a0, %value
	ecall
.end_macro

.macro print_reg(%reg)
	li		a7, 1
	mv		a0, %reg
	ecall
.end_macro

.macro print_char(%value)
	li		a7, 11
	li		a0, %value
	ecall
.end_macro

.macro exit(%code)
	li		a7, 93
	li		a0, %code
	ecall
.end_macro

.macro open(%path, %flags, %handle, %err) #macro to open a file
	li		a7, 1024
	la		a0, %path
	li		a1, %flags
	ecall
	bltz	a0, %err
	mv		%handle, a0
.end_macro	

.macro read(%handle, %addr, %maxlen, %err) #macro to read a file
	li		a7, 63
	mv		a0, %handle
	la		a1, %addr
	li		a2, %maxlen
	ecall
	blez	a0, %err   #we will jump to appropriate error handling label in case of an error
.end_macro

.macro write(%handle, %addr, %buflen, %err)
	li		a7, 64
	mv		a0, %handle
	la		a1, %addr
	li		a2, %buflen
	ecall
	bne		a0, a2, %err
.end_macro

.macro close(%handle)
	li		a7, 57
	mv		a0, %handle
	ecall
.end_macro

.text
main:
	# open the template
	print_str(temp1)
	open(tplpath, 0, RFILE, handle_error_LBMP) #Opening in read-only mode, we are outputting the file descriptor to RFILE (register s0)
	print_str(temp2)
	# read the template
	read(RFILE, bitmap, BMP_SIZE, handle_error_LBMP) #read the file with the file descriptor obtained from open macro, and outputs the length read into a0
	close(RFILE) #close the file
	
	print_str(bin1)
	open(binpath, 0, RFILE, h_errbin) #opening the binary file in read-only, saving file descriptor in RFILE (s0)
	print_str(bin2)
bin_loop:
	jal		read_OP				#jump and link into the loop that extracts 
	
	li		t0, OP_EOF				#we load end of file OP into t0
	beq		OP, t0, bin_done	#we compare, and see if we have reached end of file, if yes, we branch to bin_done, which means we have finished reading the file
	
	andi	t1, OP, 3			#we copy the least significant 2 bits into t1, to see what instruction we have
		
	print_char('[')
	print_reg(t1)
	print_char(']')

	li		t0, OP_POS				#we load OP for set position command
	beq		t1, t0, handle_pos		#we check if the instruction we have is indeed set position, if so, we move into the label to handle set position command
	li		t0, OP_MOV				#and so on for other OPs and commands
	beq		t1, t0, handle_mov
	li		t0, OP_DIR
	beq		t1, t0, handle_dir
	li		t0, OP_PEN
	beq		t1, t0, handle_pen	
	
handle_pos:							#handle position, handles set position command
	srli	OP, OP, 2		#we shift everything to the right by 2 positions,
	andi	t0, OP, 63			#we use binary value of 63 (111111) to extract bits 0-5, which now contain our y coordinates
	mv	RPOSY, t0				#we use extracted value and load it into RPOSY (s3)
	srli	OP, OP, 13		#we shift to the right by 13, and now the bits for the X position will take up bits 0-9
	andi	t0, OP, 1023		#we use binary value of 1023 (1111111111) to extract bits 0-9 from our instruction command
	mv	RPOSX, t0				#we copy extracted value to RPOSX (s2)
	print_str(str_pos)
	print_reg(RPOSX)
	print_str(strmid)
	print_reg(RPOSY)
	print_char('\n')
	j		bin_loop	
handle_dir:							
	srli	OP, OP, 14
	andi	OP, OP, 3
	slli	OP, OP, 2		#multiply by 4 because we are loading words from memory, size is 4, turn it into offset for which we will use with our normal values
	la		t0, X			#load address of normal X values
	add		t0, t0, OP		#increment by the offset
	lw		RDIRX, (t0)		#load the value t0 is pointing to into RDIRX (s4)
	la		t0, Y			#load address of normal Y values
	add		t0, t0, OP		#increment by the offset
	lw		RDIRY, (t0)		#load the value t0 is pointing to into RDIRY (s5)
	print_str(str_dir)
	print_reg(RDIRX)
	print_str(strmid)
	print_reg(RDIRY)
	print_char('\n')
	j		bin_loop
handle_mov:
	srli	OP, OP, 6		   #at this point we already know we are working with move command, so we shift everything 6 positionsr
	andi	R_MVAMT, OP, 1023  #here, because we have 10 bits, we will andi with 1024-1= 1023 to extract bits m0-m9
	print_str(str_mov)
	print_reg(R_MVAMT)
	print_char('\n')

draw_loop:								
	blez	R_MVAMT, draw_done
	blez	RPOSX, draw_done	 #these check when drawing is done
	blez	RPOSY, draw_done
	li		t0, WIDTH
	bge		RPOSX, t0, draw_done #here we check if we are withing the boundaries of our bmp file
	li		t0, HEIGHT
	bge		RPOSY, t0, draw_done	
		
	andi	t0, RPEN, 1			 #here we check if the pen state is 0, if so, then we move to the loop that draws gaps
	beqz	t0, draw_step
	
	la		PIXEL, bitmap			  #we load address of bitmap into PIXEL register (s8)
	addi	PIXEL, PIXEL, BMP_PIXELS  #offset of the header
	li		t2, ROW_SIZE			  #this value represents bytes per row
	mul		t1, RPOSY, t2		      #multiple y by stride, to get offset of the scan line
	add		PIXEL, PIXEL, t1		  #add it to address of pixel buffer
	li		t1, 3					  #we multiply by 3 because thats the size of the pixel we want to get within the scan line
	mul		t1, RPOSX, t1	
	add		PIXEL, PIXEL, t1		  #add it to address of pixel buffer
	
	# blue
	srli	t0, RPEN, 1
	andi	t1, t0, 15
	slli	t2, t1, 4			   	 #to convert it into 1 byte space, so that we can offset properly
	sb		t2, 2(PIXEL)
	
	# green
	srli	t0, t0, 4
	andi	t1, t0, 15
	slli	t2, t1, 4
	sb		t2, 1(PIXEL)
	
	# red
	srli	t0, t0, 4
	andi	t1, t0, 15
	slli	t2, t1, 4
	sb		t2, 0(PIXEL)
	
	print_str(str_pos)
	print_reg(RPOSX)
	print_str(strmid)
	print_reg(RPOSY)
	print_char('\n')
	
draw_step:										
	addi	R_MVAMT, R_MVAMT, -1
	add		RPOSX, RPOSX, RDIRX
	add		RPOSY, RPOSY, RDIRY	
	j		draw_loop
draw_done:
	
	j		bin_loop
handle_pen:	
	srli	RPEN, OP, 3
	print_str(str_pen)	
	print_reg(RPEN)
	print_char('\n')
	j		bin_loop
bin_done:
	print_str(bin3)
	close(RFILE)
	
	# open/create the result file
	print_str(infbmp1)
	open(rstpath, 1, RFILE, h_errbmp)
	print_str(infbmp2)
	# write the result
	write(RFILE, bitmap, BMP_SIZE, h_errbmp)
	close(RFILE)
	
	# no error termination
	exit(0)
	
h_errbin:
	print_str(inferr)
	exit(error_binary)
h_errbmp:
	print_str(inferr)
	exit(error_SBMP)
handle_error_LBMP:
	print_str(inferr)
	exit(error_LBMP)
handle_error_op:
	print_str(inferr)
	exit(error_op)

read_OP:
	mv		OP, zero							#sets the OP register (s7) to 0
	read(	RFILE, optemp, 1, read_OP_eof)	#we read 1 byte at a time, assigning it to the optemp byte we reserved previously.
	lbu		t0, optemp		#we load optemp into t0, first byte from bin file
	slli	OP, t0, 8			#shift left by 8 to make room for the next byte, load into s7
	read(	RFILE, optemp, 1, read_OP_eof)	#we read 2nd byte
	lbu		t0, optemp              #we load optemp into t0, for reading 2nd byte from bin file
	or		OP, OP, t0		#load the second byte into bits 0-7 in OP (s7)
	
	li		t0, OP_POS	        #We load the OP for set position instruction into t0 to check if the instruction we have loaded is indeed a set position instruction,"4 bytes"
	andi	t1, OP, 3			#We perform andi to copy last 2 bits from the 2 bytes we have extracted so far from the binary file, 3='11'
	bne		t1, t0, read_OP_done	#We check t0 and t1 where t0 is set postion instruction.are equal or not.
						    # if equal We extract another 2 bytes from the binary file if they are equivalent;
						    #  if they are not equal, that means we are done extracting their no set posyion
	read(	RFILE, optemp, 1, read_OP_eof)	#We read the 3 byte from binary files
	lbu		t0, optemp								
	slli	t0, t0, 24			#					
	or		OP, OP, t0		#				
	read(	RFILE, optemp, 1, read_OP_eof)	#We read the 4 byte from binary files
	lbu		t0, optemp              #
	slli	t0, t0, 16                      #
	or		OP, OP, t0              #
read_OP_done:
	ret	                          	#done reading, going back to bin_loop
read_OP_eof:
	li		OP, OP_EOF	       #we load end of file OP into OP (s7)
	ret
