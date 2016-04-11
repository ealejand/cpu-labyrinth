;- Created by:
;-		Emil Alejandria
;-		Megan Durante
;- For:
;-		CPE 233
;-		Fall 2013

;- Labyrinth 1.00	Patch Notes
;-	Functional drawDisplay implementation
;-	Functional getByte implementation
;-	Functional collision detection.
;-	Expanded map memory location allocation

;- Labyrinth 1.00a	Patch Notes
;-	Code optimization
;-	Comments added

;- Labyrinth 1.00b	Patch Notes
;-	Moved current location storage to memory from registers

;- Labyrinth 1.00c	Patch Notes
;-	Added a victory screen

;- Labyrinth 1.01	Patch Notes
;-	Added functional keys and doors

;- Labyrinth 1.02	Patch Notes
;-	Added almost functional mob.
;-		Spontaneously jumps two spaces periodically
;-		RNG for movement unsatisfactory

;- Labyrinth 1.02a	Patch Notes
;-	Added a death screen

;- Future changes
;-	Destructible blocks
;-	Bombs
;-	Mobs
;---- ^ Good luck
;-	Health
;-	Timer
;---- ^ Stop trying

;--------------------------------------------------------------------
; I/O Port Constants
;--------------------------------------------------------------------
.EQU LEDS		= 0x40     ; LED array
.EQU SSEG		= 0x81     ; 7-segment decoder 

.EQU PS2_KEY_CODE	= 0x44     ; ps2 data register

.EQU VGA_HADD	= 0x90     ; high address register
.EQU VGA_LADD	= 0x91     ; low address register
.EQU VGA_COLOR	= 0x92     ; color value register
;--------------------------------------------------------------------

;--------------------------------------------------------------------
; Key Constants
;--------------------------------------------------------------------
.EQU W			= 0x1D
.EQU A			= 0x1C
.EQU S			= 0x1B
.EQU D			= 0x23
.EQU SPAAACE	= 0x29
;--------------------------------------------------------------------

;--------------------------------------------------------------------
; Color constants
;--------------------------------------------------------------------
.EQU BLACK		= 0x00
.EQU CRIMSON	= 0xE0
.EQU BLUE		= 0x03
.EQU GREEN		= 0x1C
.EQU GREY		= 0x4A
.EQU YELLOW		= 0x48
.EQU BROWN		= 0x45
;--------------------------------------------------------------------

;--------------------------------------------------------------------
;- Register Usage
;--------------------------------------------------------------------
;- r20					; current map shift
;- r21					; current x location
;- r22					; current y location
;- r1					; byte being pointed to
;--------------------------------------------------------------------

;--------------------------------------------------------------------
;- Memory Allocation
;--------------------------------------------------------------------
;- 0x00					; display shift
;- 0x01					; display x-location
;- 0x02					; display y-location
;- 0x30 to 0x8F			; Map
;--------------------------------------------------------------------
.DSEG
.ORG 0x00
			.DB		0x06
			.DB		0x06
			.DB		0x06
			.DB		0x01, 0x01, 0x01
			.DB		0x04, 0x14, 0x0C
			.DB		0x05, 0x0D, 0x0F

.CSEG
.ORG 0x125

initialize:
			CALL 	generateMap
			CALL	drawFrame			
			CALL	drawDisplay
			SEI

main:
			LD		r1,0x29
			CMP		r1,0x01
			BREQ	main
			LD		r1,0x20
			ADD		r1,0x01
			ST		r1,0x20
			CMP		r1,0xFF
			BRNE	main
			MOV		r1,0x00
			ST		r1,0x20
			LD		r1,0x21
			ADD		r1,0x01
			ST		r1,0x21
			CMP		r1,0xFF
			BRNE	main
			MOV		r1,0x00
			ST		r1,0x21
			LD		r1,0x22
			ADD		r1,0x01
			ST		r1,0x22
			CMP		r1,0xFF
			BRNE	main
			MOV		r1,0x00
			ST		r1,0x22
			LD		r1,0x23
			ADD		r1,0x01
			ST		r1,0x23
			BRN		moveMobs
			CMP		r1,0xFF
			BRNE	main
			MOV		r1,0x00
			ST		r1,0x23
			BRN		main

