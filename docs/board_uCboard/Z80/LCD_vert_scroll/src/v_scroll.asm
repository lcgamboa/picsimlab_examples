;*******************************************************************************
;===============================================================================
; Program: v_scroll.asm
; programmer(s): Dincer Aydin (dinceraydin@altavista.net)
; function: vertical scroll effect
; The effect is the same as the one you can see at the entrance of my LCD pages:
; http://www.dinceraydin.com/lcd/z80example.htm
;===============================================================================
;*******************************************************************************
; This code requires a 2*16 LCD connected to a 8255 with base address of 00h
; routines sendcomA & sendcom & sendcharA & sendchar have been tested on 
; >> 2*16 Hitachi LCD with HD44780 chip 
; >> Samsung 1*16 LCD with a KS0062F00 chip
; >> 2*16 Epson LCD marked P300020400 SANTIS 1 ,and 
; >> noname 1*16 HD44780 based LCD.
; The Z80 was clocked at 2 MHz and 4,9152 MHz for each display.This was done 
; because the routines mentioned above take many t states and in most cases 
; that will be longer that the time a HD44780 will need to execute a command. 
;
; Connections:
; LCD data bus(pins #14-#7) connected to Port A of a 8255 with 00h base address
; LCD Enable pin(#6) connected to Port C bit #7
; LCD R/W pin(#5) connected to Port C bit #6
; LCD RS pin(#4) connected to Port C bit #5


;8255 port address(base 00h):	
paadr: 		equ 00h		; Address of PortA
pbadr: 		equ 01h		; Address of PortB
pcadr: 		equ 02h		; Address of PortC
cwadr: 		equ 03h		; Address of Control Word
;stuff to be written into the control word of the 8255:
;Some of the change the state of the ports and some manipulate
;bits on port C
allpsin: 	equ 9bh		; set all ports to input mode
paincout: 	equ 90h		; A input,C output,B output
pandcout:	equ 80h		; set all ports to output mode
pacoutbin:	equ 82h		; A output,C output,B input
	
;bit set/reset commands.These bits are the control signals for the LCD
enable: 	equ 0fh		; set portC bit #6
disable:	equ 0eh		; reset portC bit #6
read: 		equ 0dh		; set portC bit #5
write:		equ 0ch		; reset portC bit #5
command: 	equ 0ah		; reset portC bit #4
data: 		equ 0bh		; set portC bit #4
	
; Define number of commands and length of string data
numofc: 		equ 4h		; number of commands

	
; initialization:		
	ld 	sp,0000h 	; Set stack pointer
	ld 	c,cwadr 
	ld 	a,pacoutbin 	; Ports A&C output,B input
	out	(c),a

; *********It all begins here**********:
; This part sends commands to initialize the LCD
				
	call 	delay	
	ld 	a,38h		; function set command
	ld 	b,4		
again:	ld 	c,cwadr		
	ld 	d,command	
	out	(c),d		; select the instruction register 
	ld 	d,write
	out	(c),d		; reset RW pin for writing to LCD
	out	(paadr),a	; place the command into portA
	ld 	d,enable	
	out	(c),d		; enable the LCD
	ld 	d,disable
	out	(c),d		; disable the LCD 
	call	delay		; wait for a while
	djnz	again		; loop till the command is sent 4 times
	
; send commands to set input mode, cursor,number of lines ,and etc.
	ld 	hl,combegadr 	; set HL to point the first command
	ld 	b,numofc	; put the number of commands to be sent in B
nextcom:
	call 	sendcom		; send (HL) as a command 
	inc 	hl		; point the next command
	djnz 	nextcom		; loop till all commands are sent
	
; Initialization is complete.


; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; This part sends strings to the LCD:
numofcts: 	equ 6h		; number of characters to scroll
numofd_line1: 	equ 0Fh		; define the number of string bytes to be sent to line #1
numofd_line2:	equ 08h		; define the number of string bytes to be sent to line #2

replay:	
	ld 	a,01h		; 01h is the "Clear Screen" command
	call 	sendcomA	; command is sent 
	
	ld 	a,40h		; set CGRAM address to 00h command
	call 	sendcomA	; command is sent and the addrss counter is pointing 00h in CGRAM
	
	xor 	a		; clear A
	ld 	b,64		; 64 CGRAM locations
clear:
	call 	sendcharA	; 00h is written to a CG ram location (i.e it is cleared)
	djnz 	clear		; loop till all CGRAM is cleared
				; CGRAM is clear and any garbage is gone
	
	ld 	a,80h		; 80h is the "set DDRAM address to 00h" command
	call 	sendcomA	; command is sent and the addrss counter is pointing 00h in DDRAM
				; Now that DDRAM address is set, let's print the string data
	ld 	hl,first_line	; set HL to point the first string byte
	ld 	b,numofd_line1	; put the number of string bytes to be sent in B
nextdata:			
	call 	sendchar	; send (HL) as string data 
	call    delay
	inc 	hl		; point the next string byte
	djnz	nextdata	; loop till all string bytes are sent
	
	ld 	hl,scrolldat	; make HL point the  bitmap data of the characters to be scrolled
	call 	scroll		; call the routine that will make it scroll
	
	ld 	a,0C4h		; set DDRAM address so that the cursor moves to the 4th location of the second line
	call 	sendcomA	
				; Now that DDRAM address is set, let's print the string data
	ld 	hl,second_line	; set HL to point the first string byte
	ld 	b,numofd_line2	; put the number of string bytes to be sent in B
nextdata2:			
	call 	sendchar	; send (HL) as string data 
	inc 	hl		; point the next string byte
	djnz	nextdata2	; loop till all string bytes are sent
	
	ld 	hl,0FFFFh
	call    pdelay
	
	jp 	replay
;====================================================================
; Subroutine name:Scroll
; programmer: Dincer Aydin
; input 1: HL pointing the data of the string to scroll
; input 2: "numofcts" >>the number of the characters in the string to be scrolled
; output:
; Registers altered: many
; function:	
;====================================================================
scroll:
	push 	hl	;ld hl',hl
	exx 
	pop 	hl
	exx
	
	ld b,1		; B is used as line counter
	ld a,47h	; A holds the command to set CGRAM 
			; address to the bottom line 
			; of the first custom chatacter in CGRAM 
				
			; later in the program A will be increased by 8 to
			; create the command to set CGRAM address to the same
			; line of the next custom character in CGRAM
			; The value in B = the number of lines to be 
			; written to CGRAM for each character.
			 
bidaha:	call delay
	
	exx		;ld hl,hl'
	push	hl
	exx 
	pop 	hl

	push 	bc	; save bc
	push 	af	; save af
	call 	tkr	; write to CGRAM to display B lines of the bitmap data,
			; starting from the laction specified by the command in A
			; for the first custom character and  A+8n command for the following 
			; custom characters   (n being the number of the custom character)
			; Need it be said that A and B are Z80 registers,not the hex numbers A and B ?
	pop 	af	; restore bc
	pop 	bc	; restore af
	dec 	a	; derease A to create a new set CGRAM address command
	inc 	b	; increase the number of lines to be sent a time
	push 	af	; save af
	ld 	a,09h	; see if all the lines are done (i.e. see if the aanimation is completed)
	cp 	b
	jp 	z,okend ; return if so
	pop 	af	; else restore af
	jp 	bidaha	; and go shift all custom characters one more line up
okend:	pop 	af
	ret

tkr:	ld 	d,numofcts	; d stores the number of custom characters to be scrolled
	
other:	push 	af	; save bc
	push 	bc	; save af
	call 	ilk	; send the specified number of bytes belonging to this custom character
	pop 	bc	; restore bc
	pop 	af	; restore af
	
	add 	a,8h	; a is increased by 8 to create the command to set CGRAM address to the same
			; line for the next custom character
			; add 8 to l so that (HL) points to the bitmap data that belongs to the new CGRAM address
	push 	af 	
	ld 	a,8
	add 	a,l
	ld 	l,a
	pop 	af
	dec 	d	; see if all the custom characters got their share
	jp 	nz,other 	; if not, go on with the next one
	ret		; else return

ilk:	push hl		; save HL
	call sendcomA	; send the commnad in A to set the CGRAM addres
next:	call sendchar	; send the byte in (HL) to that CGRAM location
	inc hl		;
	djnz next	; dec B to see is all the lines of this character are done. Loop till they are done.
	pop hl		; restore HL
	ret	        ; the specified number of bytes belonging to this custom character are sent.It is time to return.
	
; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	
; ====================================================================
; Subroutine name:sendcomA & sendcom & sendcharA & sendchar 
; programmer:Caner Buyuktuna & Dincer Aydin
; input:A or (HL)
; output:
; Registers altered:A 
; function:	sendcharA sends the data in A to the LCD
;  	  	sendchar sends the data in (HL) to the LCD
; 		sendcomA sends the command in A to the LCD
;  		sendcom sends the command in (HL) to the LCD	
; ====================================================================
sendchar:
	ld 	a,(hl)		; put the data to be sent to the LCD in A
sendcharA:	
	push 	bc		; save BC
	push 	de		; save DE
	ld 	e,data		;  
	jp 	common

sendcom:
	ld 	a,(hl)
sendcomA:	
	push 	bc		; save BC
	push 	de		; save DE   
	ld 	e,command	   

common:	
	call 	bfcheck    	; See if the LCD is busy. If it is busy wait,till it is not.
	out 	(c),e		; Set/reset RS accoring to the content of register E
	ld 	d,write		
	out	(c),d		; reset RW pin for writing to LCD
	out	(paadr),a	; place data/instrucrtion to be written into portA
	ld 	d,enable	
	out	(c),d		; enable the LCD
	ld 	d,disable	
	out 	(c),d		; disable the LCD 
	pop 	de		; restore DE
	pop 	bc		; restore BC
	ret			; return
; ====================================================================
; Subroutine name:bfcheck
; programmer:Dincer Aydin
; input:
; output:
; Registers altered:D
; function:Checks if the LCD is busy and waits until it is not busy
; ====================================================================

bfcheck:
	push 	af		; save AF
	ld 	c,cwadr
	ld 	d,paincout
	out 	(c),d		; make A input,C output,B output
	ld 	d,read		
	out 	(c),d		; set RW pin for reading from LCD
	ld 	d,command
	out	(c),d		; select the instruction register 
check_again:	
	ld 	d,enable	
	out	(c),d		; enable the LCD
	in 	a,(paadr)	; read from LCD
	ld 	d,disable
	out 	(c),d		; disable the LCD 
	rlca			; rotate A left through C flag to see if the busy flag is set
	jp 	c,check_again	; if busy check it again,else continue
	ld 	d,pandcout	
	out	(c),d		; set all ports to output mode
	pop 	af		; restore AF
	ret

;====================================================================
; Subroutine name:DELAY 
; programmer(s):Dincer Aydin
; input:-
; output:-
; Registers altered:-
; function:delay 
; for more delay you can add a few nops or or some junk commands using the index 
; registers
;====================================================================
pdelay:	push 	hl
	jp 	comdelay
delay:	push    hl
	ld 	hl,2222h
comdelay:	
	dec	l
	nop
	jp 	nz,comdelay
	dec	h
	jp 	nz,comdelay
	pop	hl
	ret

;====================================================================
; commands and strings
combegadr:
	db 01h,80h,0ch,06h  	; clear display,set DD RAM adress,
				; turn on display with cursor hidden,set entry mode

first_line:
	dm "VERTICAL " 
	db 00h,01h,02h,03h,04h,05h 		; first 5 custom characters
second_line:
	dm "Is Cool!"

scrolldat:
	db 143,144,144,142,129,129,158,128 ; S
	db 128,128,142,144,144,145,142,128 ; c
	db 128,128,150,153,144,144,144,128 ; r
	db 128,128,142,145,145,145,142,128 ; o
	db 140,132,132,132,132,132,142,128 ; l
	db 140,132,132,132,132,132,142,128 ; l

end
