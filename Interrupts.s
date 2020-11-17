#include <xc.inc>
    
global intchk_hi;,intchk_lo
    
psect    udata_acs	    ; named variables in access ram
sawval:		    ds 1    ; reserve 1 byte for current counter val
psect    Keypad_code, class=CODE
    
intchk_hi:
    btfss	TMR2IF ; check that the PWM called the interrupt
    retfie	f ; otherwise return
    incf	sawval ; increase sawval by 1
    bcf		TMR2IF ; clear tmr2 interrupt flag
    retfie	f ; return
    
;intchk_lo:
;    retfie
    