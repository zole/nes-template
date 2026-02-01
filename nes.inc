;
; NES I/O definitions
; Copyright 2010 Damian Yerrick
;
; Copying and distribution of this file, with or without
; modification, are permitted in any medium without royalty provided
; the copyright notice and this notice are preserved in all source
; code copies.  This file is offered as-is, without any warranty.
;
; Modifications by M. Zole

.ifndef NES_INC
NES_INC = 1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; PPU Access
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PPUCTRL	    = $2000
PPUMASK	    = $2001
PPUSTATUS	= $2002
OAMADDR	    = $2003
OAMDATA	    = $2004
PPUSCROLL	= $2005
PPUADDR	    = $2006
PPUDATA	    = $2007

.struct PPU
    .org    $2000
    CTRL    .byte
    MASK    .byte
    STATUS  .byte
        .struct OAM
            .org   $2003 
            ADDR .byte 
            DATA .byte
        .endstruct
    SCROLL  .byte
    ADDR    .byte
    DATA    .byte
.endstruct


OAMDMA         = $4014
; OAM local RAM copy goes from $0200-$02FF:
OAM_RAM         = $0200

;; PPU_CTRL flags
CTRL_NT_2000	= %00000000 	; Name Table Address at $2000
CTRL_NT_2400	= %00000001 	; Name Table Address at $2400
CTRL_NT_2800	= %00000010 	; Name Table Address at $2800
CTRL_NT_2C00	= %00000011 	; Name Table Address at $2C00

CTRL_INC_1	    = %00000000 	; Increment PPU Address by 1 (Horizontal rendering)
CTRL_INC_32	    = %00000100 	; Increment PPU Address by 32 (Vertical rendering)

CTRL_SPR_0000	= %00000000 	; Sprite Pattern Table at $0000 in VRAM
CTRL_SPR_1000	= %00001000 	; Sprite Pattern Table at $1000 in VRAM
CTRL_BG_0000	= %00000000 	; Background Pattern Table at $0000 in VRAM
CTRL_BG_1000	= %00010000 	; Background Pattern Table at $1000 in VRAM

CTRL_8x8	    = %00000000 	; Use 8x8 Sprites
CTRL_8x16	    = %00100000 	; Use 8x16 Sprites

CTRL_NMI	    = %10000000	    ; Execute Non-Maskable Interrupt on VBlank

;; PPU_MASK flags
MASK_COLOR	    = %00000000 	; Display in Color
MASK_MONO	    = %00000001 	; Display in Monochrome
MASK_BG_CLIP	= %00000010 	; Background clipped on left column
MASK_SPR_CLIP	= %00000100 	; Sprites clipped on left column
MASK_BG		    = %00001000 	; Backgrounds Visible
MASK_SPR	    = %00010000 	; Sprites Visible
MASK_TINT_RED	= %00100000	    ; Red Background
MASK_TINT_BLUE	= %01000000	    ; Blue Background
MASK_TINT_GREEN	= %10000000	    ; Green Background

; Bits read from PPU_STATUS
ST_VBLANK       = %10000000     ; VBlank Active
ST_SPRITE0      = %01000000     ; VBlank hit Sprite 0
ST_SCAN8        = %00100000     ; More than 8 sprites on current scanline
ST_VRAM_NOWRITE = %00010000     ; VRAM Writes currently ignored


;; Video memory map
PPU_CHR_TBL0    = $0000         ; pattern tables in CHR-ROM
PPU_CHR_TBL1    = $1000
PPU_NT0         = $2000         ; nametable, aka background, through $23BF
PPU_NT1         = $2400
PPU_NT2         = $2800         ; Mirrors
PPU_NT3         = $2C00         ;
PPU_ATTR0       = $23C0         ; attributes for nametable 0
PPU_ATTR1       = $27C0         ; for nametable 1
PPU_ATTR2       = $2BC0         ; Mirrors
PPU_ATTR3       = $2FC0         ;

PPU_PALETTE     = $3F00

; low byte of individual palette addresses
PALETTE_BG0     = $00
PALETTE_BG1     = $04
PALETTE_BG2     = $08
PALETTE_BG3     = $0C

PALETTE_SPR0    = $10
PALETTE_SPR1    = $14
PALETTE_SPR2    = $18
PALETTE_SPR3    = $1C

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Audio
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

APU_NOISE_VOL   = $400C
APU_NOISE_FREQ  = $400E
APU_NOISE_TIMER = $400F
APU_DMC_CTRL    = $4010
; APU_STATUS	    = $4015
APU_CHAN_CTRL   = $4015
APU_FRAME       = $4017         ; frame counter https://www.nesdev.org/wiki/APU#Frame_Counter_($4017)

; These registers are only active with the test pin (pin 30) asserted on 2A03 G and H.
APUTEST1		= $4018
APUTEST2		= $4019
APUTEST3		= $401A

APUPU1			= $4000
SQ1_VOL			= APUPU1 + 0
SQ1_SWEEP		= APUPU1 + 1
SQ1_LO			= APUPU1 + 2
SQ1_HI			= APUPU1 + 3

APUPU2			= $4004
SW2_VOL			= APUPU2 + 0
SW2_SWEEP		= APUPU2 + 1
SW2_LO			= APUPU2 + 2
SW2_HI			= APUPU2 + 3

APUTRI			= $4008
TRI_LINEAR		= APUTRI + 0
TRI_LO			= APUTRI + 2
TRI_HI			= APUTRI + 3

