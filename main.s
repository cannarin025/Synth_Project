	#include <xc.inc>
	extrn PWM_setup, PWM_setup2
psect	code, abs
	
main:
	org	0x0
	goto	start

	org	0x100		    ; Main code starts here at address 0x100
start:
	call	PWM_setup2
	bra	start
	goto $