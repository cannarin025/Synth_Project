	#include <xc.inc>
	
extrn intchk_hi
extrn Keypad_Loop,Keypad_Init
extrn PWM_setup2
extrn ADC_Setup, ADC_loop

psect	code, abs
	
main:
    org	0x0
    goto	start

    org	0x100		    ; Main code starts here at address 0x100

int_hi:
    org	0x0008
    goto	intchk_hi
	
;int_lo:
;    org	0x0018
;    goto	intchk_lo
	
start:
    call	PWM_setup2
    call	Keypad_Init
    call	DAC_Setup
    
loop:
    call	ADC_loop
    call	Keypad_Loop
    bra		start
    
    goto	$