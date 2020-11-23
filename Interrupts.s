#include <xc.inc>
	
global	CCP5_Int_Hi, CCP6_Int_Hi, Wave_Setup
    
extrn	check_nonote

psect    udata_acs        ; named variables in access ram
    wavetype:		ds 1    ; reserve 1 byte for wavetype (saw = 0, square = 1)
    saw:		ds 1    ; reserve 1 byte to compare (saw = 0)
    square:		ds 1    ; reserve 1 byte to compare (square = 1)
    wavecounter:	ds 1    ; reserve 1 byte for the square wave counter
    tri:		ds 1	; reserve 1 byte to compare (tri = 2)
    tri_state:		ds 1
    
psect	CCP_interrupt_code, class=CODE
	
Wave_Setup:
	movlw   0x00
	movwf	saw, A
	movwf	LATH, A
	movlw	0x01
	movwf	wavetype, A
	movwf	tri_state, A
	movwf	square, A
	movlw	0x02
	movwf	tri, A
	movlw	64
	movwf	wavecounter, A
	return
	
CCP5_Int_Hi:
	call	check_nonote
	movlw	0x00
	movwf	TMR1H, A	;resetting timer counters
	movwf	TMR1L, A		;resetting timer counters
	movf	wavetype, W, A
typecheck1:
	cpfseq	saw, A
	bra	typecheck2
	bra	saw_inc
typecheck2:
	cpfseq	square, A
	bra	typecheck3
	bra	square_inc
typecheck3:
	;cpfseq	sin, A
	;bra	typecheck4
	bra	tri_inc
	
saw_inc:
	incf	LATH, F, A	; increment PORTD
	incf	LATH, F, A	;(increment twice to get step of 2)
	bcf	CCP5IF		; clear interrupt flag
	retfie	f		; fast return from interrupt
	
square_inc:
	decfsz	wavecounter, A
	bra	square_end
	call	square_fliptest
square_end:
	bcf	CCP5IF
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
    movf    tri_state, W, A
    addwf   LATH, A
    addwf   LATH, A
    decfsz  wavecounter, A
    bra	    tri_end
    call    tri_fliptest
tri_end:
    bcf	    CCP5IF
    retfie    f
tri_fliptest:
    movlw    0xff
    cpfseq    tri_state, A
    bra    tri_01
    bra    tri_FF
tri_FF:
    movlw    0x01
    movwf    tri_state, A
    bra    tri_postflip
tri_01:
    movlw    0xFF
    movwf    tri_state, A
    bra    tri_postflip
tri_postflip:
    movlw    64
    movwf    wavecounter, A
    return


CCP6_Int_Hi:
	btfss	CCP6IF		; check that this is timer3 interrupt
	retfie	f		; if not then return
	movlw	0x00
	movwf	TMR3H, A	;resetting timer counters
	movwf	TMR3L, A	;resetting timer counters
	incf	LATD, F, A	; increment PORTD
	bcf	CCP6IF		; clear interrupt flag
	retfie	f		; fast return from interrupt
	
;CCP5_Int_Hi:
;    btfss    CCP5IF        ; check that this is timer0 interrupt
;    retfie    f        ; if not then return
;    movlw    0x00
;    movwf    TMR1H, A    ;resetting timer counters
;    movwf    TMR1L, A        ;resetting timer counters
;    cpfseq    saw
;    bra    square_inc
;    bra    saw_inc
;    
;saw_inc:
;    incf    LATH, F, A    ; increment PORTD
;    bcf    CCP5IF        ; clear interrupt flag
;    retfie    f        ; fast return from interrupt
;    
;square_inc:
;    decfsz    squarecounter, A
;    bra    square_end
;    call    square_fliptest
;square_end:
;    bcf    CCP5IF
;    retfie    f
;    
;square_fliptest:
;    movlw    0xFF
;    cpfseq    LATH, A
;    bra    square_00
;    bra    square_FF
;square_FF:
;    incf    LATH, A
;    bra    square_postflip
;square_00:
;    decf    LATH, A
;    bra    square_postflip
;square_postflip:
;    movlw    128
;    movwf    squarecounter, A
;    return


