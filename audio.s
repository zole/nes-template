.include "config.inc"

;;; Imports & Exports ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.export audio_init
.export audio_update:=famistudio_update
.export music_play:=famistudio_music_play
.export sfx_play

;;; Configuration ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.if FAMISTUDIO_CFG_DPCM_SUPPORT
    .import __DPCM_LOAD__

FAMISTUDIO_DPCM_OFF = __DPCM_LOAD__

.endif


;;; Binary Data ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.segment "RODATA"

music_data:
    .include "music.s"

.if FAMISTUDIO_CFG_SFX_SUPPORT
sfx_data:
    .include "sfx.s"
.endif

.segment "DPCM"

.if FAMISTUDIO_CFG_DPCM_SUPPORT
    .incbin "music.dmc"
.endif

;;; Reserved memory ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.segment "ZEROPAGE"

.segment "BSS"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.segment "CODE"

audio_init:
    lda #1                          ; NTSC
    ldx #<music_data
    ldy #>music_data
    jsr famistudio_init


.if FAMISTUDIO_CFG_SFX_SUPPORT
    ldx #<sfx_data
    ldy #>sfx_data
    jsr famistudio_sfx_init
.endif

    rts


sfx_play:
    ldx #FAMISTUDIO_SFX_CH0
    jmp famistudio_sfx_play

.include "famistudio_ca65.s"
