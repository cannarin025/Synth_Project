#include <xc.inc>
    
global	Wave_Setup, Wave_Check, saw_inc, square_inc, tri_inc, sin_inc ; export subroutines
global	wavetype, saw, square, wavecounter, tri, tri_state, sin ; export variables

extrn	sin_reset, sin_next_val ; import subroutines
    
psect	udata_acs ; reserve data space in access ram
	
    wavetype:		ds 1    ; reserve 1 byte for wavetype (saw = 0, square = 1)
    saw:		ds 1    ; reserve 1 byte to compare (saw = 1)
    square:		ds 1    ; reserve 1 byte to compare (square = 1)
    wavecounter:	ds 1    ; reserve 1 byte for the square wave counter
    tri:		ds 1	; reserve 1 byte to compare (tri = 2)
    tri_state:		ds 1	; reserve 1 byte for triangle gradient
    sin:		ds 1	; reserve 1 byte to compare (sin = 4)

psect    Wave_code, class = CODE
    
Wave_Setup:		    ; initialise the wave types and values used for each wave
    
    ; define constant wave types for comparison:
    movlw   0x01
    movwf   square, A
    movlw   0x02
    movwf   saw, A
    movlw   0x04
    movwf   tri, A
    movlw   0x08
    movwf   sin, A

    ; set values required for wave generation
    movlw   0x04
    movwf   tri_state, A
    movlw   64
    movwf   wavecounter, A

    call    Wave_Check		; check which wave type is currently chosen
    clrf    LATH, A		; ensure port H is clear

    return
    
Wave_Check:
    movff   PORTJ, wavetype, A	; for printing wave type to LCD in the future
    movff   PORTJ, PORTG, A	; for debugging
    return
    
saw_inc:		; saw wave generation
	movlw	0x02
	addwf	LATH, A		; increment port H by 2 (output)
	retfie	f		; fast return from interrupt
	
square_inc:		; square wave generation
	decfsz	wavecounter, A	; every 64 interrupts, go to fliptest
	bra	square_end	; else go to end
	call	square_fliptest
square_end:
	retfie	f
	
square_fliptest:
	movlw	0xFF
	cpfseq	LATH, A		; if currently at 0xFF, go to square_FF
	bra	square_00	; else if currently at 0x00, go to square_00
	bra	square_FF
square_FF:
	incf	LATH, A		; increase by 1 to overflow to 0x00
	bra	square_postflip
square_00:
	decf	LATH, A		; decrease by 1 to overflow to 0xFF
	bra	square_postflip
square_postflip:
	movlw	64		; reset the counter 
	movwf	wavecounter, A
	return

tri_inc:		; triangle wave generation
	movf	tri_state, W, A
	addwf	LATH, A		; increment by tri_state (either +4 or -4)
	decfsz	wavecounter, A
	bra	tri_end		; decrease wavecounter. If = zero, go to flipetst
	call	tri_fliptest
tri_end:
	retfie	f
tri_fliptest:
	movlw	0xFC		; if tri_state = +4, flip to -4, if = -4, flip to +4
	cpfseq	tri_state, A
	bra	tri_04
	bra	tri_FC
tri_FC:
	movlw	0x04
	movwf	tri_state, A
	bra	tri_postflip
tri_04:
	movlw	0xFC
	movwf	tri_state, A
	bra	tri_postflip
tri_postflip:
	movlw	64		; reset counter
	movwf	wavecounter, A
	return
	
sin_inc:		    ; sin wave generation
	call	sin_next_val	; get the next sine value
	decfsz	wavecounter, A	; when table ends, go to sin_rst
	bra	sin_end
	bra	sin_rst
sin_end:
	retfie	f
sin_rst:
	call	sin_reset	;refresh the table
	movlw	64
	movwf	wavecounter, A
	bra	sin_end