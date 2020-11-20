#include <xc.inc>
global PWM_setup, PWM_set_note, PWM_play_note, PWM_stop_note

    psect	PWM_code, class=CODE
;note PR2 should store (1/(Tosc*PWM_freq*4*TMR2PRESCALE))-1 in order to adjust the freq of PWM
;512 in binary 1000000000 (Duty cycle) i.e. 50% duty cycle
PWM_setup:
    movlw   00001100B ;configure ccp1 
    movwf   CCP4CON, A
    movlw   10000000
    movwf   CCPR4L, A ;all but last 2 bits of duty cycle 1000000000
    ;output pin
    movlw   11110111B
    movwf   TRISG, A
    ;timer
    ;movlw   11110000 ;TOUTPSx set timer postscale 1-16
    ;movwf   T2CON, A
    bsf	    TMR2ON
    bsf	    T2CKPS1 ;timer prescalar x16
    bsf	    T2CKPS0 ;timer prescalar x16
     ;PWM mode
    bsf	    CCP2M1
    bsf	    CCP2M0
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