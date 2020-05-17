.model tiny
.code
org 100h

locals @@

.getch		macro
		xor ax, ax
		int 16h
		endm

;=================================================
VIDEOSEG equ 0b800h

CMDSEG equ 81h

IAP_STEP equ 3d

WINDOW_WEIGHT equ 80d
WINDOW_HEIGHT equ 25d

COLOUR equ 19h

TOP_RIGHT_ANGLE equ 0BBh
TOP_LEFT_ANGLE equ 0C9h
BOTTOM_RIGHT_ANGLE equ 0BCh
BOTTOM_LEFT_ANGLE equ 0C8h

HORIZONTAL_FRAME equ 0CDh 
VERTICAL_FRAME equ 0BAh

SPACE equ 20h

TEXT_WEIGHT equ 19d
TEXT_HEIGHT equ 1d

; dh FRAME_WEIGHT equ 40d	
; dl FRAME_HEIGHT equ 15d	

; bh X equ 7d		
; bl Y equ 7d		

;=================================================

Start:		call InAllParams    ; x, y, w, h		

		mov si, offset Msg		
		
		mov di, VIDEOSEG		
		mov es, di			

		mov ah, COLOUR		
		mov di, (bl * WINDOW_WEIGHT + bh) shl 1

		call DrawFrameWText		
		
		.getch				

		mov ax, 4C00h			
		int 21h

InAllParams	proc
		mov cx, CMDSEG

		jmp @@Start

@@Next:		push dx

@@Start:	call InParam
		mov dh, al
		add cx, IAP_STEP

		call InParam
		mov dl, al
		add cx, IAP_STEP

		cmp cx, CMDSEG + IAP_STEP * 4
		jne @@Next

		pop bx

		ret
		endp

InParam		proc
		mov bx, [cx]
		sub bx, '00'		

		mov al, 20d
		mul bl

		add al, bh
		add al, bh

		ret
		endp

;=================================================
;Draw frame with text.
;Entry: AH - colour
;	DI - adress start of frame
;	ES - VIDEOSEG
;	SI - adress of Msg
;Exit: CX is ALWAYS 0
;Destr: DI, SI, AL
;========================================================
DrawFrameWText	proc
		mov al, TOP_LEFT_ANGLE
		stosw

		mov al, HORIZONTAL_FRAME
		mov cx, dh - 2
		rep stosw

		mov al, TOP_RIGHT_ANGLE
		stosw
		
		mov cx, dl - 2	
		call DrawBackground
		add di, (WINDOW_WEIGHT - dh) shl 1

		mov al, BOTTOM_LEFT_ANGLE
		stosw

		mov al, HORIZONTAL_FRAME
		mov cx, dh - 2
		rep stosw

		mov al, BOTTOM_RIGHT_ANGLE
		stosw
		
		mov di, (bl + (dl - TEXT_HEIGHT) shr 1) * WINDOW_WEIGHT
		add di, bh + (dh - TEXT_WEIGHT) shr 1
		shl di, 1
		mov cx, TEXT_WEIGHT 
		call WriteText
		
		ret
		endp

;========================================================
;Draw frame background.
;Entry: AH - colour
;	DI - adress start of background
;	ES - VIDEOSEG
;	CX - count of lines
;Exit: CX is ALWAYS 0
;Destr: DI, AL
;========================================================
DrawFrameBack	proc
@@Next:		push cx
	
		add di, (WINDOW_WEIGHT - dh) shl 1
		
		mov al, VERTICAL_FRAME
		stosw

		mov al, Space
		mov cx, dh - 2
		rep stosw

		mov al, VERTICAL_FRAME
		stosw

		pop cx
		loop @@Next
		ret
		endp

;========================================================
;Prints a text to the screen.
;Entry: AH - colour
;	DI - adress start of text
;	ES - VIDEOSEG
;	CX - length of text
;	SI - adress Msg
;Exit: CX is ALWAYS 0
;Destr: DI, SI, AL
;========================================================
WriteText	proc
@@Next:		mov al, [si]
		stosw	
		inc si	
		loop @@Next
		ret
		endp
	
Msg:		db 22h, 'Knowlege is power', 22h, '$'

end 		Start  				