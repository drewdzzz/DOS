local @@
.model tiny
.data
string1:		db 'What a beautiful print!', 00h
string2:		db 30 dup ('5'), '$'
.code
org 100h

start:	lea di, string2
		lea si, string1
		call strcpy
		
		mov dx, di
		mov ah, 09h
		int 21h
		
		mov ax, 4c00h
		int 21h
;=================================================
;Enter:		SI - address of string for copy
;			DI - address of place to copy
;
;Exit:		DI - address of new string
;
;Destr:		ES SI BX CX
;=================================================
strcpy	proc
		cld
		mov cx, di
		mov bx, ds
		mov es, bx
		
@@loop:
		mov byte ptr bl, [si]
		movsb
		cmp bl, 00h
		jz @@end_copy 
		jmp @@loop
		
@@end_copy:
		mov di, cx
		ret
		endp
		
end		start