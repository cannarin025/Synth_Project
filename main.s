#include <xc.inc>
    
    extrn   Wave_Check, Keypad_Init, Keypad_Loop, CCP5_Setup, CCP5_Int_Hi, Wave_Setup, sin_setup
       
psect    code, abs
    
main:
    org    0x0
    goto    start

    org    0x100            ; Main code starts here at address 0x100

int_hi:
    org 0x0008
    goto    CCP5_Int_Hi
    
start:
  
    clrf    TRISG, A
    clrf    TRISH, A
    clrf    LATH, A
    movlw   0x0F    ;first 4 bits of portJ as input for wave select
    movwf   TRISJ, A
    movlw   0x00
    movwf   LATJ, A
    
    call    sin_setup
    call    Keypad_Init
    call    CCP5_Setup
    call    Wave_Setup
    
loop:
    call    Wave_Check
    call    Keypad_Loop
    bra     loop
    goto $