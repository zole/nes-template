.include "config.inc"
.include "macros.inc"

.ifndef CFG_PLAYERS
    CFG_PLAYERS = 2
.endif

.if CFG_PLAYERS > 2
    .error "CFG_PLAYERS: Only two players are supported"
.elseif CFG_PLAYERS < 1
    .error "CFG_PLAYERS is invalid"
.endif


;;; Imports & Exports ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; .import
; .importzp

.export input_read, input_key_pressed
.exportzp buttons, buttons_prev, buttons_pressed


;;; Reserved memory ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


.segment "ZEROPAGE"

buttons:         .res CFG_PLAYERS
buttons_pressed: .res CFG_PLAYERS
buttons_prev:    .res CFG_PLAYERS

.segment "BSS"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.segment "CODE"

    ;; Read both controllers in a DPCM-safe way
input_read:
    ldx #$00

.if CFG_PLAYERS > 1
    ;; two player variant
    jsr @readjoyx_safe  ; X=0: safe read controller 1
    inx
    ; fall through to readjoyx_safe, X=1: safe read controller 2
.endif

    ;; 
@readjoyx_safe:
    lda buttons, x
    sta buttons_prev, x

    jsr readjoyx
@reread:
    lda buttons, x
    pha
    jsr readjoyx
    pla
    cmp buttons, x
    bne @reread

    ; we've got a stable reading in buttons+x
    lda buttons_prev, x
    eor #$FF            ; now A is a bitmap of buttons not pressed last update
    and buttons, x
    sta buttons_pressed, x
    ; lda buttons_pressed
    rts

.proc readjoyx           ; X register = 0 for controller 1, 1 for controller 2
    lda #$01
    sta JOYPAD1
    sta buttons, x
    lsr a
    sta JOYPAD1
loop:
    lda JOYPAD1, x
    and #%00000011  ; ignore bits other than controller
    cmp #$01        ; Set carry if and only if nonzero
    rol buttons, x  ; Carry -> bit 0; but 7 -> Carry
    bcc loop
    rts
.endproc

    ;; [in] A: button bitmask to test for
    ;; [in] X: which controller
    ;; [out] Z: clear if button was just pressed, set otherwise
    ;; [clobbers] Y
.proc input_key_pressed
    tay
    and buttons, X 
    beq done                ; not pressed this frame, Z is set

    ; tya
    eor buttons_prev, X     ; toggle buttons that were pressed last frame

    ; toggle all the buttons set Z if button was not pressed last frame
    ; eor #$FF                ; flip the Z flag to match the expected state
    
done:
    rts
.endproc

