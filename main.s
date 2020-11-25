#include <xc.inc>
    extrn PWM_setup, PWM_set_note, PWM_play_note, PWM_stop_note, Keypad_Init, Keypad_Loop, CCP5_Setup, CCP5_Enable_Timer, CCP5_Disable_Timer, CCP6_Setup, CCP6_Enable_Timer, CCP6_Disable_Timer, CCP5_Int_Hi, CCP6_Int_Hi, Wave_Setup

psect	udata_acs   ; reserve data space in access ram
sin_counter:ds 1
    
psect	udata_bank4 ; reserve data anywhere in RAM (here at 0x400)
sinArray:    ds 0x80 ; reserve 128 bytes for message data

psect	data    
	; ******* myTable, data in programme memory, and its length *****
sinTable:
	db	128,140,152,165,176,188,199,209,218,226,234,240,246,250,253,255,256,255,253,250,246,240,234,226,218,209,199,188,176,165,152,140,128,115,103,90,79,67,56,46,37,29,21,15,9,5,2,0,0,0,2,5,9,15,21,29,37,46,56,67,79,90,103,115
	sinTable_l   EQU	64	; length of data
	align	2
    
psect	code, abs	
    
main:
    org    0x0
    goto    start

    org    0x100            ; Main code starts here at address 0x100

int_hi:
    org 0x0008
    goto    CCP5_Int_Hi
    goto    CCP6_Int_Hi
    
start:
    clrf    TRISH, A
    clrf    TRISD, A 
    clrf    LATH, A
    clrf    LATD, A
    call    Keypad_Init
    call    CCP5_Setup
    ;call    CCP6_Setup
    ;call    Wave_Setup
    ;call    CCP5_Enable_Timer
    ;call    CCP6_Enable_Timer
    ;call    table_setup
    ;call    sin_table_read
    call    sin_setup
    call    sin_get_next_val
    call    sin_get_next_val
loop:
    call    Keypad_Loop
    bra     loop
    goto $
    
	; ******* Programme FLASH read Setup Code ***********************
sin_setup:	
	bcf	CFGS	; point to Flash program memory  
	bsf	EEPGD 	; access Flash program memory
	call	sin_table_read
	return
	
	; ******* Main programme ****************************************
sin_table_read:
        lfsr	0, sinArray	; Load FSR0 with address in RAM	
	movlw	low highword(sinTable)	; address of data in PM
	movwf	TBLPTRU, A		; load upper bits to TBLPTRU
	movlw	high(sinTable)	; address of data in PM
	movwf	TBLPTRH, A		; load high byte to TBLPTRH
	movlw	low(sinTable)	; address of data in PM
	movwf	TBLPTRL, A		; load low byte to TBLPTRL
	movlw	sinTable_l	; bytes to read
	movwf 	sin_counter, A		; our counter register
	call	sin_loop
	return
	
sin_loop: 	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
	decfsz	sin_counter, A		; count down to zero
	bra	sin_loop		; keep going until finished
		
	movlw	sinTable_l	; output message to UART
	lfsr	2, sinArray
	movwf   sin_counter, A
	return

sin_get_next_val:		;sequentially gets sin values. Decrements sin_counter.
	movf    POSTINC2, W, A
	movwf	0x01, A
	decf	sin_counter, A
	return
