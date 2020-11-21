#include <xc.inc>
	
global	CCP_Int_Hi
    
extrn saw,wavetype,squarecounter,square
    
psect	CCP_interrupt_code, class=CODE
	
CCP_Int_Hi:
	btfss	CCP5IF		; check that this is timer0 interrupt
	retfie	f		; if not then return
	movlw	0x00
	movwf	TMR1H, A	;resetting timer counters
	movwf	TMR1L, A		;resetting timer counters
	movf	wavetype, W, A
	cpfseq	saw, A
	bra	square_inc
	bra	saw_inc
	
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

	
	