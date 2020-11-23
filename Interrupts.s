#include <xc.inc>
	
global	CCP5_Int_Hi, CCP6_Int_Hi
    
extrn saw,wavetype,squarecounter,square
    
psect	CCP_interrupt_code, class=CODE
	
CCP5_Int_Hi:
	btfss	CCP5IF		; check that this is timer1 interrupt
	retfie	f		; if not then return
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
	bra	square_inc
	
saw_inc:
	incf	LATH, F, A	; increment PORTD
	bcf	CCP5IF		; clear interrupt flag
	retfie	f		; fast return from interrupt
	
square_inc:
	decfsz	squarecounter, A
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
	movlw	128
	movwf	squarecounter, A
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


