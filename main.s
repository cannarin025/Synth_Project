	#include <xc.inc>
	
extrn intchk_hi
extrn Keypad_Loop,Keypad_Init
extrn ADC_Setup, ADC_Loop
extrn PWM_setup, PWM_set_note, PWM_play_note, PWM_stop_note
extrn DAC_Setup

psect	code, abs
	
main:
    org	0x0
    goto	start

    org	0x100		    ; Main code starts here at address 0x100

int_hi:
    org	0x0008
    goto	intchk_hi
	
int_lo:
    org	0x0018
    goto	intchk_hi
	
start:
    movlw	0x00
    movwf	TRISH, A
    clrf	TRISC, A	; Set PORTD as all outputs
    clrf	LATC, A		; Clear PORTD outputs
    call	PWM_setup
    call	Keypad_Init
;    call	DAC_Setup

loop:
;    call	ADC_Loop
    call	Keypad_Loop
    bra		loop
    
    goto	$