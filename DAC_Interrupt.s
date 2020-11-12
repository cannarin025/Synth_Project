#include <xc.inc>
	
global	DAC_Setup, DAC_Int_Hi, DAC_Send_Data
    
psect	dac_code, class=CODE
	
DAC_Int_Hi:	
	btfss	TMR0IF		; check that this is timer0 interrupt
	retfie	f		; if not then return
	incf	LATJ, F, A	; increment PORTD
	bcf	TMR0IF		; clear interrupt flag
	retfie	f		; fast return from interrupt

DAC_Setup:
	clrf	TRISJ, A	; Set PORTD as all outputs
	clrf	LATJ, A		; Clear PORTD outputs
	movlw	10000111B	; Set timer0 to 16-bit, Fosc/4/256
	movwf	T0CON, A	; = 62.5KHz clock rate, approx 1sec rollover
	bsf	TMR0IE		; Enable timer0 interrupt
	bsf	GIE		; Enable all interrupts
	return

;CS	PORTH pin0
;WR	PORTH pin1
;Dat	PORTJ
	
DAC_Send_Data:			;writes data stored in W to DAC
	clrf	TRISJ, A
	movwf	PORTJ, A	;moves data to PORTJ
	movlw	00000011B	;making sure CS and WR are kept high
	movwf	PORTH, A
	
	movlw	00000010B	;drops CS
	movwf	PORTH, A
	;delay between
	
	movlw	00000000B	;drops WR
	movwf	PORTH, A
	;delay between
	
	movlw	00000010B	;raises WR and latches data
	movwf	PORTH, A
	;delay between
	
	movlw	00000011B	;raises CS
	movwf	PORTH, A
	
	end