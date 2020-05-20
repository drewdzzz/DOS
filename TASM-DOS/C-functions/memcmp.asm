local @@
.model tiny
.data
string1:		db 'Anastas_Petrovich$'
string2:		db 'Anaytas_Petr$'
.code
org 100h

start:	lea di, string2
		lea si, string1
		mov cx, 7
		call memcmp
		
		mov dx, si
		mov ah, 09h
		int 21h

		mov ax, 4c00h
		int 21h
;=================================================
;Enter:	CX - size of comparing part
;		SI - ptr to first string
;		DI - ptr to second string
;
;Exit:	DI - ptr to first not equal chr in 2st string
;		SI - ptr to first not equal chr in 1st string
;
;Destr:	BX, CX
;=================================================
memcmp	proc
		cld
		mov bx, ds
		mov es, bx
		repe cmpsb
		jne @@end
		mov di, 01h
		mov si, 01h
@@end:	dec si
		dec di
		ret
		endp



end		start