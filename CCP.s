#include <xc.inc>
    
psect    udata_acs        ; named variables in access ram
    wavetype:        ds 1    ; reserve 1 byte for wavetype (saw = 0, square = 1)
    saw:            ds 1    ; reserve 1 byte to compare (saw = 0)
    square:            ds 1    ; reserve 1 byte to compare (square = 1)
    squarecounter:        ds 1    ; reserve 1 byte for the square wave counter
    
psect	CCP_code, class=CODE

    global  CCP5_Setup, CCP5_Enable_Timer, CCP5_Disable_Timer, CCP6_Setup, CCP6_Enable_Timer, CCP6_Disable_Timer

;CCP5
CCP5_Setup: ;using timer 1
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
    
CCP5_Set_Freq:
    return
    
CCP5_Enable_Timer: 
    bsf	    TMR1ON	; Turns on timer
    return
    
CCP5_Disable_Timer:
    bcf	    TMR1ON	; Turns off timer
    return
    

;CCP6
CCP6_Setup: ;using timer 3
    ;Timer 3 setup
    movlw   00001010B	; Timer 3 config. Bit 6 set Fosc (1) or Fosc/4 (0). Bit 5-4 set timer prescale (lower is faster) 8: 11, 4: 10, 2: 01, 1: 00 .
    movwf   T3CON, A	
    
    
    ;Compare mode setup
    bsf	    CCP6IP	;CCP5 high priority interrupt
    movlw   11000000B	;Enabling intcon high and low priority interrupts
    movwf   INTCON, A
    
    movlw   00001010B	;compare mode configuration to generate software interrupt on compare match
    movwf   CCP6CON, A
    
    movlw   11110110B	;CCP high byte register. Upper byte of number timer is counting to
    movwf   CCPR6H, A
    movlw   00100100B	;CCP low byte register. Lower byte of number timer is counting to
    movwf   CCPR6L, A
    
    bsf	    GIE		; Enable all interrupts
    bsf	    CCP6IE
    
    return
    
CCP6_Set_Freq:
    return
    
CCP6_Enable_Timer: 
    bsf	    TMR3ON	; Turns on timer
    return
    
CCP6_Disable_Timer:
    bcf	    TMR3ON	; Turns off timer
    return
