#include <xc.inc>

global Keypad_Init, Keypad_Loop
extrn PWM_setup, PWM_set_note, PWM_play_note, PWM_stop_note
    
    
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
    
psect    Keypad_code, class=CODE

Keypad_Init:
    banksel PADCFG1
    bsf	    REPU
    clrf    LATE, A 
    
    movlw   0x00
    movwf   TRISJ, A
    
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
    movf    keypadrowbits, W, A
    addwf   keypadcolbits, A	;adds row+col to get keypad output (stores result in keypadcolbits)
    return
    
Keypad_Loop:
    call    Keypad_Read_Rows
    call    Keypad_Get_Output
    call    check_samenote
    movff   keypadcolbits, keypadlastkey ;stores current key as last key for next cycle
    bra	    Keypad_Loop
    return
    
check_samenote:
    movf    keypadcolbits, W, A 
    cpfseq  keypadlastkey, A	;compares to prev value
    call    not_samenote
    return ;else if equal does nothing
    
not_samenote:
    movff   keypadcolbits, PORTJ ;if not equal, moves keypad value to PORTJ (output)
    bra	    check_nonote
    return
    
check_nonote:
    movlw   0xFF    ;corresponds to keypress 0
    cpfseq  PORTJ, A
    bra	    check_0
    call    PWM_stop_note
    ;do things if button corresponds to 1
    return
    
check_0:
    movlw   0xBE    ;corresponds to keypress 0
    cpfseq  PORTJ, A
    bra    check_1   
    ;do things if button corresponds to 1
    movlw   0x00    ;displays button value on buttonval
    movwf   buttonval, A  
    
    ; set octave to central (PRSCL = 2)
    movlw   01010010B	; Timer 1 config. Bit 6 set Fosc (1) or Fosc/4 (0). Bit 5-4 set timer prescale (lower is faster) 8: 11, 4: 10, 2: 01, 1: 00 .
    movwf   T1CON, A	
    
    return
    
check_1:
    movlw   0x77    ;corresponds to keypress 1
    cpfseq  PORTJ, A
    bra    check_2
    
    ;do things if button corresponds to 1
    movlw   0x01    ;displays button value on portH
    movwf   buttonval, A
    
    ; set counter max to 478
    movlw   00000001B	;CCP high byte register. Upper byte of number timer is counting to
    movwf   CCPR5H, A
    movlw   11011110B	;CCP low byte register. Lower byte of number timer is counting to
    movwf   CCPR5L, A
    
    return

check_2:
    movlw   0xB7    ;corresponds to keypress 2
    cpfseq  PORTJ, A
    bra   check_3
    
    ;do things if button corresponds to 2
    movlw   0x02    ;displays button value on portH
    movwf   buttonval, A
    
    ;set counter max to 451
    movlw   00000001B	;CCP high byte register. Upper byte of number timer is counting to
    movwf   CCPR5H, A
    movlw   11000011B	;CCP low byte register. Lower byte of number timer is counting to
    movwf   CCPR5L, A

    return

check_3:
    movlw   0xD7    ;corresponds to keypress 3
    cpfseq  PORTJ, A
    bra    check_4
    
    ;do things if button corresponds to 3
    movlw   0x03   ;displays button value on portH
    movwf   buttonval, A
    
    ;set counter max to 426
    movlw   00000001B	;CCP high byte register. Upper byte of number timer is counting to
    movwf   CCPR5H, A
    movlw   10101010B	;CCP low byte register. Lower byte of number timer is counting to
    movwf   CCPR5L, A
    
    return

check_4:
    movlw   0x7B    ;corresponds to keypress 4
    cpfseq  PORTJ, A
    bra    check_5
    
    ;do things if button corresponds to 4
    movlw   0x04   ;displays button value on portH
    movwf   buttonval, A
    
    ; set counter max to 379
    movlw   00000001B	;CCP high byte register. Upper byte of number timer is counting to
    movwf   CCPR5H, A
    movlw   01111011B	;CCP low byte register. Lower byte of number timer is counting to
    movwf   CCPR5L, A
    
    return

check_5:
    movlw   0xBB    ;corresponds to keypress 5
    cpfseq  PORTJ, A
    bra    check_6
    
    ;do things if button corresponds to 5
    movlw   0x05   ;displays button value on portH
    movwf   buttonval, A
    
    ; set counter max to 358
    movlw   00000001B	;CCP high byte register. Upper byte of number timer is counting to
    movwf   CCPR5H, A
    movlw   01100110B	;CCP low byte register. Lower byte of number timer is counting to
    movwf   CCPR5L, A
    
    return
    
check_6:
    movlw   0xDB    ;corresponds to keypress 6
    cpfseq  PORTJ, A
    bra	    check_7
    
    ;do things if button corresponds to 6
    movlw   0x06   ;displays button value on portH
    movwf   buttonval, A
    
    ; set counter max to 338
    movlw   00000001B	;CCP high byte register. Upper byte of number timer is counting to
    movwf   CCPR5H, A
    movlw   01010010B	;CCP low byte register. Lower byte of number timer is counting to
    movwf   CCPR5L, A
    
    return

