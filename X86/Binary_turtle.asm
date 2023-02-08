
bits 32

;	extern int turtle(
;		unsigned char *dest_bitmap,
;		unsigned char *commands,
;		unsigned int commands_size
;	);

%define OP_POS 3 ;3 means command is for position of turtle
%define OP_DIR 2 ;2 means command is for direction of turtle
%define OP_MOV 1 ;1 means command is for movement of turtle
%define OP_PEN 0 ;0 means command is for pen state of turtle

global turtle ; Declare turtle function as global
global _turtle ; Declare _turtle function as global

SECTION .data ; Data section
align 4

normal_y:	dd 0, 1, 0, -1 ;x direction for normal_x
normal_x:	dd 1, 0, -1, 0 ;y direction for normal_y

SECTION .text ; Text section
align 4

; arguments
%define dest_bitmap 	ebp+8 ; address of destination bitmap
%define commands 		ebp+12 ;address of where our commands begin (beginning of binary file)
%define commands_size 	ebp+16 ;size of the binary file we read in C
; stack variables
%define pos_x 			ebp-4 ;x position of turtle
%define pos_y 			ebp-8 ;y position of turtle
%define dir_x 			ebp-12 ;x direction of turtle
%define dir_y 			ebp-16 ;y direction of turtle
%define command			ebp-20 ; command for turtle
%define turtlepc		ebp-24 ;program counter for turtle
%define movement 		ebp-28 ;movement of turtle
%define penstate 		ebp-32 ;pen state of turtle
%define frame_size 			32 ;frame size

turtle:
_turtle:
	push 	ebp ;save current base pointer
	mov 	ebp, esp ;set new base pointer to current stack pointer
	; prepare local variables
	sub		esp, frame_size ;make room for local variables
	mov		[pos_x], dword 0 ;initialize pos_x to 0
	mov		[pos_y], dword 0 ;initialize pos_y to 0
	mov		[dir_x], dword 0 ;initialize dir_x to 0
	mov		[dir_y], dword 0 ;initialize dir_y to 0
	mov		[command], dword 0 ;initialize command to 0
	mov		[movement], dword 0 ;initialize movement to 0
	mov		[penstate], dword 0 ;initialize penstate to 0
	mov		[turtlepc], dword 0 ;initialize turtlepc to 0
	
bin_loop:
	mov		eax, [turtlepc] ;move turtlepc to eax
	cmp		eax, [commands_size] ;compare turtlepc with commands_size
	jge		bin_done ;if turtlepc >= commands_size goto bin_done
	
	xor		edx, edx ;clear edx
	add		eax, [commands] ;add eax with commands, we start reading bytes from read bin file
	
	mov		dh, [eax];move the value of eax to dh, we load the byte associated with the address in eax, into dh
    inc     eax ;increment eax by 1, we are now looking at the subsequent byte
    mov     dl, [eax] ;move the value of eax to dl, 
    inc     eax ;increment eax by 1
    sub     eax, [commands] ;subtract eax with commands
    mov  [turtlepc], eax ;move eax to turtlepc
    mov [command], edx ;move edx to command
	
   and		edx, 3 ;and edx with 3
   cmp		edx, OP_POS ;compare edx with OP_POS
   je		handle_pos ;if equal jump to handle_pos
   cmp		edx, OP_DIR ;compare edx with OP_DIR
   je		handle_dir ;if equal jump to handle_dir
   cmp		edx, OP_MOV ;compare edx with OP_MOV
   je		handle_mov ;if equal jump to handle_mov
   cmp		edx, OP_PEN ;compare edx with OP_PEN
   je		handle_pen ;if equal jump to handle_pen

handle_pos:
  mov eax, [command] ;move command to eax
  shr eax, 2 ;we shift everything to the right by 2 positions, because we already know what instruction we are working with, this will make extracting the rest of the parameters from the instruction easier
  and eax, 63 ;we use binary value of 63 (111111) to extract bits 0-5, which now contain our y coordinates
  mov [pos_y], eax ;move eax to pos_y, we use extracted value and load it into POS_Y 
  mov eax, [turtlepc] ;move turtlepc to eax
  cmp eax, [commands_size] ;compare turtlepc with commands_size
  jge bin_error ;if turtlepc >= commands_size jump to bin_error
  xor edx, edx ;clear edx
  add eax, [commands] ;add eax with commands
  mov dh, [eax] ;move the value of eax to dh
  inc eax ;increment eax by 1
  mov dl, [eax] ;move the value of eax to dl
  inc eax ;increment eax by 1
  sub eax, [commands] ;subtract eax with commands
  mov [turtlepc], eax ;move eax to turtlepc
  mov [command], edx ;move edx to command
  and edx, 1023 ;and edx with 1023  we use binary value of 1023 (1111111111) to extract bits 0-9 from our instruction command
  mov [pos_x], edx ;move edx to pos_x
  jmp bin_loop ;jump to bin_loop

