#include <xc.inc>

global Keypad_Init, Keypad_Loop, check_nonote
extrn PWM_setup, PWM_set_note, PWM_play_note, PWM_stop_note, CCP5_Enable_Timer, CCP5_Disable_Timer
    
    
psect    udata_acs	    ; named variables in access ram
delay_curr:	    ds 1    ; reserve 1 byte for current counter val
delay_count1:	    ds 1    ; reserve 1 byte for counting
delay_count2:	    ds 1    ; reserve 1 byte for counting
delay_count3:	    ds 1    ; reserve 1 byte for counting
wtemp:		    ds 1    ; reserve 1 byte for temp w val
    
shortdelay:	    ds 1    ; reserve 1 byte for the short delay countdown
    
buttonval:	    ds 1    ; reserve 1 byte for the current button value (was PORTH)
keypadrowbits:	    ds 1    ; reserve 1 byte for keypad row value
keypadcolbits:	    ds 1    ; reserve 1 byte for keypad column value
keypadlastkey:	    ds 1    ; reserve 1 byte for last value fo keypad
    
keypaddelay:	    ds 1 
    
psect    Keypad_code, class=CODE

Keypad_Init:
    banksel PADCFG1
    bsf	    REPU
    clrf    LATE, A 
    
    movlw   0x00
    movwf   TRISD, A
    
    movlw   0x00
    movwf   keypadlastkey, A	;stores value from last cycle (see keypad_get_output:)
    
    ;call    Keypad_Loop
    return
    
Keypad_Read_Rows:
    movlw   0x0F	;sets ports 0-3 as input, pins 4-7 as output
    movwf   TRISE, A
    movlw   10
    call    delay
    movff   PORTE, keypadrowbits
    call    Keypad_Read_Col
    return

Keypad_Read_Col:
    movlw   0xF0
    movwf   TRISE, A
    movlw   10
    call    delay
    movff   PORTE, keypadcolbits
    return
    
Keypad_Get_Output: ;this loop actually makes sense
    call    Keypad_Read_Rows
    movf    keypadrowbits, W, A
    addwf   keypadcolbits, A    ;adds row+col to get keypad output (stores result in keypadcolbits)
    return
    
Keypad_Loop:
    call    Keypad_Get_Output
    call    check_samenote
    call    check_nonote
    call    check_0    
    movff   keypadcolbits, keypadlastkey ;stores current key as last key for next cycle
    ;bra	    Keypad_Loop
    return
    
check_samenote:
    movf    keypadcolbits, W, A 
    cpfseq  keypadlastkey, A	;compares to prev value
    call    not_samenote
    return ;else if equal does nothing
    
not_samenote:
    movff   keypadcolbits, PORTD ;if not equal, moves keypad value to PORTD (output)
    return
    
check_nonote:
    movlw   0xFF    ;corresponds to keypress 0
    cpfseq  PORTD, A
    return
    call    CCP5_Disable_Timer
    ;do things if button corresponds to 1
    return
    
check_0:
    movlw   0xBE    ;corresponds to keypress 0
    cpfseq  PORTD, A
    bra    check_1   
    ;do things if button corresponds to 1
    movlw   0x00    ;displays button value on buttonval
    movwf   buttonval, A  
    ; set octave to lower (PRSCL = 4)
    call    CCP5_Disable_Timer
    ;setting prescalar to 4 (half freq)
    bsf	    T1CKPS1
    bcf	    T1CKPS0
    
    
    return
    
check_1:
    movlw   0x77    ;corresponds to keypress 1
    cpfseq  PORTD, A
    bra    check_2
    
    ;do things if button corresponds to 1
    movlw   0x01    ;displays button value on portH
    movwf   buttonval, A
    
    ; set counter max to 478
;    movlw   00000001B	;CCP high byte register. Upper byte of number timer is counting to
;    movwf   CCPR5H, A
;    movlw   11011110B	;CCP low byte register. Lower byte of number timer is counting to
;    movwf   CCPR5L, A

    movlw   11101111B	;CCP low byte register. Lower byte of number timer is counting to
    movwf   CCPR5L, A
    call    CCP5_Enable_Timer
    
    return

check_2:
    movlw   0xB7    ;corresponds to keypress 2
    cpfseq  PORTD, A
    bra   check_3
    
    ;do things if button corresponds to 2
    movlw   0x02    ;displays button value on portH
    movwf   buttonval, A
    
    ;set counter max to 451
    movlw   11100001B	;CCP low byte register. Lower byte of number timer is counting to
    movwf   CCPR5L, A
    call    CCP5_Enable_Timer
    
    return

check_3:
    movlw   0xD7    ;corresponds to keypress 3
    cpfseq  PORTD, A
    bra    check_4
    
    ;do things if button corresponds to 3
    movlw   0x03   ;displays button value on portH
    movwf   buttonval, A
    
    ;set counter max to 426
    movlw   11010101B	;CCP low byte register. Lower byte of number timer is counting to
    movwf   CCPR5L, A
    call    CCP5_Enable_Timer
    
    return

check_4:
    movlw   0x7B    ;corresponds to keypress 4
    cpfseq  PORTD, A
    bra    check_5
    
    ;do things if button corresponds to 4
    movlw   0x04   ;displays button value on portH
    movwf   buttonval, A
    
    ; set counter max to 379
    movlw   10111110B	;CCP low byte register. Lower byte of number timer is counting to
    movwf   CCPR5L, A
    call    CCP5_Enable_Timer
    
    return