check_7:
    movlw   0x7D    ;corresponds to keypress 7
    cpfseq  PORTJ, A
    bra	    check_8
    
    ;do things if button corresponds to 7
    movlw   0x07   ;displays button value on portH
    movwf   buttonval, A
    
    ; set counter max to 301
    movlw   00000001B	;CCP high byte register. Upper byte of number timer is counting to
    movwf   CCPR5H, A
    movlw   00101101B	;CCP low byte register. Lower byte of number timer is counting to
    movwf   CCPR5L, A

    return
    
check_8:
    movlw   0xBD    ;corresponds to keypress 8
    cpfseq  PORTJ, A
    bra	    check_9
    
    ;do things if button corresponds to 8
    movlw   0x08   ;displays button value on portH
    movwf   buttonval, A
    
    ; set counter max to 284
    movlw   00000001B	;CCP high byte register. Upper byte of number timer is counting to
    movwf   CCPR5H, A
    movlw   00011100B	;CCP low byte register. Lower byte of number timer is counting to
    movwf   CCPR5L, A
    
    return
    
check_9:
    movlw   0xDD    ;corresponds to keypress 9
    cpfseq  PORTJ, A
    bra	    check_A
    
    ;do things if button corresponds to 9
    movlw   0x09   ;displays button value on portH
    movwf   buttonval, A
    
    ; set counter max to 268
    movlw   00000001B	;CCP high byte register. Upper byte of number timer is counting to
    movwf   CCPR5H, A
    movlw   00001100B	;CCP low byte register. Lower byte of number timer is counting to
    movwf   CCPR5L, A
    
    return
    
check_A:
    movlw   0x7E    ;corresponds to keypress A
    cpfseq  PORTJ, A
    bra     check_B
    
    ;do things if button corresponds to A
    movlw   0x0a   ;displays button value on portH
    movwf   buttonval, A
    
    ; set octave to lower (PRSCL = 4)
    movlw   01100010B	; Timer 1 config. Bit 6 set Fosc (1) or Fosc/4 (0). Bit 5-4 set timer prescale (lower is faster) 8: 11, 4: 10, 2: 01, 1: 00 .
    movwf   T1CON, A	
    
    return
    
check_B:
    movlw   0xDE    ;corresponds to keypress B
    cpfseq  PORTJ, A
    bra	    check_C
    ;do things if button corresponds to B
    movlw   0x0b   ;displays button value on portH
    movwf   buttonval, A
    
    ; set octave to upper (PRSCL = 1)
    movlw   01000010B	; Timer 1 config. Bit 6 set Fosc (1) or Fosc/4 (0). Bit 5-4 set timer prescale (lower is faster) 8: 11, 4: 10, 2: 01, 1: 00 .
    movwf   T1CON, A	
    
    return
    
check_C:
    movlw   0xEE    ;corresponds to keypress C
    cpfseq  PORTJ, A
    bra    check_D
    ;do things if button corresponds to C
    movlw   0x0c   ;displays button value on portH
    movwf   buttonval, A

    return
    
check_D:
    movlw   0xED    ;corresponds to keypress D
    cpfseq  PORTJ, A
    bra    check_E
    ;do things if button corresponds to D
    movlw   0x0e   ;displays button value on portH
    movwf   buttonval, A
    
    ; set counter max to 253
    movlw   00000000B	;CCP high byte register. Upper byte of number timer is counting to
    movwf   CCPR5H, A
    movlw   11111101B	;CCP low byte register. Lower byte of number timer is counting to
    movwf   CCPR5L, A

    return
    
check_E:
    movlw   0xEB    ;corresponds to keypress E
    cpfseq  PORTJ, A
    bra    check_F
    ;do things if button corresponds to E
    movlw   0x0E   ;displays button value on portH
    movwf   buttonval, A
    
    ; set counter max to 319
    movlw   00000001B	;CCP high byte register. Upper byte of number timer is counting to
    movwf   CCPR5H, A
    movlw   00111111B	;CCP low byte register. Lower byte of number timer is counting to
    movwf   CCPR5L, A

    return
    
check_F:
    movlw   0xE7    ;corresponds to keypress F
    cpfseq  PORTJ, A
    return
    ;do things if button corresponds to F
    movlw   0x0F   ;displays button value on portH
    movwf   buttonval, A
    
    ; set counter max to 402
    movlw   00000001B	;CCP high byte register. Upper byte of number timer is counting to
    movwf   CCPR5H, A
    movlw   10010010B	;CCP low byte register. Lower byte of number timer is counting to
    movwf   CCPR5L, A

    return

delay:
    movlw   0xFF
    movwf   0x04, A
    call    delay_loop
    return
delay_loop:
    decfsz  0x04, A
    bra	    delay_loop
    return