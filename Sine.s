#include <xc.inc>
    
global	sin_setup, sin_next_val, sin_reset, sin_reset
    
psect	udata_acs ; reserve data space in access ram

sin_counter:	ds 1
    
psect	udata_bank4 ; reserve data anywhere in RAM (here at 0x400)

sinArray:	ds 0x80 ; reserve 128 bytes for sine data
    
psect	data    
 
; sinTable, data in programme memory, and its length
sinTable:
    db    127,139,152,164,176,187,198,208,217,226,233,239,245,249,252,254,255,254,252,249,245,239,233,226,217,208,198,187,176,164,152,139,127,115,102,90,78,67,56,46,37,28,21,15,9,5,2,0,0,0,2,5,9,15,21,28,37,46,56,67,78,90,102,115
    sinTable_l   EQU    64    ; length of data
    align    2

;table read functions
psect    Sine_code, class = CODE

sin_setup:
    bcf	    CFGS    ; point to Flash program memory  
    bsf	    EEPGD     ; access Flash program memory
    call    sin_table_read
    return
    
sin_table_read:
    lfsr    0, sinArray    ; Load FSR0 with address in RAM    
    movlw   low highword(sinTable)    ; address of data in PM
    movwf   TBLPTRU, A        ; load upper bits to TBLPTRU
    movlw   high(sinTable)    ; address of data in PM
    movwf   TBLPTRH, A        ; load high byte to TBLPTRH
    movlw   low(sinTable)    ; address of data in PM
    movwf   TBLPTRL, A        ; load low byte to TBLPTRL
    movlw   sinTable_l    ; bytes to read
    movwf   sin_counter, A        ; our counter register
    call    sin_loop
    
    return
    
sin_loop:
    tblrd*+ ; one byte from PM to TABLAT, increment TBLPRT
    movff   TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0    
    decfsz  sin_counter, A        ; count down to zero
    bra	    sin_loop        ; keep going until finished
        
    movlw   sinTable_l
    lfsr    2, sinArray
    return

sin_next_val: ; sequentially gets sin values. Decrements sin_counter.
    movf    POSTINC2, W, A
    movwf   PORTH, A
    return
 
sin_reset:
    lfsr    2, sinArray
    return