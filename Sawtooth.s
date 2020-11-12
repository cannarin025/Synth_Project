#include <xc.inc>
    
global sawloop
    
psect    udata_acs	    ; named variables in access ram
sawval:	    ds 1    ; reserve 1 byte for current counter val

shortdelay:	    ds 1    ; reserve 1 byte for the short delay countdown
    
psect    Keypad_code, class=CODE
    
sawloop:
    incf    sawval, A
    call    delay
    bra	    sawloop

delay:
    movlw   0xFF
    movwf   shortdelay, A
    call    delay_loop
delay_loop:
    decfsz  shortdelay, A
    bra	    delay_loop
    return
    