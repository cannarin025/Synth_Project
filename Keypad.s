#include <xc.inc>
 
global Keypad_Init, Keypad_Loop
extrn  LCD_Setup, LCD_Send_Byte_D, LCD_Clear
    
psect    udata_acs   ; named variables in access ram
delay_curr:	    ds 1   ; reserve 1 byte for current counter val
delay_count1:	    ds 1   ; reserve 1 byte for counting
delay_count2:	    ds 1   ; reserve 1 byte for counting
delay_count3:	    ds 1   ; reserve 1 byte for counting
wtemp:		    ds 1    ; reserve 1 byte for temp w val
keypadrowbits:	    ds 1
keypadcolbits:	    ds 1
keypadlastkey:	    ds 1
    
psect    Keypad_code, class=CODE

    
Keypad_Init:
    banksel PADCFG1
    bsf	    REPU
    clrf    LATE, A 
    
    movlw   0x00
    movwf   TRISJ, A
    
    movlw   0x00
    movwf   TRISH, A
    
    movlw   0x00
    movwf   keypadlastkey, A	;stores value from last cycle (see keypad_get_output:)
    
    call    Keypad_Loop
    return
    
Keypad_Read_Rows:
    movlw   0x0F	;sets ports 0-3 as input, pins 4-7 as output
    movwf   TRISE, A
    movlw   10
    call    delay_sec
    movff   PORTE, keypadrowbits
    call    Keypad_Read_Col
    return

Keypad_Read_Col:
    movlw   0xF0
    movwf   TRISE, A
    movlw   10
    call    delay_sec
    movff   PORTE, keypadcolbits
    return
    
Keypad_Get_Output:
    movf    keypadrowbits, W, A	;loads 0x08 (rows) into W
    ADDWF   0x02, A	;performs addition of rows with 0x09 (columns)
    movf    keypadcolbits, W, A
    cpfseq  keypadlastkey, A
    movff   keypadlastkey, PORTJ ;outputs row (dim) in 1st 4 bits and col (dim) in last 4 bits
    movff   keypadcolbits, keypadlastkey	;stores number from "last cycle" to avoid repeat entries (if it is not the same as previous number)
    return
    
Keypad_Loop:
    call    Keypad_Read_Rows
    call    Keypad_Get_Output
    movlw   0xFF
    cpfseq  PORTJ, A
    call    check_0
    bra	    Keypad_Loop
    
Keypad_Get_Value:
    return

check_0:
    movlw   0xBE    ;corresponds to keypress 0
    cpfseq  PORTJ, A
    bra    check_1
    
    ;do things if button corresponds to 1
    movlw   0x00    ;displays button value on portH
    movwf   PORTH, A
    movlw   "0"
    call    LCD_Send_Byte_D    
    
check_1:
    movlw   0x77    ;corresponds to keypress 1
    cpfseq  PORTJ, A
    bra    check_2
    
    ;do things if button corresponds to 1
    movlw   0x01    ;displays button value on portH
    movwf   PORTH, A
    movlw   "1"
    call    LCD_Send_Byte_D
    
    return

check_2:
    movlw   0xB7    ;corresponds to keypress 2
    cpfseq  PORTJ, A
    bra   check_3
    
    ;do things if button corresponds to 2
    movlw   0x02    ;displays button value on portH
    movwf   PORTH, A
    movlw   "2"
    call    LCD_Send_Byte_D
    
    return

check_3:
    movlw   0xD7    ;corresponds to keypress 3
    cpfseq  PORTJ, A
    bra    check_4
    
    ;do things if button corresponds to 3
    movlw   0x03   ;displays button value on portH
    movwf   PORTH, A
    movlw   "3"
    call    LCD_Send_Byte_D
    
    return

check_4:
    movlw   0x7B    ;corresponds to keypress 4
    cpfseq  PORTJ, A
    bra    check_5
    
    ;do things if button corresponds to 4
    movlw   0x04   ;displays button value on portH
    movwf   PORTH, A
    movlw   "4"
    call    LCD_Send_Byte_D
    
    return

check_5:
    movlw   0xBB    ;corresponds to keypress 5
    cpfseq  PORTJ, A
    bra    check_6
    
    ;do things if button corresponds to 5
    movlw   0x05   ;displays button value on portH
    movwf   PORTH, A
    movlw   "5"
    call    LCD_Send_Byte_D
    
    return
    
