.include "config.inc"
.include "macros.inc"

.include "zeropage.inc"

;;;;;;

    ;; Define and export these symbols in other files
    .import _main           ; hook for the post-PPU setup code
    .import nmi             ; hook for NMI handler
    .import irq             ; hook for IRQ handler (reqs. special hardware or
                            ;   the BRK instruction)

    .ifnblank CFG_PREINIT_FN
        .import CFG_PREINIT_FN
    .endif


    .import __CSTACK_START__, __CSTACK_SIZE__
    .export __STARTUP__ : absolute = 1      ; Mark as startup
    .import copydata
    ; importzp

;;;;;;

    ;; Can edit via nes.cfg
.segment "HEADER"
    .byte $4e,$45,$53,$1a
	.byte <NES_PRG_BANKS
	.byte <NES_CHR_BANKS
	.byte <NES_MIRRORING|(<NES_MAPPER<<4)
	.byte <NES_MAPPER&$f0

;;;;;;

.segment "VECTORS"
    ; non-maskable interrupt address
    .word nmi
    ; entry point
    .word reset
    ; IRQ - unused
    .word irq

;;;;;;

.segment "ZEROPAGE"

.segment "DATA"

;;;;;;

.segment "STARTUP"

    ;; Execution starts here after power up or reset.
.proc reset
    sei                 ; disable IRQs
    cld                 ; disable decimal mode
    ldx #$00
    stx PPUCTRL         ; disable NMI
    stx PPUMASK         ; disable rendering
    stx APU_DMC_CTRL    ; Disable DMC IRQ

    dex                 ; stack starts at $01FF
    txs                 ; initialize stack
    inx                 ; now X = 0

    ; Optional (omitted):
    ; Set up mapper and jmp to further init code here.

    ; The vblank flag is in an unknown state after reset,
    ; so it is cleared here to make sure that @vblankwait1
    ; does not exit immediately.
    bit PPUSTATUS

    ; TODO: is this right?
    bit APU_CHAN_CTRL          ; Acknowledge DMC IRQ

    ;; First of two waits for vblank to allow the PPU to stabilize
vblankwait1:
    bit PPUSTATUS
    bpl vblankwait1

    ; We now have about 30,000 cycles to burn before the PPU stabilizes.
    ; One thing we can do with this time is put RAM in a known state.
    ; Here we fill it with $00, which matches what (say) a C compiler
    ; expects for BSS. Since we haven't modified the X register since
    ; the earlier code above, it's still set to 0, so we can just
    ; transfer it to the Accumulator and save a byte

clear_memory:
    lda #0
    sta $0000, x    
    sta $0100, x
    sta $0300, x
    sta $0400, x
    sta $0500, x
    sta $0600, x
    sta $0700, x
    lda #$fe                ; $fe moves all sprites off screen.
                            ; is it worth the extra load?
    sta $0200, x    
    inx
    bne clear_memory        ; will fall through when x == 0

.ifdef USE_C
    ;; Copy DATA segment to BSS
    jsr copydata

    ;; Set up the C stack
    lda     #<(__CSTACK_START__ + __CSTACK_SIZE__)
    ldx     #>(__CSTACK_START__ + __CSTACK_SIZE__)
    sta     c_sp
    stx     c_sp+1
.endif

    ;; Jump to any extra pre-PPU init code
    ;; Other things you can do between vblank waits are set up audio
    ;; or set up other mapper registers.
    .ifnblank CFG_PREINIT_FN
        jsr CFG_PREINIT_FN
    .endif

    ;; Second wait for vblank, PPU is ready after this.
vblankwait2:
    bit PPUSTATUS
    bpl vblankwait2

    jmp _main               ; underscore allows for a C main()

.endproc