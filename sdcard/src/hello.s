.feature string_escapes

.org $1000

; lcd_printz = $E250
; lcd_printz = $E317
lcd_printz = $E25B

main:
        lda #<HELLO
        ldx #>HELLO
        jsr lcd_printz
        rts

HELLO: .asciiz "Hello from SD Card!\n"
