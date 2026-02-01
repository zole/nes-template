.include "config.inc"
.include "macros.inc"

;;; Imports & Exports ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.import audio_init
.import input_read
.importzp nmi_wait, buttons, buttons_pressed

.export _main, early_init

;;; Constants ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;; Reserved memory ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.segment "ZEROPAGE"

;; TODO:
; .exportzp

framectr:           .res 1

.segment "RAM"

;; TODO:
; .export

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.segment "CODE"

    ;; Memory has been cleared but PPU is not ready
.proc early_init
    .if ::CFG_AUDIO_ENABLE
        jsr audio_init
    .endif

    rts
.endproc


    ;; PPU is ready at this point
_main:
.proc init
    ;; Use this proc to do any one-time setup you need. Since rendering is
    ;; disabled at this point, you can write to the PPU and do other stuff for
    ;; as many cycles as you want, within reason.
    
    load_palettes palette, 0, 8     ; example


    ;; specify PPU settings and turn on NMI / background / sprites
enable_ppu:
    lda #(MASK_BG | MASK_SPR | MASK_BG_CLIP)
    sta PPUMASK
    lda #(CTRL_NMI | CTRL_NT_2000 | CTRL_SPR_0000 | CTRL_BG_0000 | CTRL_8x8)
    sta PPUCTRL

.endproc ; all done with initialization


    ;; Main loop.
    ;;
    ;; The (NTSC) CPU budget when drawing sprites and backgrounds is approx.:
    ;;       29780      CPU cycles per frame
    ;;     -   514      OAM DMA
    ;;     -  1750      Remaining time in Vblank
    ;;       =====
    ;;       27516      Cycles available for game update logic each frame
loop:
    inc nmi_wait
    ;; kill time until vblank handler starts
@spin:
    lda nmi_wait
    bne @spin

    ;; this doesn't have to be a subroutine, but it's helpful if you're
    ;; profiling your update code
    jsr update

    inc framectr
    jmp loop


.proc update
    jsr input_read
    
    rts
.endproc

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.segment "RODATA"

palette:
    ;; Background palettes
    .byte $18,$3F,$3F,$3F
    .byte $18,$3F,$3F,$3F
    .byte $18,$3F,$3F,$3F
    .byte $18,$3F,$3F,$3F
    ;; Sprite palettes
    .byte $00,$03,$23,$34
    .byte $00,$02,$38,$3C
    .byte $00,$1C,$15,$14
    .byte $00,$02,$38,$2C

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.segment "CHARS"

    ;; pattern table 0
    .incbin "jroatch_tiles.chr"
    ;; pattern table 1
    .incbin "jroatch_tiles.chr"
