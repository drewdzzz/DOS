local @@
.model tiny
.data
buffer db '$$$$$$$$$$$$$$$'
msg_address dw 00h

;------------------Console Arguments----------------
;1)top left corner x-coordinate
;2)top left corner y-coordinate
;3)height
;4)width
;5)Graphic mode:
;0 - standard graphics
;1 - pseudo graphics
;2 - custom mode (+6 ASCII symbols to draw a frame with)
;6)String to print (with $ in the end)
;------------------Console Arguments----------------


;------------------Symbols fo frame-----------------
;Top left corner -> Top right corner -> bottom left corner -> bottom rigth corner -> vertical edge -> horizontal edge
graphics	db 201d, 187d, 200d, 188d, 186d, 205d 
symbols		db '#',	 '^',  '$',  '@',  '|',  '-'
;------------------Symbols fo frame-----------------
.code
org 100h
;---------------------------------------------------
VIDEOSEG				equ 0B800h
SCR_HEIGTH				equ 25d
SCR_WIDTH				equ 80d
HEIGTH					equ 15d 
WIDTH   				equ 40d
VER_OFFSET				equ 05d
HOR_OFFSET				equ 20d
PIXEL_SIZE				equ 02d
COLOUR 					equ 4eh
;HIGH_LEFT_CORNER		equ 201d
;HIGH_RIGHT_CORNER 		equ 187d
;LOW_LEFT_CORNER		equ 200d
;LOW_RIGHT_CORNER		equ 188d
;VERTICAL_EDGE			equ 186d
;HORIZONTAL_EDGE		equ 205d
ANIM_DEPTH				equ 3d
SLEEP					equ 40000d
MIN_SIZE				equ 3d

.set_ax_min_if_few1	macro
					cmp ax, MIN_SIZE
					jae	normal_size1
					mov ax, MIN_SIZE					
normal_size1:		
					endm
					
.set_ax_min_if_few2	macro
					cmp ax, MIN_SIZE
					jae	normal_size2
					mov ax, MIN_SIZE					
normal_size2:		
					endm
;---------------------------------------------------
start:		
;---------------Read arguments--------------------------
		mov di, 81h
		call read_arg
		push dx
		call read_arg
		push dx
		call read_arg
		push dx
		call read_arg
		push dx
		
		call read_arg
		inc di
		
		call choose_graphics_mode_and_skip
		
		lea bx, msg_address
		mov word ptr [bx], di
											;Mode has been chosen
;---------------Arguments were read---------------------
		
		xor ch, ch
		mov cl, ANIM_DEPTH
animation:
		mov bp, sp
		
		push cx
		push [bp+6]
		push [bp+4]
		xor ah, ah
		mov al, byte ptr[bp+2]
		div cl
		xor ah, ah
		
		.set_ax_min_if_few1
		
		push ax
		
		xor ah, ah
		mov al, byte ptr [bp]
		div cl
		xor ah, ah
		
		.set_ax_min_if_few2
		
		push ax
		
		call draw_frame
		xor cx, cx
		mov dx, SLEEP
		mov ah, 86h
		int 15h
		pop cx cx cx cx cx
		LOOP animation

;---------------SHADOW MAKER-------------------------------

;---------------Calculate cursor position------------------
		;add di, (SCR_WIDTH - WIDTH + 1) * PIXEL_SIZE + 1
		
		xor ah, ah
		add di, SCR_WIDTH * 2
		mov bp, sp
		mov al, byte ptr [bp]
		mov dl, 2
		mul dl
		sub di, ax
		add di, 3
;---------------Cursor positon calculated------------------


		mov al, 00f7h
		mov ah, 70h
		mov dl, byte ptr [bp]            ;Set lower shadow's line length
		
		call draw_shad	

;---------------Calculate cursor position------------------
		;mov di, ( (SCR_WIDTH*VER_OFFSET)+HOR_OFFSET + WIDTH) * PIXEL_SIZE + 1
		mov al, SCR_WIDTH
		mov dl, byte ptr [bp + 4]
		mul dl
		add al, byte ptr [bp + 6]
		adc ah, 0
		add al, byte ptr [bp]
		adc ah, 0
		shl ax, 1
		inc ax
		mov di, ax
