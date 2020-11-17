	#include <pic18_chip_select.inc>
	#include <xc.inc>
	
extrn intchk_hi,Keypad_Loop,Keypad_Init

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
    call	Keypad_Init
    
loop:
    call	Keypad_Loop
    bra		start
    
    goto	$
    
    end main