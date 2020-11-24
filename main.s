#include <xc.inc>
    extrn PWM_setup, PWM_set_note, PWM_play_note, PWM_stop_note, Keypad_Init, Keypad_Loop, CCP5_Setup, CCP5_Enable_Timer, CCP5_Disable_Timer, CCP6_Setup, CCP6_Enable_Timer, CCP6_Disable_Timer, CCP5_Int_Hi, CCP6_Int_Hi, Wave_Setup, Wave_Check

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
    movlw   0xff
    movwf   TRISG, A
    clrf    TRISH, A
    clrf    TRISD, A 
    clrf    LATH, A
    clrf    LATD, A
    ;call   PWM_setup
    call    Keypad_Init
    call    CCP5_Setup
    ;call    CCP6_Setup
    call    Wave_Setup
    ;call    CCP5_Enable_Timer
    ;call    CCP6_Enable_Timer
loop:
    call    Keypad_Loop
    call    Wave_Check
    bra     loop
    goto $
