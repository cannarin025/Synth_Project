	#include <pic18_chip_select.inc>
	#include <xc.inc>
	
extrn sawloop	

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
	
    call	Keypad_Loop
    goto	$
    
    end main