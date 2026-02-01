.include "nes.inc"			; NES platform stuff
.macpack generic			; Simple macros and aliases

;; Utility routines to be included as needed


	;; PusH Registers: push the data registers onto the stack
	;; TODO: specify which registers to save?
.macro phr
    pha                     ; save registers
    txa                     ;
    pha                     ;
    tya                     ;
    pha                     ;
.endmacro

	;; PulL Registers: pull the data registers from the stack
.macro plr 
	pla                     ; restore registers
    tay                     ;
    pla                     ;
    tax                     ;
    pla
.endmacro

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Random numbers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;; Returns a random 8-bit number in A (0-255), clobbers Y (unknown).
.macro rand p_seed
;; begin rand
	lda p_seed+1
	tay ; store copy of high byte

	;; compute p_seed+1 ($39>>1 = %11100)
	lsr ; shift to consume zeroes on left...
	lsr
	lsr
	sta p_seed+1 ; now recreate the remaining bits in reverse order... %111
	lsr
	lsr
	eor p_seed+1
	eor p_seed+1
	eor p_seed+0 ; recombine with original low byte
	sta p_seed+1

	;; compute p_seed+0 ($39 = %111001)
	tya ; original high byte
	sta p_seed+0
	asl
	eor p_seed+0
	asl
	eor p_seed+0
	asl
	asl
	asl
	eor p_seed+0
	sta p_seed+0
;; end rand
.endmacro