check_5:
    movlw   0xBB    ;corresponds to keypress 5
    cpfseq  PORTD, A
    bra    check_6
    
    ;do things if button corresponds to 5
    movlw   0x05   ;displays button value on portH
    movwf   buttonval, A
    
    ; set counter max to 358
    movlw   10110011B	;CCP low byte register. Lower byte of number timer is counting to
    movwf   CCPR5L, A
    call    CCP5_Enable_Timer
    
    return
    
check_6:
    movlw   0xDB    ;corresponds to keypress 6
    cpfseq  PORTD, A
    bra	    check_7
    
    ;do things if button corresponds to 6
    movlw   0x06   ;displays button value on portH
    movwf   buttonval, A
    
    ; set counter max to 338
    movlw   10101001B	;CCP low byte register. Lower byte of number timer is counting to
    movwf   CCPR5L, A
    call    CCP5_Enable_Timer
    
    return

check_7:
    movlw   0x7D    ;corresponds to keypress 7
    cpfseq  PORTD, A
    bra	    check_8
    
    ;do things if button corresponds to 7
    movlw   0x07   ;displays button value on portH
    movwf   buttonval, A
    
    ; set counter max to 301
    movlw   10010110B	;CCP low byte register. Lower byte of number timer is counting to
    movwf   CCPR5L, A
    call    CCP5_Enable_Timer
    
    return
    
check_8:
    movlw   0xBD    ;corresponds to keypress 8
    cpfseq  PORTD, A
    bra	    check_9
    
    ;do things if button corresponds to 8
    movlw   0x08   ;displays button value on portH
    movwf   buttonval, A
    
    ; set counter max to 284
    movlw   10001110B	;CCP low byte register. Lower byte of number timer is counting to
    movwf   CCPR5L, A
    call    CCP5_Enable_Timer
    
    return
    
check_9:
    movlw   0xDD    ;corresponds to keypress 9
    cpfseq  PORTD, A
    bra	    check_A
    
    ;do things if button corresponds to 9
    movlw   0x09   ;displays button value on portH
    movwf   buttonval, A
    
    ; set counter max to 268
    movlw   10000110B	;CCP low byte register. Lower byte of number timer is counting to
    movwf   CCPR5L, A
    call    CCP5_Enable_Timer
    
    return
    
check_A:
    movlw   0x7E    ;corresponds to keypress A
    cpfseq  PORTD, A
    bra     check_B
    
    ;do things if button corresponds to A
    movlw   0x0a   ;displays button value on portH
    movwf   buttonval, A
    ;Lowest octave (prescale 8)
    call    CCP5_Disable_Timer
    ;setting prescalar to 8 (halves freq again. Lowst octave)
    bsf	    T1CKPS1
    bsf	    T1CKPS0	
    
    return
    
check_B:
    movlw   0xDE    ;corresponds to keypress B
    cpfseq  PORTD, A
    bra	    check_C
    ;do things if button corresponds to B
    movlw   0x0b   ;displays button value on portH
    movwf   buttonval, A
    
    ; set octave to central (PRSCL = 2)
    call    CCP5_Disable_Timer
    ;resetting back to original freq (prescale 2)
    bcf	    T1CKPS1
    bsf	    T1CKPS0
    
    return
    
check_C:
    movlw   0xEE    ;corresponds to keypress C
    cpfseq  PORTD, A
    bra    check_D
    ;do things if button corresponds to C
    movlw   0x0c   ;displays button value on portH
    movwf   buttonval, A
    ; set octave to upper (PRSCL = 1)
    call    CCP5_Disable_Timer
    ;setting prescalar to 1 (faster double freq)
    bcf	    T1CKPS1
    bcf	    T1CKPS0
    
    return
    
check_D:
    movlw   0xED    ;corresponds to keypress D
    cpfseq  PORTD, A
    bra    check_E
    ;do things if button corresponds to D
    movlw   0x0e   ;displays button value on portH
    movwf   buttonval, A
    
    ; set counter max to 253
    movlw   01111111B	;CCP low byte register. Lower byte of number timer is counting to
    movwf   CCPR5L, A
    call    CCP5_Enable_Timer
    
    return
    
check_E:
    movlw   0xEB    ;corresponds to keypress E
    cpfseq  PORTD, A
    bra    check_F
    ;do things if button corresponds to E
    movlw   0x0E   ;displays button value on portH
    movwf   buttonval, A
    
    ; set counter max to 319
    movlw   10011111B	;CCP low byte register. Lower byte of number timer is counting to
    movwf   CCPR5L, A
    call    CCP5_Enable_Timer
    
    return
    
check_F:
    movlw   0xE7    ;corresponds to keypress F
    cpfseq  PORTD, A
    return
    ;do things if button corresponds to F
    movlw   0x0F   ;displays button value on portH
    movwf   buttonval, A
    
    ; set counter max to 402
    movlw   11001001B	;CCP low byte register. Lower byte of number timer is counting to
    movwf   CCPR5L, A
    call    CCP5_Enable_Timer
    
    return

delay:
    movlw   0x40
    movwf   keypaddelay, A
    call    delay_loop
    return
delay_loop:
    decfsz  keypaddelay, A
    bra	    delay_loop
    return
