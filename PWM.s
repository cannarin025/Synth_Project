#include <xc.inc>

;note PR2 should store (1/(Tosc*PWM_freq*4*TMR2PRESCALE))-1 in order to adjust the freq of PWM
;512 in binary 1000000000 (Duty cycle) i.e. 50% duty cycle
PWM_setup:
    movwf   PR2, A   ;moves value in w to PR2
    movlw   00001100B ;configure ccp1
    movwf   CCP1CON, A 
    movlw   10000000B
    movwf   CCPR1L, A ;all but last 2 bits of duty cycle 1000000000
    movlw   00000101B ;configure tmr2
    clrf    TRISC, A
    
    return