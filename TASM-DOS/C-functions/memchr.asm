local @@
.model tiny
.data
string:		db '12dhsn3 -> F <- the first letter gdghdg5htd$'
.code
org 100h

start:	lea di, string
		mov cx, 10
		mov al, 'F'
		call memchr
		
		mov dx, di
		mov ah, 09h
		int 21h
		
		mov ax, 4c00h
		int 21h
;=================================================
;Enter:		CX - size of piece of string
;			DI - address of string
;			AL - symbol for searching	
;
;Exit:		DI - addres of symbol 
;
;Destr:		ES CX BX	
;=================================================
memchr	proc
		cld
		mov bx, ds
		mov es, bx
		repne scasb
		jz @@end
		mov di, 01h
@@end:	dec di		
		ret
		endp

end		start