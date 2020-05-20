local @@
.model tiny
.data
string1:		db 'ILoveVladimirPutin$'
string2:		db 10 dup ('5'), '$'
.code
org 100h

start:	lea di, string2
		lea si, string1
		mov cx, 7
		call memcpy
		
		lea dx, string2
		mov ah, 09h
		int 21h
		
		mov ax, 4c00h
		int 21h
;=================================================
;Enter:		CX - part of string to copy
;			SI - address of string for copy
;			DI - address of place to copy
;
;Exit:		NONE
;
;Destr:		ES SI DI BX
;=================================================
memcpy	proc
		cld
		mov bx, ds
		mov es, bx
		rep movsb
		ret
		endp
		
end		start