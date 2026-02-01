;;; nmi.s: handle NMI (vblank) and IRQ ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.include "config.inc"
.include "macros.inc"

;;; Imports & Exports ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.import audio_update
.importzp _TODO

.export nmi, irq
.exportzp nmi_wait

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
    phr                     ; save registers

    lda #0
    sta PPUCTRL             ; quick and dirty, turn off NMI until we're done
                            ; probably want to store the desired value of
                            ; PPUCTRL and restore it later

@nametable_update:


@set_scroll:
    ;; PPUADDR clobbers scroll values, apparently, so:
    bit PPUSTATUS
    lda #$00
    sta PPUSCROLL
    lda #$00
    sta PPUSCROLL

@oam_update:
    ;; Copy sprite info
    run_dma OAM_RAM
 
@nmi_end:
    lda #(CTRL_NMI | CTRL_NT_2000 | CTRL_SPR_0000 | CTRL_BG_0000 | CTRL_8x8)
    sta PPUCTRL             ; reset PPUCTRL flags (re-enable NMI)

    .if CFG_AUDIO_ENABLE    
        jsr audio_update    ; end of nmi is a good time to update audio, apparently
    .endif

    lda #0
    sta nmi_wait            ; notify main program it can resume

    plr                     ; restore registers

    ;; since we're not doing anything with irq, this saves a couple bytes
irq:
    rti

