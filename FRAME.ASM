.model tiny
.code
org 100h

locals @@

.getch		macro
		xor ax, ax
		int 16h
		endm

;========================================================
VIDEOSEG equ 0b800h

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
;========================================================

Start:		mov si, offset Msg		
		
		mov di, VIDEOSEG		
		mov es, di			

		mov ax, word ptr [Y]
                mov bx, WINDOW_WEIGHT
                mul bl
                add ax, word ptr [X]
                shl ax, 1
		mov di, ax

                mov al, SPACE
		mov ah, COLOUR		
		call DrawFrameWText		
		
		.getch			

		mov ax, 4C00h			
		int 21h

;========================================================
;Draw frame with text.
;Entry: AH - colour
;	DI - adress start of frame
;	ES - VIDEOSEG
;	SI - adress of Msg
;Exit: CX is ALWAYS 0
;Destr: DI, SI, AL, DX, BX
;========================================================
DrawFrameWText	proc
		mov al, TOP_LEFT_ANGLE
		stosw

		mov al, HORIZONTAL_FRAME
		mov cx, word ptr [FRAME_WEIGHT]
                sub cx, 2
		rep stosw

		mov al, TOP_RIGHT_ANGLE
		stosw
		
		mov cx, word ptr [FRAME_HEIGHT]
                sub cx, 2
		call DrawFrameBack
		mov dx, WINDOW_WEIGHT
                sub dx, word ptr [FRAME_WEIGHT]
                shl dx, 1
                add di, dx

		mov al, BOTTOM_LEFT_ANGLE
		stosw

		mov al, HORIZONTAL_FRAME
		mov cx, word ptr [FRAME_WEIGHT]
                sub cx, 2
		rep stosw

		mov al, BOTTOM_RIGHT_ANGLE
		stosw
		
                mov dx, ax
                mov ax, word ptr [FRAME_HEIGHT]
                sub ax, TEXT_HEIGHT
                shr ax, 1
                add ax, word ptr [Y]
                mov bx, WINDOW_WEIGHT
                mul bl
		mov di, ax
                
                mov ax, word ptr [FRAME_WEIGHT]
		sub ax, TEXT_WEIGHT
                shr ax, 1
                add ax, word ptr [X]
                add di, ax
		shl di, 1
		
                mov ax, dx

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
;Destr: DI, AL, DX
;========================================================
DrawFrameBack	proc
@@Next:		push cx
	
                mov dx, WINDOW_WEIGHT
                sub dx, word ptr [FRAME_WEIGHT]
                shl dx, 1
		add di, dx
		
		mov al, VERTICAL_FRAME
		stosw

		mov al, Space
		mov cx, word ptr [FRAME_WEIGHT]
                sub cx, 2
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

X:		dw 7d		
Y:		dw 7d 
FRAME_WEIGHT:	dw 40d
FRAME_HEIGHT:	dw 15d 

Msg:		db 22h, 'Knowlege is power', 22h, '$'

end 		Start  				