moveMobs:
			CLI
			MOV		r6,0x06
			MOV		r7,0x07
			MOV		r8,0x08
			CALL	moveMob

moveMob:
			LD		r20,(r6)
			LD		r21,(r7)
			LD		r22,(r8)
			LD		r2,0x02
			EXOR	r2,r21
			LSR		r2
			BRCS	checkUp
			LSR		r2
			BRCS	checkRight
			LSR		r2
			BRCS	checkLeft
			LSR		r2
			BRCS	checkDown
			LSR		r2
			BRCS	checkUp
			LSR		r2
			BRCS	checkRight
			LSR		r2
			BRCS	checkLeft
			LSR		r2
			BRCS	checkDown
			RET

checkUp:
			SUB		r22,0x01
			CALL	getByte
			LSL		r31
			BRCS	checkLeft
			BRN		moveMobDone
checkLeft:
			ADD		r22,0x01
			SUB		r21,0x01
			SUB		r20,0x01
			BRCC	checkLeftCont
			MOV		r20,0x07
checkLeftCont:
			CALL	getByte
			LSL		r31
			BRCS	checkRight
			BRN		moveMobDone
checkRight:
			ADD		r21,0x02
			ADD		r20,0x02
			SUB		r20,0x08
			BRCC	checkRightCont
			ADD		r20,0x08
checkRightCont:
			CALL	getByte
			LSL		r31
			BRCS	checkDown
			BRN		moveMobDone
checkDown:
			SUB		r21,0x01
			SUB		r20,0x01
			BRCC	checkDownCont
			MOV		r20,0x07
checkDownCont:
			ADD		r22,0x01
			CALL	getByte
			LSL		r31
			BRCC	moveMobDone
			RET

moveMobDone:
			ST		r20,(r6)
			ST		r21,(r7)
			ST		r22,(r8)
			CALL	drawDisplay
			RET

;--------------------------------------------------------------------
;- Subroutine: drawDisplay
;-	This subroutine iterates through each line of the display area
;-	and displays a byte generated by getByte. It then adds the blit
;-	to show the user's location.

;- Modified registers:
;-	r7, r8, r6
;-	r23, r24, r25, r26, r27, r28, r30, r31 (getByte)
;--------------------------------------------------------------------
drawDisplay:
			LD		r20,0x00
			LD		r22,0x02
			MOV		r7,0x04

drawDisplayLine:
			LD		r21,0x01
			MOV		r8,0x01
			CALL	getByte
			SUB		r21,0x01
			CALL	drawByte

			ADD		r22,0x01
			ADD		r7,0x03
			CMP		r7,0x19
			BRNE	drawDisplayLine

drawLocation:
			MOV		r6,CRIMSON
			MOV		r7,0x0D
			MOV		r8,0x0D
			CALL	drawBlit
			
drawDisplayComplete:
			RET

;--------------------------------------------------------------------
drawByte:
			ADD		r21,0x01
			ADD		r8,0x03
			CMP		r8,0x1C
			BREQ	drawByteDone
			CLC
			LSL		r31
			BRCC	checkMobs
            MOV     r6,GREY
            CALL    drawBlit
            BRN     drawByte
checkMobs:
			LD		r24,0x07
			CMP		r21,r24
			BRNE	checkKeys
			LD		r24,0x08
			CMP		r22,r24
			BRNE	checkKeys
			MOV		r6,GREEN
			CALL	drawBlit
			MOV		r6,BLACK
			CALL	drawDot
			BRN		drawByte
checkKeys:
			LD		r24,0x03
			CMP		r24,0x01
			BRNE	checkKey2
			CMP		r21,0x18
			BRNE	checkKey2
			CMP		r22,0x08
			BRNE	checkKey2
			BRN		drawKey
checkKey2:
			LD		r24,0x04
			CMP		r24,0x01
			BRNE	checkKey3
			CMP		r21,0x17
			BRNE	checkKey3
			CMP		r22,0x0F
			BRNE	checkKey3
			BRN		drawKey
checkKey3:
			LD		r24,0x05
			CMP		r24,0x01
			BRNE	checkDoors
			CMP		r21,0x08
			BRNE	checkDoors
			CMP		r22,0x12
			BRNE	checkDoors
			BRN		drawKey
