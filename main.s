	#include <xc.inc>
	extrn PWM_setup, PWM_set_note, PWM_play_note, PWM_stop_note, Keypad_Init, DAC_Setup1, DAC_Int_Hi

	psect	code, abs
	
main:
	org	0x0
	goto	start

	org	0x100		    ; Main code starts here at address 0x100

int_hi:
    org 0x0008
    goto    DAC_Int_Hi
    
start:
	;call PWM_setup
	;call Keypad_Init
	call DAC_Setup1
	;call PWM_stop_note
	
	;bra	start
	goto $