#include <xc.inc>
    psect	CCP_code, class=CODE

    global  CCP_Setup, CCP_Enable_Timer, CCP_Disable_Timer
    
CCP_Setup: ;using timer 1
    ;Timer 1 setup
    movlw   00010010B	; Timer 1 config. Bit 6 set Fosc (1) or Fosc/4 (0). Bit 5-4 set timer prescale (lower is faster) 8: 11, 4: 10, 2: 01, 1: 00 .
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
    
    return
    
CCP_Set_Freq:
    return
    
CCP_Enable_Timer: 
    bsf	    TMR1ON	; Turns on timer
    return
    
CCP_Disable_Timer:
    bcf	    TMR1ON	; Turns off timer
    return