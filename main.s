	#include <pic18_chip_select.inc>
	#include <xc.inc>

extrn	Keypad
	
psect	code, abs
	
main:
	org	0x0
	goto	start

	org	0x100		    ; Main code starts here at address 0x100
start:
	
    
	end main