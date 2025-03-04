;
; Helper functions
;

.include "../include/define.inc"

.export f_parse_hex
.export _f_parse_hex = f_parse_hex
.export f_parse_octet
.export _f_parse_octet = f_parse_octet
.export wait2us
.export wait8us
.export wait16us
.export wait2ms
.export wait16ms

.import vdelay

.zeropage

F_BYTE: .res 1
F_PTR: .res 2

.segment "KORE"

.export _wait1ms = wait1ms
.export _wait16ms = wait16ms
.export wait32us

; Parse hexadecimal ASCII character into number
;
; Arguments:
;   A - ASCII character
; Return:
;   A - value (0..15), $F0 if character is not a valid hex literal
f_parse_hex:
        sec
        sbc #'0'
        bmi @invalid  ; Less than 48
        cmp #10
        bmi @end      ; Return digit (== bcc?)

        ; Check for uppercase letter
        sbc #'A'-'0'
        bmi @invalid  ; <A
        cmp #6
        bpl @lowercase  ; >F
        jmp @add10

    @lowercase:
        ; Check for lowercase
        sbc #'a'-'A'
        bmi @invalid  ; <a
        cmp #6
        bpl @invalid  ; >f
        jmp @add10

    @add10:
        clc
        adc #10
        jmp @end
    @invalid:
        lda #$F0
    @end:
        rts

; Parse two hexadecimal ASCII characters into number
;
; Arguments:
;   A - lower address of first of two ASCII characters
;   X - higher address of first of two ASCII characters
; Return:
;   A - value (0..255)
f_parse_octet:
        phx
        phy

        sta F_PTR
        stx F_PTR+1
        lda (F_PTR)
        jsr f_parse_hex
        asl
        asl
        asl
        asl
        sta F_BYTE

        ldy #1
        lda (F_PTR), Y
        jsr f_parse_hex
        ora F_BYTE

        ply
        plx

        rts


; Wait ~2 us
wait2us:
        pha
        phx

        lda #<(2 * CYCLES_PER_US)
        ldx #>(2 * CYCLES_PER_US)
        jsr vdelay

        plx
        pla

        rts


; Wait ~8 us
wait8us:
        pha
        phx

        lda #<(8 * CYCLES_PER_US)
        ldx #>(8 * CYCLES_PER_US)
        jsr vdelay

        plx
        pla

        rts


; Wait ~16 us
wait16us:
        pha
        phx

        lda #<(16 * CYCLES_PER_US)
        ldx #>(16 * CYCLES_PER_US)
        jsr vdelay

        plx
        pla

        rts


; Wait ~32 us
wait32us:
        pha
        phx

        lda #<(32 * CYCLES_PER_US)
        ldx #>(32 * CYCLES_PER_US)
        jsr vdelay

        plx
        pla

        rts


; Wait ~1 ms
wait1ms:
        pha
        phx

        ; lda #$00
        ; ldx #$20
        lda #<(1000 * CYCLES_PER_US)
        ldx #>(1000 * CYCLES_PER_US)
        jsr vdelay

        plx
        pla

        rts

; Wait ~2 ms
wait2ms:
        pha
        phx

        ; lda #$00
        ; ldx #$40
        lda #<(2000 * CYCLES_PER_US)
        ldx #>(2000 * CYCLES_PER_US)
        jsr vdelay

        plx
        pla

        rts


; Wait ~16 ms
wait16ms:
        pha
        phx

        ; lda #$FF
        ; ldx #$FF
        lda #<(8000 * CYCLES_PER_US)
        ldx #>(8000 * CYCLES_PER_US)
        jsr vdelay
        ; lda #$FF
        ; ldx #$FF
        lda #<(8000 * CYCLES_PER_US)
        ldx #>(8000 * CYCLES_PER_US)
        jsr vdelay

        plx
        pla

        rts

; Wait ~1 s
wait1s:
        pha
        phx

        ; TODO
        ldx #120
    @again:
        phx
        lda #$FF
        ldx #$FF
        jsr vdelay
        plx
        dex
        bne @again

        plx
        pla

        rts

