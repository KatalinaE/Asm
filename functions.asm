.model tiny
.code
org 100h

Start:		
		mov ax, 4C00h
		int 21h

;=================================================
;===================MEMCHR========================
;Return first occurrence of the character from AL 
;	      in the first N symbols of Data or 0.
;Entry: AL - character
;	CX - N
;	DI - pointer to the Data
;Exit: BX - position of first occurrence
;Destr: DI, CX
;=================================================
memchr 		proc
		cld
		repne scasb		

		xor bx, bx
		
		dec di
		cmp byte ptr [di], al
		je Founded
		ret

Founded:	mov bx, di
		ret
		endp

;=================================================
;===================MEMCMP========================
;Compares the first N characters of strings. 
;Returns 0 if equal, >0 if Data1 is greater Data2,
;           and <0 if Data2 is greater than Data1.
;Entry: CX - N
;	SI - pointer to the Data1
;	DI - pointer to the Data2
;Exit: AX - answer
;Destr: SI, DI, CX
;=================================================
memcmp 		proc
		cld
		repe cmpsb
		je Return

NotEq:		dec si
		dec di
		
		mov al, byte ptr [si]
		sub al, byte ptr [di]

Return:		ret
		endp

;=================================================
;===================MEMCPY========================
;Copies N characters from Data2 to Data1.
;Entry: DI - pointer to Data1
;	SI - pointer to Data2
;	CX - N
;Exit:	BX - pointer to Data1
;	CX is always 0
;Destr: SI, DI
;=================================================
memcpy		proc
		mov bx, di

		cld
		rep movsb

		mov byte ptr [di], '$'

		ret
		endp

;=================================================
;===================MEMSET========================
;Fills N Data elements with a specific character.
;Entry: DI - pointer to Data
;	CX - N
;	AL - character
;Exit: 	BX - pointer to Data
;	CX is always 0
;Destr: DI
;=================================================
memset		proc
		mov bx, di
	
		cld
		rep stosb
		
		mov byte ptr [di], '$'
		
		ret
		endp

;=================================================
;===================STRCHR========================
;Searches for the first occurrence of a character 
;                                        in Data.
;Entry: BX - pointer to Data
;	AL - character
;Exit: 	DI - pointer to the first occurrence or 0
;Destr: BX
;=================================================
strchr		proc
		xor di, di

Next:		cmp byte ptr [bx], '$'
		je Return
		
		cmp byte ptr [bx], al
		je Found

		inc bx
		jmp Next

Found:		mov di, bx

Return:		ret
		endp

;=================================================
;===================STRCMP========================
;Compares strings. 
;Returns 0 if equal, >0 if Data1 is greater Data2,
;           and <0 if Data2 is greater than Data1.
;Entry: SI - pointer to Data1
;	DI - pointer to Data2
;Exit: 	AX
;Destr: SI, DI, DX
;=================================================
strcmp		proc
		xor ax, ax
		xor dx, dx

Next:		mov al, byte ptr [si]
		mov dl, byte ptr [di]

		cmp al, '$'
		je EndData1

		cmp al, dl
		jne Difference

		inc si
		inc di
		jmp Next

EndData1:	cmp dl, '$'
		je Return
		mov al, -1
		jmp Return

Difference:	sub al, dl		

Return:		ret
		endp

;=================================================
;===================STRCPY========================
;Copies Data2 to Data1.
;Entry: SI - pointer to Data1
;	DI - pointer to Data2
;Exit:	BX - pointer to Data1 
;Destr: SI, DI, AX
;=================================================
strcpy		proc
		mov bx, di

Next:		mov al, byte ptr [di]
		mov byte ptr [si], al
		
		cmp al, '$'
		je Return

		inc si
		inc di
		jmp Next

Return:		ret
		endp

;=================================================
;===================STRLEN========================
;Calculates the length of Data.
;Entry: BX - pointer to Data
;Exit: 	AX - length of Data
;Destr: BX
;=================================================
strlen		proc
		xor ax, ax

Next:		cmp byte ptr [bx], '$'
		je Return
		
		inc bx
		inc ax
		jmp Next

Return:		ret
		endp

;=================================================
;===================STRRCHR=======================
;Searches for the last occurrence of a character 
;					in Data.
;Entry: DI - pointer to Data
;	AL - character
;Exit: 	BX - pointer to the last occurrence of 
;				a character or 0
;Destr: CX, DI
;=================================================
strrchr		proc
		xor cx, cx
		xor bx, bx
		
Next:		cmp byte ptr [di], '$'
		je EndData
		inc di
		inc cx
		jmp Next

EndData:	dec di
		std
		repne scasb

		inc di
		cmp byte ptr [di], al
		jne Return
		mov bx, di

Return:		ret
		endp

end 		Start