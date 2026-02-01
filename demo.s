
.include "macros.inc"

;;; Imports & Exports ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.import audio_init, music_play, sfx_play, input_read
.importzp buttons, buttons_pressed

.export _main, early_init

;;; Constants ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

TIMER = $10                 ; timer reset value

;;; Reserved memory ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.struct Vec2
    xx  .byte
    yy  .byte
.endstruct

.segment "ZEROPAGE"

framectr:           .res 1
; buttons:           .res 1
; input_prev_p1:      .res 1
color_idx:          .res 1  ; index into list of background colors
color_timer:        .res 1  ; frames till background color changes
scroll_x:           .res 1
rng:                .res 2  ; random number seed, doubling as output of rand()
seed:               .res 1
offset:             .tag Vec2

.segment "RAM"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.segment "CODE"

    ;; Memory has been cleared but PPU is not ready
.proc early_init
init_timer:
    lda #TIMER
    sta color_timer
    
    jsr audio_init

    rts
.endproc


    ;; PPU is ready at this point
_main:
.proc init

    load_palettes palette, 0, 8

init_nametables:
    ppu_set_addr vram_tile(0, 0, 0)


    lda #$16            ; the diamond
    ;; X = 0 because that's the low byte of NT0
    ;; write 8 pages (fill the first two nametables)
    ldy #$08
:
    sta PPUDATA
    inx
    bne :-

    dey
    bne :-

init_attr0:
    ppu_set_addr vram_attr(0, 0, 0)
    lda #0
    ldx #$40
:
    sta PPUDATA
    dex
    bne :-

    lda #0                         ; song index
    jsr music_play


    ;; specify PPU settings and turn on NMI / background / sprites
enable_ppu:
    lda #(MASK_BG | MASK_SPR | MASK_BG_CLIP)
    sta PPUMASK
    lda #(CTRL_NMI | CTRL_NT_2000 | CTRL_SPR_0000 | CTRL_BG_0000 | CTRL_8x8)
    sta PPUCTRL

.endproc ; all done with initialization


    ;; The CPU budget when drawing sprites and backgrounds is something like:
    ;;       29780      CPU cycles per frame
    ;;     -   514      OAM DMA
    ;;     -  1750      Remaining time in Vblank
    ;;       =====
    ;;       27516      Cycles available for per-frame logic
.proc loop
    inc nmi_wait
    ;; kill time until vblank handler starts
@spin:
    lda nmi_wait
    bne @spin

    jsr update

    inc framectr
    jmp loop
.endproc


.proc update
    ;; Update input, but save the old one for diffing
    ; input_read_p1_unsafe buttons
    jsr input_read

    jsr seed_rng
    jsr move_sprites
    jsr advance_timer
    jsr timer_effects
    jsr generate_garbage

    rts
.endproc


     ;; if there has been any input and there's no random seed, set it
     ;; [clobbers] A
.proc seed_rng
    lda seed
    bne done
    lda buttons
    beq done
    lda framectr
    bne value_ok        ; 0 doesn't work as a seed
    add #1
value_ok:
    sta seed
done:
    rts
.endproc


    ;; change the sprite offset. clobbers: A,X,Y
.proc move_sprites
    ldx buttons
    add_dpad offset+0, #KEY_LEFT, #KEY_RIGHT
    add_dpad offset+1, #KEY_UP, #KEY_DOWN
    rts
.endproc


    ;; Updates timer and leaves new value in X
.proc advance_timer
    lda buttons_pressed
    and #KEY_A
    beq tick                    ; ...to skip extending the timer
    lda #0                      ; play the first sound
    jsr sfx_play                ;
    ldx #TIMER * 4
    stx color_timer
    rts
tick:
    ldx color_timer
    dex
    stx color_timer             ; timer will stay in X
    rts
.endproc


    ;; Do stuff based on the timer.
    ;; [in] x: color timer
    ;; [clobbers] A,X
.proc timer_effects
scroll:
    txa
    cmp #TIMER
    bcs cycle_color             ; if the timer has been extended, don't scroll
    inc scroll_x

