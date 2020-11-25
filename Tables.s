#include <xc.inc>

global	sin_table_read
    
psect	udata_acs   ; reserve data space in access ram
sin_counter:ds 1
    
psect	udata_bank4 ; reserve data anywhere in RAM (here at 0x400)
sinArray:    ds 0x80 ; reserve 128 bytes for message data

psect	data
	
	; ******* myTable, data in programme memory, and its length *****
sinTable:
	db	128,140,152,165,176,188,199,209,218,226,234,240,246,250,253,255,256,255,253,250,246,240,234,226,218,209,199,188,176,165,152,140,128,115,103,90,79,67,56,46,37,29,21,15,9,5,2,0,0,0,2,5,9,15,21,29,37,46,56,67,79,90,103,115
					; message, plus carriage return
	sinTable_l   EQU	64	; length of data
	align	2
    
psect	table_code, abs	
	
	; ******* Programme FLASH read Setup Code ***********************
table_setup:	
	bcf	CFGS	; point to Flash program memory  
	bsf	EEPGD 	; access Flash program memory
	
	; ******* Main programme ****************************************
sin_table_read: ;reads in sin values sequentially to register 0x01
        lfsr	0, sinArray	; Load FSR0 with address in RAM	
	movlw	low highword(sinTable)	; address of data in PM
	movwf	TBLPTRU, A		; load upper bits to TBLPTRU
	movlw	high(sinTable)	; address of data in PM
	movwf	TBLPTRH, A		; load high byte to TBLPTRH
	movlw	low(sinTable)	; address of data in PM
	movwf	TBLPTRL, A		; load low byte to TBLPTRL
	movlw	sinTable_l	; bytes to read
	movwf 	sin_counter, A		; our counter register
sin_read_loop: 	
	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
	decfsz	sin_counter, A		; count down to zero
	bra	sin_read_loop		; keep going until finished
		
	movlw	sinTable_l
	lfsr	2, sinArray

get_sin_values:	    ; Message stored at FSR2, length stored in W
	movwf   sin_counter, A
sin_output_loop:
	movf    POSTINC2, W, A
	movwf	0x01, A
	decfsz  sin_counter, A
	bra	sin_output_loop
	return