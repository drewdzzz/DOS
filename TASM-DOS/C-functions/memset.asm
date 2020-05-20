local @@
.model tiny
.data
string:		db 'I dont use C, I create it$'
.code
org 100h

start:	lea di, string
		mov cx, 7
		mov al, 'A'
		call memset
		
		lea dx, string
		mov ah, 09h
		int 21h
		
		mov ax, 4c00h
		int 21h
;=================================================
;Entry	AL - char attr
;		DI - address to set
;		CX - size of setting part
;
;Destr:	ES CX DI BX
;=================================================
memset	proc
		mov bx, ds
		mov es, bx
		rep stosb
		ret
		endp
		
end 	start
		