checkDoors:
			CMP		r22,0x09
			BRNE	wipeByte
			LD		r24,0x03
			CMP		r24,0x01
			BRNE	checkDoor2
			CMP		r21,0x07
			BRNE	checkDoor2
			BRN		drawDoor
checkDoor2:
			LD		r24,0x04
			CMP		r24,0x01
			BRNE	checkDoor3
			CMP		r21,0x06
			BRNE	checkDoor3
			BRN		drawDoor
checkDoor3:
			LD		r24,0x05
			CMP		r24,0x01
			BRNE	wipeByte
			CMP		r21,0x05
			BRNE	wipeByte
			BRN		drawDoor

wipeByte:
			MOV		r6,BLACK
			CALL	drawBlit
			BRN		drawByte
drawByteDone:
			RET
drawDoor:
			MOV		r6,BROWN
			CALL	drawBlit
			MOV		r6,YELLOW
			CALL	drawDot
			BRN		drawByte
drawKey:
			MOV		r6,BLACK
			CALL	drawBlit
			MOV		r6,YELLOW
			CALL	drawDot
			BRN		drawByte
			
;--------------------------------------------------------------------

;--------------------------------------------------------------------
;- Subroutine: drawFram
;-	This subroutine draws the frame to hold the display area for our labyrinth.
;-	It uses drawHLine and drawVLine to draw a rectangle on the screen from
;-	(0x02, 0x02) to (0x1B, 0x1B). The color of the frame is blue.

;- Modified registers:
;-	r6, r7, r8, r9
;--------------------------------------------------------------------
drawFrame:
			MOV		r6,BLUE		; pick a color

			MOV		r7,0x02		; y-coordinate
			MOV		r8,0x02		; x-coordinate low
			MOV		r9,0x1B		; x-coordinate high
			CALL	drawHLine
			MOV		r7,0x02		; x-coordinate
			MOV		r8,0x02		; y-coordinate low
			MOV		r9,0x18		; y-coordinate high
			CALL	drawVLine
			MOV		r7,0x02		; y-coordinate low
			MOV		r8,0x1B		; x-coordinate 
			MOV		r9,0x18		; y-coordinate high
			CALL	drawVLine
			MOV		r7,0x18		; y-coordinate
			MOV		r8,0x02		; x-coordinate low
			MOV		r9,0x1B		; x-coordinate high
			CALL	drawHLine

			RET
;--------------------------------------------------------------------

;--------------------------------------------------------------------
;-  Subroutine: drawHLine
;-
;-  Draws a horizontal line from (r8,r7) to (r9,r7) using color in r6
;-
;-  Parameters:
;-   r6  = color used for line
;-   r7  = y-coordinate
;-   r8  = starting x-coordinate
;-   r9  = ending x-coordinate
;- 
;- Tweaked registers: r8,r9
;--------------------------------------------------------------------
drawHLine:
        ADD    r9,0x01          ; go from r8 to r9 inclusive

drawHLoop:
        CALL   drawDot         ; draw tile
        ADD    r8,0x01          ; increment column (X) count
        CMP    r8,r9            ; see if there are more columns
        BRNE   drawHLoop      ; branch if more columns
        RET
;--------------------------------------------------------------------


;---------------------------------------------------------------------
;-  Subroutine: drawVLine
;-
;-  Draws a horizontal line from (r8,r7) to (r8,r9) using color in r6
;-
;-  Parameters:
;-   r6  = color used for line
;-   r7  = starting y-coordinate
;-   r8  = x-coordinate
;-   r9  = ending y-coordinate
;- 
;- Tweaked registers: r7,r9
;--------------------------------------------------------------------
drawVLine:
         ADD    r9,0x01         ; go from r7 to r9 inclusive

drawVLoop:          
         CALL   drawDot        ; draw tile
         ADD    r7,0x01         ; increment row (y) count
         CMP    r7,r9           ; see if there are more rows
         BRNE   drawVLoop      ; branch if more rows
         RET
;--------------------------------------------------------------------

