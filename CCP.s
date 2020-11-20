#include <xc.inc>
    psect	CCP_code, class=CODE

    global  CCP_Setup
    
CCP_Setup:
    ;Timer 1 setup
    movlw   10000110B	; Set timer0 to 16-bit, Fosc/4/256. Varying this doubles / halves freq ==> changes octave. Timer starts off
    movwf   T1CON, A	; = 62.5KHz clock rate, approx 1sec rollover
    bsf	    TMR1ON	; Turns on timer
    ;bsf	    TMR1IE		; Enable timer0 interrupt
    ;bsf	    GIE		; Enable all interrupts
    
    ;Compare mode setup
    ;bsf	    INTCON
    movlw   11110000B
    movwf   INTCON, A
    bsf	    CCP5IE
    bsf	    CCP5IP	;CCP5 high priority interrupt
    movlw   00000000B	;CCP5 using tmr 1/2
    ;movwf   CCPTMSR1, A
    movlw   00001010B	;compare mode configuration to generate software interrupt on compare match
    movwf   CCP5CON, A
    movlw   00001000B	;CCP low byte register
    movwf   CCPR5L, A
    movlw   00001000B	;CCP high byte register
    movwf   CCPR5H
    return