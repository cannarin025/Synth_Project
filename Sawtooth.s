
    
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    #include <xc.inc>
 
global Keypad_Init, Keypad_Loop
    
psect    udata_acs	    ; named variables in access ram
sawval:	    ds 1    ; reserve 1 byte for current counter val
sawmax:	    ds 1
sawmin:	    ds 1




delay_count1:	    ds 1    ; reserve 1 byte for counting
delay_count2:	    ds 1    ; reserve 1 byte for counting
delay_count3:	    ds 1    ; reserve 1 byte for counting
wtemp:		    ds 1    ; reserve 1 byte for temp w val
    
shortdelay:	    ds 1    ; reserve 1 byte for the short delay countdown
    
psect    Keypad_code, class=CODE
    
sawloop:
    incf    sawval, A
    call    delay
  

delay:
    movlw   0xFF
    movwf   shortdelay, A
    call    delay_loop
delay_loop:
    decfsz  shortdelay, A
    bra	    delay_loop
    return