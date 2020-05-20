local @@
.model tiny
.data
string:		db '12dhsn3FThat was 1st F letter g5htd$'
.code
org 100h

start:	lea di, string
		mov al, 'F'
		call strchr
		
		mov dx, di
		mov ah, 09h
		int 21h
		
		mov ax, 4c00h
		int 21h

;=================================================
;Entry:		DI - address of string
;			AL - ASCII code of char 
;
;Exit:		DI - address of char in string, 0 if not found
;
;Destr:		BX ES
;=================================================

strchr	proc
		cld
		mov bx, ds
		mov es, bx

@@loop:	mov byte ptr bl, es:[di]
		cmp bl, 00h
		jz @@no_chr
		scasb
		jz @@found
		jmp @@loop

@@found:
		dec di
		ret
		
@@no_chr:
		mov ah, 00h
		ret
		endp
		
end		start