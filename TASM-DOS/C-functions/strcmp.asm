local @@
.model tiny
.data
string1:		db 'Comparing strinas$', 00h
string2:		db 'Comparing strings$', 00h
.code
org 100h

start:	lea di, string2
		lea si, string1
		call strcmp
		
		mov dl, bl
		mov ah, 02h
		int 21h
		
		mov ax, 4c00h
		int 21h
;=================================================
;Enter:		SI - address of 1st string
;			DI - address of 2nd string
;
;Exit:		BL - ans
;
;Destr:		ES BH
;=================================================
strcmp	proc
		cld 

		mov bx, ds
		mov es, bx

		xor bx, bx
@@loop:	cmp byte ptr ds:[si], 00h
		jz @@end_first
		cmp byte ptr es:[di], 00h
		jz @@end_second
		cmpsb
		je @@loop

		dec si
		dec di
		mov bl, es:[di]
		cmp byte ptr ds:[si], bl
		jb @@second_more
		mov bl, 01h
		ret
		
@@second_more:	
		mov bl, 02h
		ret

@@end_first:	
		cmp byte ptr es:[di], 00h
		jz @@equal

@@end_second:	
		cmp byte ptr ds:[si], 00h
		jz @@equal

@@equal:
		ret
		endp
		
end		start