handle_dir:
  mov eax, [command] ;move command to eax
  shr eax, 14 ;shift right eax by 14
  and eax, 3 ;and eax with 3
  shl eax, 2 ;multiply by 4 because we are loading words from memory, size is 4, turn it into offset for which we will use with our normal values
  mov ecx, dword [eax+normal_x] ;move normal_x to ecx
  mov edx, dword [eax+normal_y] ;move normal_
  mov [dir_x], ecx ;move ecx to dir_x
  mov [dir_y], edx ;move edx to dir_y
  jmp bin_loop ;jump to bin_loop

handle_mov:; code to handle movement of turtle
  mov eax, [command] ;move command to eax
  shr eax, 6 ;shift right eax by 4#at this point we already know we are working with move command, so we shift everything 6 positions to the right in order to make the copying of m0-m9 easier
  and eax, 1023 ;and eax with 1023#here, because we have 10 bits, we will and with 1024-1= 1023 to extract bits m0-m9
  mov [movement], eax ;move eax to movement

draw_loop:
	; loop for drawing turtle position on the bitmap
	mov		eax, [movement] ;move movement to eax
	test	eax, eax ;check if eax is zero
	jz		bin_loop ;if eax is zero, jump to bin_loop
	mov		eax, [pos_x] ;move pos_x to eax
	cmp		eax, 600 ;compare eax with 600 // width
	jge		bin_loop ;if eax >= 600 jump to bin_loop
	cmp		eax, -1 ;compare eax with -1
	jle		bin_loop ;if eax <= -1 jump to bin_loop
	mov		eax, [pos_y] ;move pos_y to eax
	cmp		eax, 50 ;compare eax with 50 ///bmp hight
	jge		bin_loop ;if eax >= 50 jump to bin_loop
	cmp		eax, -1 ;compare eax with -1
	jle		bin_loop ;if eax <= -1 jump to bin_loop
	mov		eax, [penstate] ;move penstate to eax
	and		eax, 1 ;and eax with 1
	test	eax, eax ; check eax is zero or not
	jz		draw_step ;if eax is zero then jump to draw_step
draw_fill:
; code for filling color on the bitmap
mov eax, [pos_x] ;move pos_x to eax
lea eax, [eax+eax*2] ;calculate offset of x position in bitmap
mov ecx, [pos_y] ;move pos_y to ecx
imul ecx, 1800 ;multiply pos_y by 1800 this value represents bytes per row
add eax, ecx ;add offset of y position to offset of x position
add eax, [dest_bitmap] ;add dest_bitmap to eax to get the final memory location
mov		edx, [penstate] ;move penstate to edx
shr		edx, 1 ;shift right edx by 1 #we the shifting right to redad ud pen state
mov		ecx, edx ;move edx to ecx
and		ecx, 15 ;and ecx with 15 # we r copy lest significat bites (15(1111) ,wr extarct 4 bit
shl		ecx, 4 ;shift left ecx by 4 #shifting to the left because color bits take up upper 4 bits of the byte
mov		[eax], cl ;move ecx to memory location
dec		eax ;decrement eax
shr		edx, 4 ;shift right edx by 4
mov		ecx, edx ;move edx to ecx
and		ecx, 15 ;and ecx with 15
shl		ecx, 4 ;shift left ecx by 4
mov		[eax], cl ;move ecx to memory location
dec		eax ;decrement eax	
shr		edx, 4 ;shift right edx by 4
mov		ecx, edx ;move edx to ecx
and		ecx, 15 ;and ecx with 15
shl		ecx, 4 ;shift left ecx by 4
mov		[eax], cl ;move ecx to memory location
dec		eax ;decrement eax

draw_step:
	; code for performing a step in drawing
	dec		dword [movement] ;decrement movement by 1
	mov		eax, [pos_x] ;move pos_x to eax
	add		eax, [dir_x] ;add dir_x to eax
	mov		[pos_x], eax ;move eax to pos_x
	mov		eax, [pos_y];move pos_y to eax
	add     eax, [dir_y] ;add dir_y to eax
    mov    [pos_y], eax ;move eax to pos_y
    jmp    draw_loop ;jump to draw_loop
draw_done:
    jmp   bin_loop ;jump to bin_loop
handle_pen:
; code to handle pen state of turtle
    mov    eax, [command] ;move command to eax
    shr    eax, 3 ;shift right eax by 3
    mov   [penstate], eax ;move eax to penstate
    jmp   bin_loop ;jump to bin_loop
bin_done:
    xor   eax, eax ;clear eax
turtle_return:
; code for cleaning up stack frame and returning
   mov   esp, ebp ;move esp to ebp
   pop   ebp ;pop ebp
   ret ;return
bin_error:
; code for error handling
   mov  eax, -1 ;move -1 to eax
   jmp  turtle_return ;jump to turtle_return
