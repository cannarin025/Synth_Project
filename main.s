#include <xc.inc>
    
    extrn   Wave_Check,PWM_setup, PWM_set_note, PWM_play_note, PWM_stop_note, Keypad_Init, Keypad_Loop, CCP5_Setup, CCP5_Enable_Timer, CCP5_Disable_Timer, CCP6_Setup, CCP6_Enable_Timer, CCP6_Disable_Timer, CCP5_Int_Hi, CCP6_Int_Hi, Wave_Setup
    extrn   sin_setup, sin_get_next_val, sin_reset

    ;global  sinArray, sinTable, sinTable_l, sin_counter, sin_setup, sin_get_next_val, sinArray
       
psect    code, abs
    
main:
    org    0x0
    goto    start

    org    0x100            ; Main code starts here at address 0x100

int_hi:
    org 0x0008
    goto    CCP5_Int_Hi
    ;goto    CCP6_Int_Hi
    
start:
    ;movlw   0xff
    call    sin_setup
    clrf   TRISG, A
    clrf    TRISH, A
    ;clrf    TRISJ, A 
    clrf    LATH, A
    movlw   0x0F    ;first 4 bits of portd as input
    movwf   TRISJ, A
    movlw   0x00
    movwf    LATJ, A
    call    Keypad_Init
    call    CCP5_Setup
    ;call    CCP6_Setup
    ;call    Wave_Setup
    ;call    CCP5_Enable_Timer
    ;call    CCP6_Enable_Timer
    call    sin_setup ;test
loop:
    ;call    Wave_Check ;moved before keypad loop to ensure that wavecheck is carried out before next interrupt.
    ;call    Keypad_Loop
    call    sin_get_next_val
    call    sin_get_next_val
    call    sin_get_next_val
    call    sin_reset
    bra     loop
    goto $