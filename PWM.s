  
#include <xc.inc>
global PWM_setup, PWM_set_note, PWM_play_note, PWM_stop_note

    psect	PWM_code, class=CODE
;note PR2 should store (1/(Tosc*PWM_freq*4*TMR2PRESCALE))-1 in order to adjust the freq of PWM
;512 in binary 1000000000 (Duty cycle) i.e. 50% duty cycle
PWM_setup:
    ;PWM period
    ;movlw   250 value for note
    ;movwf   PR2, A   ;moves value in w to PR2
    ;duty cycle
    ;bcf	    CCP4B1 ;second last bit
    ;bcf	    CCP4B0 ;last bit
    movlw   00001100B ;configure ccp1 
    movwf   CCP4CON, A
    movlw   10000000
    movwf   CCPR4L, A ;all but last 2 bits of duty cycle 1000000000
    ;output pin
    movlw   11110111B
    movwf   TRISG, A
    ;timer
;    bsf	    TMR2ON
    
    movlw   11111111B
    movwf   T2CON, A
;    bsf	    T2CKPS1 ;timer prescalar x16
;    bsf	    T2CKPS0 ;timer prescalar x16
;     ;PWM mode
    bsf	    CCP2M1
    bsf	    CCP2M0
    movlw   11000000B
    movwf   INTCON,A
    movlw   00000010B
    movwf   PIE1, A
    movlw   00000001B
    movwf   PIE2, A
    return
    
PWM_set_note: ;plays note corresponding to W using formula (PR2 value)
    movwf   PR2, A
    return

PWM_play_note:
    movlw   10000000
    movwf   CCPR4L, A
    return
    
PWM_stop_note:
    movlw   00000000
    movwf   CCPR4L, A
    return