;---------------Cursor positon calculated------------------		
		
		
		mov al, 00f7h
		mov ah, 70h
		mov bp, sp
		mov cx, [bp + 2]					;Set heigth of vertical shadow line
shad_loop:									;draw verical shadow line
		add di, SCR_WIDTH * PIXEL_SIZE		
		mov dl, 01h
		call draw_shad
		sub di, 2
		LOOP shad_loop


;---------------SHADOW MAKER END---------------------------

;---------------PRINT TEXT---------------------------------
		
		mov bp, sp
		
		lea bx, msg_address
		mov di, word ptr [bx]
		
		call strlen
		mov di, cx
		
		;-------Calculating position for text-----------------
		xor ah, ah
		mov al, [bp + 2]
		mov cl, 2
		div cl
		
		mov cl, al
		add cl, [bp + 4]
		mov ax, SCR_WIDTH
		mul cl
		
		add al, [bp + 6]
		
		mov bx, ax
		xor ah, ah
		mov al, [bp]
		mov cl, 2
		div cl
		xor ah, ah
		add bx, ax
				
		mov ax, di
		mov cl, 2		
		div cl

		xor ah, ah

		sub bx, ax
		mov di, bx
		
	
		shl di, 1
		;-------Calculated position for text------------------
		
		
		lea bx, msg_address
		mov si, word ptr [bx]
		
		mov bx, VIDEOSEG
		mov es, bx
		cld
		mov cx, 0ffffh
		
print_loop:
		movsb
		inc di
		cmp byte ptr [si], '$'
		jz printed
		loop print_loop

printed:

;---------------PRINT TEXT---------------------------------

		ending:
		mov ax, 4c00h
		int 21h
	
;---------------PROCEDURES---------------------------------
	
;=================================================
;Entry:		AH - colour attr
;		AL - char attr
;		CX - number of repeats
;		ES - segment for STOSW
;		DI - address for STOSW
;
;Destr:	CX DI*
;		* DI += CX * 2
;=================================================
draw		proc
		rep stosw
		ret
draw	endp
		
;=================================================
;Entry:	CX - length of line
;		AH - colour attr
;		BH - left chr
;		BL - rigth chr
;		DL - center char
;		DI - address of beginning of the line
;
;Exit:	CX - number of repeats (the same)
;Destr:	DI, AL
;=================================================
draw_pryamaya	proc
		push VIDEOSEG
		pop es
		
		push cx
		mov al, bh
		mov cx, 01h
		call draw
		
		mov al, dl
		pop	cx
		push cx
		dec cx
		dec cx
		call draw		

		mov al, bl
		mov cx, 01h
		call draw
		pop cx		
		ret
draw_pryamaya	endp




;=================================================
;Entry: 	AH - colour
;			AL - mask for colour
;			DI - address of beginning
;			DL - number of repeats
;Exit:		ES - address of VIDEOSEG
;Destr:		BX DL
;=================================================
draw_shad	proc

		mov bx, VIDEOSEG
		mov es, bx
		mov byte ptr es:[di], ah
		and es:[di], al
		add di, 2
		dec dl
		jz shad_draw_ending
		jmp draw_shad
		shad_draw_ending:
		ret
		endp
		
;=================================================		
;Stk_Entry:	X, Y coord of top left corner, heigth, width
;Entry:		SI - addres of buffer with chars (watch th beginning of the file)
;Destr:		DI, DL, AX, BX, BP, CX
;Note:		using CLD
;=================================================

