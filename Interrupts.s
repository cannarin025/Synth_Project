#include <xc.inc>
	
global	CCP5_Int_Hi, CCP6_Int_Hi, Wave_Setup, Wave_Check, sin_setup, sin_get_next_val
    
extrn	check_nonote, sin_reset

psect    udata_acs        ; named variables in access ram
    wavetype:		ds 1    ; reserve 1 byte for wavetype (saw = 0, square = 1)
    saw:		ds 1    ; reserve 1 byte to compare (saw = 0)
    square:		ds 1    ; reserve 1 byte to compare (square = 1)
    wavecounter:	ds 1    ; reserve 1 byte for the square wave counter
    tri:		ds 1	; reserve 1 byte to compare (tri = 2)
    tri_state:		ds 1
    sin:		ds 1
    
psect	CCP_interrupt_code, class=CODE
	
Wave_Setup:
	movlw   0x02
	movwf	saw, A
	
	clrf	LATH, A
	
	movlw	0x02
	movwf	tri_state, A
	
	movlw	0x04
	movwf	tri, A
	
	movlw	0x08
	movwf	sin, A
	
	movlw	0x01
	movwf	square, A

	movlw	64
	movwf	wavecounter, A
	call	Wave_Check
	return

;maybe instead try just comparing portg with saw, square, tri instead of wavetype.
;also change wavecheck to work.
	
Wave_Check:
    movff   PORTJ, wavetype, A
    movff   PORTJ, PORTG, A
    return

;CCP5_Int_Hi:
;	clrf	TMR1L, A		;resetting timer counters
;	clrf	TMR1H, A	;resetting timer counters
;	bcf	CCP5IF
;	call	check_nonote
;	;bra	sin_inc	    ;force sin wave

CCP5_Int_Hi:
    btfss    RBIF
    bra    Timer_Int
    bra    RB_Int

Timer_Int:
    clrf    TMR1L, A        ;resetting timer counters
    clrf    TMR1H, A    ;resetting timer counters
    bcf	    CCP5IF
    call    check_nonote
    ;bra    sin_inc        ;force sin wave
    
typecheck1:
	movf	wavetype, W, A
	cpfseq	saw, A
	bra	typecheck2
	bra	saw_inc
typecheck2:
	cpfseq	square, A
	bra	typecheck3
	bra	square_inc
typecheck3:
	cpfseq	sin, A
	bra	typecheck4
	bra	sin_inc
	
	return
typecheck4:
	bra	tri_inc
	return
	
saw_inc:
	movlw	0x02
	addwf	LATH, A ; clear interrupt flag
	retfie	f		; fast return from interrupt
	
square_inc:
	decfsz	wavecounter, A
	bra	square_end
	call	square_fliptest
square_end:
	;bcf	CCP5IF
	retfie	f
	
square_fliptest:
	movlw	0xFF
	cpfseq	LATH, A
	bra	square_00
	bra	square_FF
square_FF:
	incf	LATH, A
	bra	square_postflip
square_00:
	decf	LATH, A
	bra	square_postflip
square_postflip:
	movlw	64
	movwf	wavecounter, A
	return

tri_inc:
	movf	tri_state, W, A
	addwf	LATH, A
	decfsz	wavecounter, A
	bra	tri_end
	call	tri_fliptest
tri_end:
	;bcf	CCP5IF
	retfie	f
tri_fliptest:
	movlw	0xFC
	cpfseq	tri_state, A
	bra	tri_04
	bra	tri_FC
tri_FC:
	movlw	0x02
	movwf	tri_state, A
	bra	tri_postflip
tri_04:
	movlw	0xFE
	movwf	tri_state, A
	bra	tri_postflip
tri_postflip:
	movlw	64
	movwf	wavecounter, A
	return
	
sin_inc:
	call	sin_get_next_val
	decfsz	wavecounter, A
	bra	sin_end
	bra	sin_rst
sin_end:
	retfie	f
sin_rst:
	call	sin_reset
	movlw	64
	movwf	wavecounter, A
	bra	sin_end

RB_Int:
    call    Wave_Check
    bcf        RBIF
    retfie    f

CCP6_Int_Hi:
	btfss	CCP6IF		; check that this is timer3 interrupt
	retfie	f		; if not then return
	movlw	0x00
	movwf	TMR3H, A	;resetting timer counters
	movwf	TMR3L, A	;resetting timer counters
	incf	LATD, F, A	; increment PORTD
	bcf	CCP6IF		; clear interrupt flag
	retfie	f		; fast return from interrupt