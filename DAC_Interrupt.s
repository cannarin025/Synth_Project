#include <xc.inc>
	
global	DAC_Setup1, DAC_Int_Hi, DAC_Send_Data1
    
psect	dac_code, class=CODE
	
DAC_Int_Hi:
	btfss	TMR0IF		; check that this is timer0 interrupt
	retfie	f		; if not then return
	;movlw	0xFF
	;movwf	PORTD, A
	incf	LATD, F, A	; increment PORTD
	call	DAC_Send_Data1
	bcf	TMR0IF		; clear interrupt flag
	retfie	f		; fast return from interrupt

DAC_Setup1:
	clrf	TRISC, A	;Set PORTC as all outputs
	clrf	TRISD, A	; Set PORTD as all outputs
	clrf	LATD, A		; Clear PORTD outputs
	movlw	10000111B	; Set timer0 to 16-bit, Fosc/4/256. Varying this doubles / halves freq ==> changes octave
	movwf	T0CON, A	; = 62.5KHz clock rate, approx 1sec rollover
	bsf	TMR0IE		; Enable timer0 interrupt
	bsf	GIE		; Enable all interrupts
	return

;CS	PORTC pin0
;WR	PORTC pin1
;Dat	PORTD

DAC_Send_Data1:			;writes data stored in W to DAC
	clrf	TRISD, A
	movwf	PORTD, A	;moves data to PORTJ
	;movlw	00000011B	;making sure CS and WR are kept high
	movlw	00000010B	;WR kept high
	movwf	PORTC, A
	
	;movlw	00000010B	;drops CS
	;movwf	PORTH, A
	;delay between
	
	movlw	00000000B	;drops WR
	movwf	PORTC, A
	;delay between
	
	movlw	00000010B	;raises WR and latches data
	movwf	PORTC, A
	;delay between
	
	;movlw	00000011B	;raises CS
	;movwf	PORTH, A
	return	
	
;DAC_Send_Data1:			;writes data stored in W to DAC
;	clrf	TRISJ, A
;	movwf	PORTJ, A	;moves data to PORTJ
;	;movlw	00000011B	;making sure CS and WR are kept high
;	movlw	00000010B	;WR kept high
;	movwf	PORTH, A
;	
;	;movlw	00000010B	;drops CS
;	;movwf	PORTH, A
;	;delay between
;	
;	movlw	00000000B	;drops WR
;	movwf	PORTH, A
;	;delay between
;	
;	movlw	00000010B	;raises WR and latches data
;	movwf	PORTH, A
;	;delay between
;	
;	;movlw	00000011B	;raises CS
;	;movwf	PORTH, A
;	return