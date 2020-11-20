#include <xc.inc>
	
global	CCP_Int_Hi
    
psect	CCP_interrupt_code, class=CODE
	
CCP_Int_Hi:
	btfss	CCP5IF		; check that this is timer0 interrupt
	retfie	f		; if not then return
	movlw	0x00
	movwf	TMR1H		;resetting timer counters
	movwf	TMR1L		;resetting timer counters
	;movlw	0xFF
	;movwf	PORTD, A
	incf	LATD, F, A	; increment PORTD
	;call	DAC_Send_Data1
	bcf	CCP5IF		; clear interrupt flag
	retfie	f		; fast return from interrupt