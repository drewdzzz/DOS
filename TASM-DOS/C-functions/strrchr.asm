local @@
.model tiny
.data
string:		db 'hdsj F hdsjh F ae F <- last letter$'
.code
org 100h

start:	lea di, string
		mov al, 'F'
		call strchr
		
		mov dx, bx
		mov ah, 09h
		int 21h
		
		mov ax, 4c00h
		int 21h

;=================================================
;Entry:		DI - address of string
;			AL - ASCII code of char 
;
;Exit:		BX - address of char in string, 0 if not found
;
;Destr:		CX ES
;=================================================

strchr	proc
		cld
		mov bx, ds
		mov es, bx
		xor bx, bx

@@loop:	mov byte ptr cl, es:[di]
		cmp cl, 00h
		jz @@end_search
		scasb
		jnz @@loop
		mov bx, di
		dec bx
		jmp @@loop

@@end_search:
		ret
		endp
		
end		start