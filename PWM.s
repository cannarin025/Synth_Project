#include <xc.inc>
global PWM_setup, PWM_setup2

    psect	PWM_code, class=CODE
;note PR2 should store (1/(Tosc*PWM_freq*4*TMR2PRESCALE))-1 in order to adjust the freq of PWM
;512 in binary 1000000000 (Duty cycle) i.e. 50% duty cycle
PWM_setup:
    ;movlw   250000
    movlw   100
    movwf   PR2, A   ;moves value in w to PR2
    movlw   00001100B ;configure ccp1
    movwf   CCP1CON, A
    movlw   00000011B
    movwf   TMR2, A
    bsf	    TMR2ON
    bsf	    T2CKPS1 ;timer prescalar x16
    movlw   10000000B
    movwf   CCPR1L, A ;all but last 2 bits of duty cycle 1000000000
    movlw   00000101B ;configure tmr2
    clrf    TRISC, A
    
    return
   
PWM_setup2:
    ;PWM period
    movlw   100
    movwf   PR2, A   ;moves value in w to PR2
    ;duty cycle
    ;bcf	    CCP4B1 ;second last bit
    ;bcf	    CCP4B0 ;last bit
    movlw   00001100B ;configure ccp1
    movwf   CCP4CON, A
    movwf   CCPR4L, A ;all but last 2 bits of duty cycle 1000000000
    ;output pin
    movlw   11110111B
    movwf   TRISG, A
    ;timer
    bsf	    TMR2ON
    bsf	    T2CKPS1 ;timer prescalar x16
     ;PWM mode
    bsf	    CCP2M1
    bsf	    CCP2M0
    return