;--------------------------------------------------------------------
;- Subroutine: Draw_blit
;- 
;- The subroutine draws a 3x3 square centered at the
;- values in (r8,r7) <==> (x,y). The center of this
;- 3x3 is green; the outside edges are blue. 
;- 
;- Tweaked Registers:
;--------------------------------------------------------------------
drawBlit: 
         PUSH	r7       ; save current y location
         PUSH	r8       ; save current x location

         CALL  drawDot     ; draw center

         SUB   r7,0x01      ; adjust coordinates
         SUB   r8,0x01
         CALL  drawDot     ; NW pixel 
         ADD   r8,0x01      ; adjust coordinates
         CALL  drawDot     ; N pixel
         ADD   r8,0x01      ; adjust coordinates
         CALL  drawDot     ; NE pixel
         
         ADD   r7,0x01      ; adjust coordinates
         CALL  drawDot     ; E pixel
         SUB   r8,0x02      ; adjust coordinates
         CALL  drawDot     ; W pixel

         ADD   r7,0x01      ; adjust coordinates
         CALL  drawDot     ; SW pixel
         ADD   r8,0x01      ; adjust coordinates
         CALL  drawDot     ; S pixel
         ADD   r8,0x01      ; adjust coordinates
         CALL  drawDot     ; SE pixel

         POP	r8       ; restore current y location
         POP	r7       ; restore current x location
         RET                ; later dude
;--------------------------------------------------------------------

;--------------------------------------------------------------------
;- Subrountine: drawDot
;- 
;- This subroutine draws a dot on the display the given coordinates: 
;- 
;- (X,Y) = (r8,r7)  with a color stored in r6  
;- 
;- Tweaked registers: r4,r5
;--------------------------------------------------------------------
drawDot: 
			MOV		r1,r1
           MOV	 r4,r7         ; copy Y coordinate
           AND   r4,0x1F       ; make sure top 3 bits cleared

           MOV	 r5,r8         ; copy X coordinate
           AND   r5,0x3F       ; make sure top 2 bits cleared

           LSR   r4            ; need to get the bot 2 bits of r4 into sA
           BRCS  dd_add40

t1:        LSR   r4
           BRCS  dd_add80

dd_out:    OUT   r5,VGA_LADD   ; write bot 8 address bits to register
           OUT   r4,VGA_HADD   ; write top 3 address bits to register
           OUT   r6,VGA_COLOR  ; write data to frame buffer
           RET

dd_add40:  OR    r5,0x40       ; set bit if needed
           CLC                 ; freshen bit
           BRN   t1             

dd_add80:  OR    r5,0x80       ; set bit if needed
           BRN   dd_out

;--------------------------------------------------------------------

drawScreen:
		MOV		r6,0xFF
		MOV		r7,0x0E
		MOV		r8,0xFF
		MOV		r10,0x08
		LD		r31,(r30)

drawWinLoop:
		ADD		r8,0x01
		SUB		r10,0x01
		LSL		r31
		BRCC	drawWinNext1
		CALL	drawDot

drawWinNext1:	
		CMP		r10,0x00
		BRNE	drawWinNext2
		MOV		r10,0x08
		ADD		r30,0x01
		LD		r31,(r30)

drawWinNext2:
		CMP		r8,0x27
		BRNE	drawWinLoop
		ADD		r7,0x01
		CMP		r7,0x12
		BREQ	drawWinDone
		MOV		r8,0xFF
		BRN		drawWinLoop

drawWinDone:
		CLI
		RET

;---------------------------------------------------------------------
;-  Subroutine: draw_background
;-
;-  Fills the 30x40 grid with one color using successive calls to 
;-  draw_horizontal_line subroutine. 
;- 
;-  Tweaked registers: r13,r7,r8,r9
;---------------------------------------------------------------------
clearScreen: 
         PUSH  r7                       ; save registers
         PUSH  r8
         MOV   r6,BLACK	                ; use default color
         MOV   r13,0x00                 ; r13 keeps track of rows
start:   MOV   r7,r13                   ; load current row count 
         MOV   r8,0x00                  ; restart x coordinates
         MOV   r9,0x27 
 
         CALL  drawHLine		        ; draw a complete line
         ADD   r13,0x01                 ; increment row count
         CMP   r13,0x1E                 ; see if more rows to draw
         BRNE  start                    ; branch to draw more rows
         POP   r8                       ; restore registers
         POP   r7
         RET
