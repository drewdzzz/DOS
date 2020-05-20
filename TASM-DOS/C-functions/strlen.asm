locals @@
.model tiny
.data
string:	db '12345678901234', 00h
.code
org 100h
start:
	lea di, string
	call strlen
	
	mov ah, 02h
	int 21h

	mov ax, 4c00h
	int 21h
;=================================================
;Entry:		DI - ADDRESS OF STRING
;
;Exit:		DX - length of string
;
;Destr:		ES AH 	
;Note:		using CLD
;=================================================
strlen	proc
	cld
	mov ax, ds
	mov es, ax
	mov dx, di
	xor al, al

	repne scasb
	sub di, dx
	mov dx, di
	dec dx
	ret
	endp


end	start	