cycle_color:
    txa
    bne done                    ; timer is >0, no change

    lda #TIMER
    sta color_timer             ; reset the timer

    ;; advance color index, looping when we hit the end of the buffer
    ldx color_idx
    inx
    cpx #(color_cycle_end - color_cycle)
    bcc :+                      ; carry clear means x < bufferlength
    ldx #0                      ; X is >= the length of the buffer, so loop
:   stx color_idx

done:
    rts
.endproc


.proc generate_garbage
    ;; load the rng seed to get the same sequence of numbers each frame
    lda seed
    sta rng+0
    lda seed
    sta rng+1

    ;; write 256 "random" values to page 2 for DMA'ing to OAM
    ldx #$00
:
    jsr getrand

    ;; y coord
    add offset + Vec2::yy
    sta OAM_RAM, X
    inx

    ;; tile idx
    ; jsr getrand
    lda rng+0
    and #$1F
    add #$40
    sta OAM_RAM, X
    inx

    jsr getrand
    ;; attributes
    and #%00100011 
    sta OAM_RAM, X
    inx

    ;; x coord
    ; jsr getrand
    lda rng+0
    add offset + Vec2::xx
    sta OAM_RAM, X
    inx

    bne :-
    rts
.endproc


.proc getrand
    rand rng                ; random number seed, doubling as output of rand()
    rts
.endproc


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;; Imports & Exports ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.import audio_update

.export nmi, irq

;;; Reserved memory ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.segment "ZEROPAGE"

nmi_wait:       .res 1      ;; set to 0 when NMI is finished

.segment "RAM"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.segment "CODE"

    ;; VBlank handler
    ;; On NTSC, roughly 2273 CPU cycles are available, minus ~514 for OAMDMA,
    ;; so that leaves about 1750 cycles to access the PPU.
nmi:
    pha                     ; save registers
    txa                     ;
    pha                     ;
    tya                     ;
    pha                     ;

    lda #0
    sta PPUCTRL             ; quick and dirty, turn off NMI until we're done
                            ; probably want to store the desired value of
                            ; PPUCTRL and restore it later

demo_cycle_background:      ; about 71 cycles

    ldy color_idx
    lda color_cycle, Y

    ;; write the new shared background color
    ppu_set_addr PPU_PALETTE
    sta PPUDATA

    ;; PPUADDR clobbers scroll values, apparently, so:
    bit PPUSTATUS
    lda scroll_x                
    lsr A                   ; slows scroll, but only works because
    lsr A                   ; the nametable is homogenous
    sta PPUSCROLL
    lda #$00                ; no vertical scrolling
    sta PPUSCROLL

    ;; Copy sprite info
    run_dma OAM_RAM
 
@nmi_end:
    lda #(CTRL_NMI | CTRL_NT_2000 | CTRL_SPR_0000 | CTRL_BG_0000 | CTRL_8x8)
    sta PPUCTRL             ; reset PPUCTRL flags (re-enable NMI)
    
    jsr audio_update        ; end of nmi is a good time to update audio, apparently

    lda #0
    sta nmi_wait            ; notify main program it can resume

    pla                     ; restore registers
    tay                     ;
    pla                     ;
    tax                     ;
    pla

    ;; since we're not doing anything with irq, this saves a couple bytes
irq:
    rti



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.segment "RODATA"

color_cycle:
    .byte   $0E,$01,$11,$21,$31,$20,$31,$21,$11,$01
    .byte   $0E,$09,$0A,$1A,$2A,$3A,$20
    .byte   $3A,$2A,$1A,$0A,$09
color_cycle_end:
palette:
    ;; Background palette
    .byte $18,$3F,$3F,$3F
    .byte $18,$3F,$3F,$3F
    .byte $18,$3F,$3F,$3F
    .byte $18,$3F,$3F,$3F
    ;; Sprite palette
    .byte $00,$03,$23,$34
    .byte $00,$02,$38,$3C
    .byte $00,$1C,$15,$14
    .byte $00,$02,$38,$2C

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.segment "CHARS"

    ;; pattern table 0
    .incbin "jroatch_tiles.chr"
    ;; pattern table 1 (unused)
    ; .incbin "jroatch_tiles.chr"