;---------------------------------------------------------------------

;--------------------------------------------------------------------
;- Subroutine: getByte
;-	This subroutine takes the current location (r21, r22) and generates
;-	a byte to be displayed for that row. It pulls the byte at its
;-	current location (top left corner) and, if needed, shifts it. When
;-	shifting, it rotates the byte left, clearing the rightmost bit as it
;-  goes, until the shift counter is emptied. It then pulls the next byte
;-	to the right and shifts that one to the left, but clears the opposite
;-	bits. It then combines these half completed bytes and spits the whole 
;-	thing out.

;- Used Registers
;-	r20, r21, r22, r26, r29, r30, r31
;- Modified registers:
;-	r26, r29, r30, r31
;--------------------------------------------------------------------
getByte:
			PUSH	r20
			PUSH	r21
			PUSH	r22
			MOV		r26,0xFF		; counter for columns (underflow for DO-WHILE)
			MOV		r30,0x30
	
findColumnLoop:
			ADD		r26,0x01
			SUB		r21,0x08
			BRCC	findColumnLoop
			ADD		r30,r26			; move to the intended byte's column
			MOV		r26,0xFC		; counter for rows (underflow for DO-WHILE)

findRowLoop:
			ADD		r26,0x04
			SUB		r22,0x01
			BRCC 	findRowLoop
			ADD		r30,r26			; move to the intended byte's row
			LD		r31,(r30)		; pull that byte's data

shiftInit:
			CMP		r20,0x00		; check if a shift is necessary
			BREQ	shiftByteDone
shiftFirstByte:
			MOV		r26,0xFF		; used to AND the shifted bytes
			CALL	shiftByte		; shift the byte
			AND		r31,r26			; clear unnecessary bits
			MOV		r29,r31			; store our half-complete bit
shiftSecondByte:
			LD		r20,0x00		; reset counter
			MOV		r26,0xFF		; ^
			ADD		r30,0x01		; grab the next byte
			LD		r31,(r30)		; ^
			CALL	shiftByte		; shift dat shit
			EXOR	r26,0xFF		; invert
			AND		r31,r26			; clear unnecessary bits
			OR		r31,r29			; add our earlier completed half
shiftByteDone:
			POP		r22
			POP		r21
			POP		r20
			RET

shiftByte:
			LSL		r26
			ROL		r31
			SUB		r20,0x01
			CMP		r20,0x00
			BRNE	shiftByte
			RET

;--------------------------------------------------------------------
;- Subroutine: ISR (Interrupt Service Routine)
;-	This subroutine handles movement checking whenever a keyboard press is detected. 
;-	It disables interrupts, checks each key sequentially by verifying the key code,
;-	checks the validity of the move, then either cancels the move or adjusts the
;- 	current location appropriately.

;- Modified registers
;-	r1, r20, r21, r22, r31
;--------------------------------------------------------------------
ISR:
			CLI
			IN		r1,PS2_KEY_CODE
			LD		r20,0x00
			LD		r21,0x01
			LD		r22,0x02

checkW:
			CMP		r1,W				; Compare the key code to a 'w' press, move on
			BRNE	checkA				; if they aren't equal.

			ADD		r22,0x02			; Adjust the pointer to the row above the
			CALL	getByte				; character, get that byte, and move the 
			SUB		r22,0x02			; pointer back.

			AND		r31,0x10			; Empty all bits except the bit above the
			CMP		r31,0x10			; character then check if there's anything
			BREQ	done				; there. If so, end the ISR. If not, adjust
			SUB		r22,0x01			; the current location then end the ISR.
			BRN		done

checkA:
			CMP		r1,A
			BRNE	checkS

			ADD		r22,0x03
			CALL	getByte
			SUB		r22,0x03
		
			AND		r31,0x20
			CMP		r31,0x20
			BREQ	done
			BRN		checkADoors
checkACont:
			SUB		r21,0x01
			CMP		r20,0x00
			BREQ	checkAException
			SUB		r20,0x01
			BRN		done		

