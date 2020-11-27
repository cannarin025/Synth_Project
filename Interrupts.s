#include <xc.inc>
	
global CCP5_Int_Hi ; export subroutines
    
extrn	check_nonote, sin_inc, saw_inc, square_inc, tri_inc ; import subroutines
extrn	square, saw, tri, sin, tri_state, wavecounter, wavetype ; import variables
    
psect	Interrupt_code, class=CODE

CCP5_Int_Hi:
	clrf	TMR1L, A	; reset timer counters
	clrf	TMR1H, A	; reset timer counters
	bcf	CCP5IF		; remove CCP5 interrupt flag
	call	check_nonote	; ensure a key is still held
	;goto	sin_inc		; force sin wave (debugging)
typecheck1:
	movf	wavetype, W, A	; move the wavetype value to W
	cpfseq	tri, A		; go to tri_inc if triangle wave selected
	bra	typecheck2	; else move on
	goto	tri_inc
typecheck2:
	cpfseq	square, A	; go to square_inc if square wave selected
	bra	typecheck3	; else move on
	goto	square_inc
typecheck3:
	cpfseq	sin, A		; go to sin_inc if sine wave selected
	bra	typecheck4	; else move on
	goto	sin_inc
typecheck4:
	goto	saw_inc		; go to saw_inc when none other selected