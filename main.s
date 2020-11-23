#include <xc.inc>
	extrn PWM_setup, PWM_set_note, PWM_play_note, PWM_stop_note, Keypad_Init, Keypad_Loop, CCP_Setup, CCP_Int_Hi, CCP_Enable_Timer, CCP_Disable_Timer

	psect	code, abs
	
main:
    org	0x0
    goto	start

	org	0x100		    ; Main code starts here at address 0x100

int_hi:
    org 0x0008
    goto    CCP_Int_Hi
    
start:
	clrf TRISH
	;call PWM_setup
	;call	Keypad_Init
	call	CCP_Setup
	call	CCP_Enable_Timer
	;bra	start
	
loop:
	;call	Keypad_Loop
	bra	loop
	goto $
