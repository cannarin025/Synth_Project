#include <xc.inc>
   
global intchk_hi, DAC_Setup, DAC_Int_Hi, DAC_Send_Data
   
psect    udata_acs        ; named variables in access ram
sawval:            ds 1    ; reserve 1 byte for current counter val
psect	dac_code, class=CODE
   
intchk_hi:
    movlw   0xff
    movwf   PORTD, A
    btfss    TMR0IF ; check that the PWM called the interrupt
    retfie    f ; otherwise return
    incf    sawval ; increase sawval by 1
    movff    sawval, PORTD, A
    call DAC_Send_Data
    bcf        TMR0IF ; clear tmr2 interrupt flag
    retfie    f ; return
	
;DAC_Int_Hi:	
;	btfss	TMR0IF		; check that this is timer0 interrupt
;	retfie	f		; if not then return
;	incf	LATJ, F, A	; increment PORTD
;	call	DAC_Send_Data
;	bcf	TMR0IF		; clear interrupt flag
;	retfie	f		; fast return from interrupt

DAC_Setup:
	clrf	TRISD, A	; Set PORTD as all outputs
	clrf	LATD, A		; Clear PORTD outputs
	movlw	10000111B	; Set timer0 to 16-bit, Fosc/4/256. Varying this doubles / halves freq ==> changes octave
	movwf	T0CON, A	; = 62.5KHz clock rate, approx 1sec rollover
	bsf	TMR2IE		; Enable timer0 interrupt
	bsf	GIE		; Enable all interrupts
	return

;CS	PORTC pin0
;WR	PORTC pin1
;Dat	PORTD
	
DAC_Send_Data:			;writes data stored in W to DAC
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