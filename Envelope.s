#include <xc.inc>
 
global Keypad_Init, Keypad_Loop
    
psect    udata_acs	    ; named variables in access ram
envelope:	    ds 1    ; reserve 1 byte for current volume envelope val
Scounter:	    ds 1    ; reserve 1 byte for the sustain counter value
Acompare:	    ds 1    ; reserve 1 byte for 0xFF (to compare to)
Rcompare:	    ds 1    ; reserve 1 byte for 0x00 (to compare to)
envdelaycounter:    ds 1    ; reserve 1 byte for the delay counter value


    
; the folliwing should be user - controlled values:
Alength:	    ds 1    ; reserve 1 byte for the attack time
Snum:		    ds 1    ; reserve 1 byte for the sustain value
Slength:	    ds 1    ; reserve 1 byte for the sustain time
Dlength:	    ds 1    ; reserve 1 byte for the delay time
Rlength:	    ds 1    ; reserve 1 byte for the release time

    
psect    Keypad_code, class=CODE
    
; need to write envdelay to take w and delay by it
    
increnv:
    incf    envelope, F, A
    movf    Alength, W, A
    call    envdelaytime
    bra	    sustaincheck
    
Sdecrenv:
    decf    envelope, F, A
    movf    Slength, W, A
    call    envdelaytime
    bra	    delaycheck
    
Rdecrenv:
    decf    envelope, F, A
    movf    Rlength, W, A
    call    envdelaytime
    bra	    finish
    
envstart:
    movlw   0x00
    movwf    envelope, A
    movwf    Rcompare, A
    movlw    0xFF
    movwf    Acompare, A
   
attackcheck:
    movf    envelope, W, A
    cpfseq  Acompare, A
    bra	    increnv

sustaincheck:
    movf    envelope, W, A
    cpfseq  Snum, A
    bra	    Sdecrenv
    
delaycheck:
    cpfseq  ;KEY RELEASED
    bra	    delaycheck

releasecheck:
    movf    envelope
    cpfseq  Rcompare, A
    bra	    Rdecrenv
    
envdelaytime:
    movwf   envdelaycounter, A
    call    envdelayloop
envdelayloop:
    decfsz  envdelaycounter, A
    bra	    envdelayloop
    return
    
finish:
    end