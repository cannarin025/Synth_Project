#include <xc.inc>
    
global CCP5_Setup, CCP5_Enable_Timer, CCP5_Disable_Timer 

psect	Compare_code, class=CODE

CCP5_Setup: ; uses timer1
    
    ; Timer 1 setup
    movlw   00011010B	; Timer 1 config. Bit 6 set Fosc/4 (0). Bit 5-4 set init timer prescale to 2 (01)
    movwf   T1CON, A
    
    ; Compare setup
    bsf	    CCP5IP	; CCP5 high priority interrupt
    movlw   11000000B	; interrupt config. Bit 7 enable global interrupts (1), Bit 6 enable peripheral interrupts (1)
    movwf   INTCON, A
    
    movlw   00001010B	; compare mode config. Bits 3-0 generate software interrupt on compare match
    movwf   CCP5CON, A
    
    movlw   00000000B	; CCP high byte register. Upper byte of number timer is counting to
    movwf   CCPR5H, A
    
    bsf	    GIE		; Enable all interrupts
    bsf	    CCP5IE	; Enable CCP5 interrupts
    
    return
    
CCP5_Enable_Timer: 
    bsf	    TMR1ON	; Turns on timer
    return
    
CCP5_Disable_Timer:
    bcf	    TMR1ON	; Turns off timer
    movlw   0x00
    movwf   PORTH, A
    return