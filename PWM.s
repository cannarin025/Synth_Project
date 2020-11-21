#include <xc.inc>
global PWM_setup, PWM_set_note, PWM_play_note, PWM_stop_note

    psect	PWM_code, class=CODE
    
PWM_setup:
    movlw   00001100B ;configure ccp1 
    movwf   CCP4CON, A
    movlw   10000000
    movwf   CCPR4L, A ;all but last 2 bits of duty cycle 1000000000
    ;output pin
    movlw   11110111B
    movwf   TRISG, A
    ;timer
;    bsf        TMR2ON
    
    movlw   11111100B ; PRESCALER 16
    movwf   T2CON, A ; SET TO 11111100B FOR PRESCALER 1
    
;     ;PWM mode
    bsf        CCP2M1
    bsf        CCP2M0
    movlw   11000000B
    movwf   INTCON,A
    movlw   00000010B
    movwf   PIE1, A
;    movlw   00000001B
;    movwf   PIE2, A
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