draw_frame	proc
		cld
		mov bp, sp
		add bp, 02h
		xor ch, ch
		mov cl, byte ptr [bp]						;Set width
			
		mov bh, byte ptr [si]					;Set high left corner chr
		mov bl, byte ptr [si+1]					;Set high right corner chr
			
		;===Start point calcualting================	
		mov al, SCR_WIDTH
		mul byte ptr [bp+4]
		add al, byte ptr[bp+6]
		shl ax, 01d									;ax*PIXEL_SIZE
		mov di, ax
		;===Start point calcualted=================		;Set position of cursor	
		
		
		mov ah, COLOUR								;Set colour
		mov dl, byte ptr [si+5]						;Set horizontal edge chr for upper edge of frame
		
		call draw_pryamaya							;draw line from position = DI with length = CX



		mov bh, byte ptr [si+4]						;Line symbol for left edge of frame
		mov bl, byte ptr [si+4]						;Line symbol for rigth edge of frame
		xor dl, dl									;\0 for interior
			
		mov cl, byte ptr [bp+2]
		xor ch, ch
		dec cl										;Heigth of interior
		dec cl
draw_interior:											
			
		;===Cursor position calculating=============	;Move cursor to the next line
		push ax										;Save AX
		xor ax, ax
		mov al, SCR_WIDTH
		sub al, byte ptr [bp]
		shl ax, 1
		add di, ax
		pop ax										;Save AX
		;===Cursor position calculated==============	
		
		push cx
		xor cx, cx
		;Save CX for loop
		mov cl, byte ptr [bp]						;Set length of line
		call draw_pryamaya							;Draw line with length = CX
		pop cx										;Save CX for loop
		LOOP draw_interior							;LOOP drawing interior

		mov cl, byte ptr [bp]
		mov ah, COLOUR
		mov bh, byte ptr [si+2]
		mov bl, byte ptr [si+3]
		mov dl, byte ptr [si+5]
			
		;===Cursor position calculating=============	;Move cursor to the next line
		push ax										;Save AX
		xor ax, ax
		mov al, SCR_WIDTH
		sub al, byte ptr [bp]
		shl ax, 1
		add di, ax
		pop ax										;Save AX
		;===Cursor position calculated==============
		call draw_pryamaya

		ret
		endp
			
;=================================================	
;Entry: DI - address of reading argument in PSP
;		buffer - part of memory for translating an argument
;Exit:	DL - argument
;		ES - address of PSP
;		DI - address of space before next argument (if it exists)
;
;Destr:	AX BX SI
;Note:	using STD
;=================================================	
read_arg 	proc			
		mov ah, 62h					;Get PSP address
		int 21h	
		mov es, bx

		lea si, buffer
			
		xor dx, dx
		mov bl, 01d
@@copy_num:
		mov al , byte ptr es:[di]
		mov [si], al
		inc di
		cmp byte ptr es:[di], 0dh
		jz @@trans
		cmp byte ptr es:[di], ' '
		jz @@trans
		inc si
		jmp @@copy_num
@@trans:
		std
		lodsb
			
		cmp al, ' '
		jz @@fin
		sub al, '0'
		mul bl
		add dl, al
		mov al, bl
		mov bl, 10d
		mul bl
		mov bl, al
		jmp @@trans
@@fin:
		ret
		endp


;=================================================
;Entry:		DL - graphics mode
;			DI - address of symbols in PSP (for custom mode)
;
;Exit:		SI - address of graphic buffer
;			DI - addres of next argument
;Note:		using CLD
;Destr:		ES AL 
;=================================================
choose_graphics_mode_and_skip	proc
	
		cmp dl, 01h
		jz @@symbols 
		cmp dl, 02h	
		jz @@custom
		lea si, graphics
		jmp @@fin

@@symbols:
		lea si, symbols
		jmp @@end
		
@@custom:
		mov si, di
		cld
		push ds
		pop es
		mov al, ' '
		repne scasb
@@end:	
		ret	
		endp
		
;=================================================
;Entry:		DI - ADDRESS OF STRING
;			DS - Segment address for string
;
;Exit:		CX - length of string
;
;Destr:		AH DI ES
;Note:		using CLD
;=================================================
strlen	proc
		cld
		mov cx, ds
		mov es, cx
		mov cx, 00ffffh
		mov al, '$'
		
		repne scasb
		
		neg cx
		dec cx
		dec cx
		ret
		endp

end 		start