checkS:
			CMP		r1,S
			BRNE	checkD

			ADD		r22,0x04
			CALL	getByte
			SUB		r22,0x04

			AND		r31,0x10
			CMP		r31,0x10
			BREQ	done
			ADD		r22,0x01
			BRN		done

checkD:
			CMP		r1,D
			BRNE	done

			ADD		r22,0x03
			CALL	getByte
			SUB		r22,0x03
		
			AND		r31,0x08
			CMP		r31,0x08
			BREQ	done
			ADD		r21,0x01
			CMP		r20,0x07
			BREQ	checkDException
			ADD		r20,0x01
			BRN		done

done:
			ST		r20,0x00
			ST		r21,0x01
			ST		r22,0x02
			ADD		r21,0x03
			ADD		r22,0x03
			BRN		checkKeyGrab

checkADoors:
			CMP		r22,0x06
			BRNE	checkACont
			CMP		r21,0x05
			BRNE	checkADoors2
			LD		r24,0x03
			CMP		r24,0x01
			BREQ	done
			BRN		checkACont
checkADoors2:
			CMP		r21,0x04
			BRNE	checkADoors3
			LD		r24,0x04
			CMP		r24,0x01
			BREQ	done
			BRN		checkACont
checkADoors3:
			CMP		r21,0x03
			BRNE	checkACont
			LD		r24,0x05
			CMP		r24,0x01
			BREQ	done
			BRN		checkACont
			

checkAException:
			MOV		r20,0x07
			BRN 	done

checkDException:
			MOV		r20,0x00
			BRN		done

checkKeyGrab:
			CMP		r21,0x18
			BRNE	checkKeyGrab2
			CMP		r22,0x08
			BRNE	checkKeyGrab2
			MOV		r24,0x00
			ST		r24,0x03
			BRN		notVictory
checkKeyGrab2:
			CMP		r21,0x17
			BRNE	checkKeyGrab3
			CMP		r22,0x0F
			BRNE	checkKeyGrab3
			MOV		r24,0x00
			ST		r24,0x04
			BRN		notVictory
checkKeyGrab3:
			CMP		r21,0x08
			BRNE	checkDeath
			CMP		r22,0x12
			BRNE	checkDeath
			MOV		r24,0x00
			ST		r24,0x05
			BRN		notVictory
checkDeath:
			LD		r24,0x07
			CMP		r24,r21
			BRNE	checkVictory
			LD		r24,0x08
			CMP		r24,r22
			BRNE	checkVictory
			CALL	clearScreen
			MOV		r30,0xA4
			CALL	drawScreen
			MOV		r29,0x01
			ST		r29,0x29
			RETID

checkVictory:
			SUB		r21,0x03
			SUB		r22,0x03
			CMP		r21,0x00
			BRNE	notVictory
			CMP		r22,0x06
			BRNE	notVictory

			CALL	clearScreen
			MOV		r30,0x90
			CALL	drawScreen
			MOV		r29,0x01
			ST		r29,0x29
			RETID

notVictory:
			CALL	drawDisplay
			RETIE
;--------------------------------------------------------------------

;--------------------------------------------------------------------
;- Subroutine: generateMap
;-	This subroutine loads the predesigned level into the scratchRAM. The map occupies
;-	memory locations 0x30 through 0x8F, a total of 96 locations. If a bit exists in a
;-	location then the program will put a wall there, else it will remain open.

;- Modified registers:
;-	None
;--------------------------------------------------------------------