APUNOI			= $400C
NOISE_VOL		= APUNOI + 0
NOISE_LO		= APUNOI + 2
NOISE_HI		= APUNOI + 3

APUDMC			= $4010
DMC_FREQ		= APUDMC + 0
DMC_RAW			= APUDMC + 1
DMC_START		= APUDMC + 2
DMC_LEN			= APUDMC + 3

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Input
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

JOYPAD1		= $4016
JOYPAD2		= $4017

KEY_A      = %10000000
KEY_B      = %01000000
KEY_SELECT = %00100000
KEY_START  = %00010000
KEY_UP     = %00001000
KEY_DOWN   = %00000100
KEY_LEFT   = %00000010
KEY_RIGHT  = %00000001

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; PPU Tasks
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;; Copy the page of RAM at `p_shadow` to OAM
.macro run_dma p_shadow
    lda #$00            ; destination
    sta OAMADDR
    lda	#>(p_shadow)		; transfer from RAM page 2 to OAM
    sta OAMDMA
.endmacro


	;; Set the VRAM write address to the 16-bit value. 
	;; Clobbers X. Don't forget to re-set the scroll registers, apparently
.macro ppu_set_addr vram_ptr
;; begin ppu_set_addr
	bit PPUSTATUS
	ldx #>vram_ptr
	stx PPUADDR
	ldx #<vram_ptr
	stx PPUADDR
;; end ppu_set_addr
.endmacro

    ;; Resolve to the VRAM address of the tile at x,y in nametable nt.
    ;; Arguments are truncated if they have too many bits.
    ;; TODO: not sure if this kind of thing is what we'll use in practice
.define vram_tile(nt, tx, ty) (PPU_NT0 | ((nt & $03) << 10) | ((ty & $1F) << 5) | (tx & $1F))

    ;; Resolve to the VRAM address that defines the given tile's address in an
    ;; attribute table. Note that one byte in the attribute table determines the
    ;; palettes for a 4x4 block of tiles, so low bits are discarded
.define vram_attr(nt, tx, ty) (PPU_ATTR0 | ((nt & $03) << 10) | ((ty & $1F) >> 2 << 3) | (tx & $1F) >> 2)


    ;; Create an attribute value from four palette indexes
.define ppu_attr(tl, tr, bl, br) (br << 6) | (bl << 4) | (tr << 2) | (tl << 0)


    ;; Load PPU palettes from continguous data in CPU memory.
	;; Make sure PPUCTRL.b2 is cleared (advance PPU address by 1)
	;;
	;; src: the address to copy palette data from
	;; dest: the first palette index to update.
	;;  	  0-3 are background palettes 0-3, 4-7 are sprite palettes 0-3
	;; count: the number of palettes to copy. count * 4 bytes will be copied.
    ;; [clobbers] A,X
.macro load_palettes p_src, dest, count
	.local loop
;; begin load_palettes
    bit PPUSTATUS      	      	; read PPU status to reset the high/low latch
    ldx #>PPU_PALETTE			; set the PPU write address
    stx PPUADDR
    ldx #<PPU_PALETTE + (dest * 4)
    stx PPUADDR
	ldx #0
loop:
    lda p_src,x        			; load byte from ROM address (palette + x)
    sta PPUDATA                 ; write to PPU
    inx                         ; 
    cpx #(count * 4)                    ; loop until 32 bytes (8 palettes) written
    bne loop                   ; 
;; end load_palettes
.endmacro

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Input Tasks
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;; Read first controller. Unsafe because it doesn't account for DPCM
	;; playback. Also doesn't read Famicom expansion port.
	;; From https://www.nesdev.org/wiki/Controller_reading_code#Basic_Example
	;;
	;; Clobbers: A
	;; p_paddata: memory address that will receive a bitmask of controller
	;;			  buttons. the bits will be:
	;;				.0	D-pad right
	;;				.1  D-pad left
	;;				.2	D-pad down
	;;				.3 	D-pad up
	;;				.4 	Start
	;;				.5 	Select
	;;				.6 	B
	;;				.7 	A
.macro input_read_p1_unsafe p_paddata
	.local loop
;; begin input_read_p1_unsafe
	lda #$01
    ; While the strobe bit is set, buttons will be continuously reloaded.
    ; This means that reading from JOYPAD1 will only return the state of the
    ; first button: button A.
    sta JOYPAD1
    sta p_paddata
    lsr a        ; now A is 0
    ; By storing 0 into JOYPAD1, the strobe bit is cleared and the reloading stops.
    ; This allows all 8 buttons (newly reloaded) to be read from JOYPAD1.
    sta JOYPAD1
loop:
    lda JOYPAD1
    lsr a        ; bit 0 -> Carry
    rol p_paddata  ; Carry -> bit 0; bit 7 -> Carry
    bcc loop
;; end input_read_p1_unsafe
.endmacro

    ;; Increments or decrements var by 1 depending on the given key bitmaps
    ;; pre: X = input bitmask, clobbers: A,Y
    ;; example:
    ;;   add_dpad pos_x, #KEY_LEFT, #KEY_RIGHT
.macro add_dpad var, key_neg, key_pos
    .scope
        ldy var

    check_neg:
        txa
        and key_neg
        beq check_pos
        dey

    check_pos:
        txa
        and key_pos
        beq done
        iny

    done:
        sty var

    .endscope
.endmacro

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.endif