check_6:
    movlw   0xDB    ;corresponds to keypress 6
    cpfseq  PORTJ, A
    bra	    check_7
    
    ;do things if button corresponds to 6
    movlw   0x06   ;displays button value on portH
    movwf   PORTH, A
    movlw   "6"
    call    LCD_Send_Byte_D
    
    return

check_7:
    movlw   0x7D    ;corresponds to keypress 7
    cpfseq  PORTJ, A
    bra	    check_8
    
    ;do things if button corresponds to 7
    movlw   0x07   ;displays button value on portH
    movwf   PORTH, A
    movlw   "7"
    call    LCD_Send_Byte_D
    
    return
    
check_8:
    movlw   0xBD    ;corresponds to keypress 8
    cpfseq  PORTJ, A
    bra	    check_9
    
    ;do things if button corresponds to 8
    movlw   0x08   ;displays button value on portH
    movwf   PORTH, A
    movlw   "8"
    call    LCD_Send_Byte_D
    
    return
    
check_9:
    movlw   0xDD    ;corresponds to keypress 9
    cpfseq  PORTJ, A
    bra	    check_A
    
    ;do things if button corresponds to 9
    movlw   0x09   ;displays button value on portH
    movwf   PORTH, A
    movlw   "9"
    call    LCD_Send_Byte_D
    
    return
    
check_A:
    movlw   0x7E    ;corresponds to keypress A
    cpfseq  PORTJ, A
    bra     check_B
    
    ;do things if button corresponds to A
    movlw   0x0a   ;displays button value on portH
    movwf   PORTH, A
    movlw   "A"
    call    LCD_Send_Byte_D
    return
    
check_B:
    movlw   0xDE    ;corresponds to keypress B
    cpfseq  PORTJ, A
    bra	    check_C
    ;do things if button corresponds to B
    movlw   0x0b   ;displays button value on portH
    movwf   PORTH, A
    movlw   "B"
    call    LCD_Send_Byte_D
    return
    
check_C:
    movlw   0xEE    ;corresponds to keypress C
    cpfseq  PORTJ, A
    bra    check_D
    ;do things if button corresponds to C
    movlw   0x0c   ;displays button value on portH
    movwf   PORTH, A
    call    LCD_Clear
    return
    
check_D:
    movlw   0xED    ;corresponds to keypress D
    cpfseq  PORTJ, A
    bra    check_E
    ;do things if button corresponds to D
    movlw   0x0e   ;displays button value on portH
    movwf   PORTH, A
    movlw   "D"
    call    LCD_Send_Byte_D
    return
    
check_E:
    movlw   0xEB    ;corresponds to keypress E
    cpfseq  PORTJ, A
    bra    check_F
    ;do things if button corresponds to E
    movlw   0x0E   ;displays button value on portH
    movwf   PORTH, A
    movlw   "E"
    call    LCD_Send_Byte_D
    return
    
check_F:
    movlw   0xE7    ;corresponds to keypress F
    cpfseq  PORTJ, A
    return
    ;do things if button corresponds to F
    movlw   0x0F   ;displays button value on portH
    movwf   PORTH, A
    movlw   "F"
    call    LCD_Send_Byte_D
    return

;delay_sec:
;    movwf   wtemp, A
;    movlw   0x00
;    movwf   delay_curr, A
;    incf    delay_curr, F, A        ; set f00 = f00 + 1
;    movlw   0xfd            ; set W = 256 (timer)
;    movwf   delay_count1, A            ; set timer f06 = W (=256)
;    movlw   0x2b
;    movwf   delay_count2, A            ; set timer f07 = W (=256)
;    movlw   0x52            ; set W = 80
;    movwf   delay_count3, A            ; set timer f08 = W (=80)
;    call    delay            ; run the delay
;    movf    wtemp, W, A
;    return
   
;delay:
;    decfsz  delay_count1, A            ; decrement f02 and skip next if f02 = 0
;    bra	    delay
;    decfsz  delay_count2, A            ; decrement f02 and skip next if f02 = 0
;    bra	    delay
;    decfsz  delay_count3, A            ; decrement f02 and skip next if f02 = 0
;    bra	    delay
;    return
    
delay_sec:
    movlw   0xFF
    movwf   0x04, A
    call    delay_loop
delay_loop:
    decfsz  0x04, A
    bra	    delay_loop
    return