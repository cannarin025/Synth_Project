#include <xc.inc>
    
global  CCP_Setup, CCP_Enable_Timer, CCP_Disable_Timer
global saw, square, squarecounter,wavetype

psect    udata_acs	    ; named variables in access ram
wavetype:	    ds 1    ; reserve 1 byte for wavetype (saw = 0, square = 1)
saw:		    ds 1    ; reserve 1 byte to compare (saw = 0)
square:		    ds 1    ; reserve 1 byte to compare (square = 1)
squarecounter:	    ds 1    ; reserve 1 byte for the square wave counter
    
psect	CCP_code, class=CODE

    
    
CCP_Setup: ;using timer 1
    ;Timer 1 setup
    movlw   00001010B	; Timer 1 config. Bit 6 set Fosc (1) or Fosc/4 (0). Bit 5-4 set timer prescale (lower is faster) 8: 11, 4: 10, 2: 01, 1: 00 .
    movwf   T1CON, A	
    
    
    ;Compare mode setup
    bsf	    CCP5IP	;CCP5 high priority interrupt
    movlw   11000000B	;Enabling intcon high and low priority interrupts
    movwf   INTCON, A
    
    movlw   00001010B	;compare mode configuration to generate software interrupt on compare match
    movwf   CCP5CON, A
    
    movlw   11110100B	;CCP high byte register. Upper byte of number timer is counting to
    movwf   CCPR5H, A
    movlw   00100100B	;CCP low byte register. Lower byte of number timer is counting to
    movwf   CCPR5L, A
    
    bsf	    GIE		; Enable all interrupts
    bsf	    CCP5IE
    
    ; set wavetype as saw wave
    
    movlw   0x01
    movwf   square, A
    movwf   wavetype, A ; set as sq wave
    movlw   0x00
    movwf   saw, A
    ;movwf   wavetype, A ; set as saw wave
    movlw   128
    movwf   squarecounter, A
    
    return
    
;CCP_Setup: ;using timer0
;    ;Timer 0 setup
;    movlw   01000110B	; Set timer0 to 16-bit, Timer frequency = Fosc/4/Prescale. Bits 0:2 are prescale. Varying this doubles / halves freq ==> changes octave. Timer starts off
;    movwf   T0CON, A	; = 62.5KHz clock rate, approx 1sec rollover
;    
;    
;    ;Compare mode setup
;    bsf	    CCP5IP	;CCP5 high priority interrupt
;    movlw   11000000B	;Enabling intcon high and low priority interrupts
;    movwf   INTCON, A
;    
;    movlw   00001010B	;compare mode configuration to generate software interrupt on compare match
;    movwf   CCP5CON, A
;    movlw   00000001B	;CCP low byte register
;    movwf   CCPR5L, A
;    movlw   00000000B	;CCP high byte register
;    movwf   CCPR5H, A
;    
;    bsf	    GIE		; Enable all interrupts
;    bsf	    CCP5IE
;    
;    return
    
CCP_Set_Freq:
    return
    
CCP_Enable_Timer: 
    bsf	    TMR1ON	; Turns on timer
    return
    
CCP_Disable_Timer:
    bcf	    TMR1ON	; Turns off timer
    return