generateMap:
.DSEG
.ORG	0x30

			.DB		0xFF, 0xFF, 0xFF, 0xFF	; 0x30 - 0x33
			.DB		0xFF, 0xFF, 0xFF, 0xFF	; 0x34 - 0x37
			.DB		0xFF, 0xFF, 0xFF, 0xFF	; 0x38 - 0x3B
			.DB		0xEE, 0x20, 0x78, 0x0F	; 0x3C - 0x3F
			.DB		0xE0, 0x8B, 0x02, 0xEF	; 0x40 - 0x43
			.DB		0xEE, 0xBB, 0xEE, 0x0F	; 0x44 - 0x47
			.DB		0xE0, 0x02, 0x22, 0xAF	; 0x48 - 0x4B
			.DB		0xFD, 0xFE, 0xA8, 0x0F	; 0x4C - 0x4F
			.DB		0xE7, 0x10, 0xAD, 0x5F	; 0x50 - 0x53
			.DB		0xE0, 0x05, 0xA8, 0x0F	; 0x54 - 0x57
			.DB		0xE7, 0x10, 0x8A, 0xAF	; 0x58 - 0x5B
			.DB		0xFD, 0xBA, 0xEA, 0xAF	; 0x5C - 0x5F
			.DB		0xE0, 0x02, 0x22, 0xAF	; 0x60 - 0x63
			.DB		0xEB, 0xFB, 0xAA, 0x8F	; 0x64 - 0x67
			.DB		0xE8, 0x8A, 0x20, 0xEF	; 0x68 - 0x6B
			.DB		0xEE, 0xA0, 0x86, 0x0F	; 0x6C - 0x6F
			.DB		0xE0, 0x8A, 0xD0, 0xEF	; 0x70 - 0x73
			.DB		0xFE, 0xBA, 0x15, 0xEF	; 0x74 - 0x77
			.DB		0xE0, 0x13, 0xD4, 0x0F	; 0x78 - 0x7B
			.DB		0xEA, 0xD6, 0x15, 0xEF	; 0x7C - 0x7F
			.DB		0xE2, 0x00, 0xF0, 0x0F	; 0x80 - 0x83
			.DB		0xFF, 0xFF, 0xFF, 0xFF	; 0x84 - 0x87
			.DB		0xFF, 0xFF, 0xFF, 0xFF	; 0x88 - 0x8B
			.DB		0xFF, 0xFF, 0xFF, 0xFF	; 0x8C - 0x8F
			.DB		0x05, 0x75, 0x2A, 0xE9, 0x40	; 0x90 - 0x94
			.DB		0x07, 0x55, 0x2A, 0x4D, 0x40	; 0x95 - 0x99
			.DB		0x02, 0x55, 0x2A, 0x4B, 0x00	; 0x9A - 0x9E
			.DB		0x02, 0x77, 0x14, 0xE9, 0x40	; 0x9F - 0xA3
			.DB		0x02, 0xBA, 0x99, 0xDD, 0x80	; 0xA4
			.DB		0x03, 0xAA, 0x94, 0x99, 0x40
			.DB		0x01, 0x2A, 0x94, 0x91, 0x40
			.DB		0x01, 0x3B, 0x99, 0xDD, 0x80

;			.DB		0xFF, 0xFF, 0xFF, 0xFF	; 0x50 - 0x53
;			.DB		0x88, 0x0F, 0xFA, 0x01	; 0x54 - 0x57
;			.DB		0x83, 0xA0, 0x02, 0x3D	; 0x58 - 0x5B
;			.DB		0x88, 0xAE, 0xEA, 0xA9	; 0x5C - 0x5F
;			.DB		0xD8, 0x20, 0x28, 0x23	; 0x60 - 0x63
;			.DB		0xD0, 0xAF, 0xAB, 0x7B	; 0x64 - 0x67
;			.DB		0xD7, 0xA0, 0x08, 0x09	; 0x68 - 0x6B
;			.DB		0x84, 0x2F, 0xEF, 0xED	; 0x6C - 0x6F
;			.DB		0xBD, 0xA8, 0x02, 0x21	; 0x70 - 0x73
;			.DB		0xA1, 0xAA, 0xA8, 0xBF	; 0x74 - 0x77
;			.DB		0xB8, 0x0A, 0x02, 0x11	; 0x78 - 0x7B
;			.DB		0x83, 0x63, 0xDF, 0x55	; 0x7C - 0x7F
;			.DB		0xEE, 0x08, 0x40, 0x45	; 0x80 - 0x83
;			.DB		0x8A, 0x8F, 0x55, 0xD5	; 0x84 - 0x87
;			.DB		0xB8, 0x80, 0x40, 0x14	; 0x88 - 0x8B
;			.DB		0xFF, 0xFF, 0xFF, 0xFF	; 0x8C - 0x8F

.CSEG
.ORG	0x3FD

			RET
;--------------------------------------------------------------------

.CSEG
.ORG 0x3FF
			BRN		ISR
