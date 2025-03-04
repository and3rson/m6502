;
; HD44780 40x04 LCD implementation with constant tty-like scrolling
;
; Uses port A of 6522 VIA w/ 4-bit data bus & busy flag polling
; Datasheet: https://www.sparkfun.com/datasheets/LCD/HD44780.pdf
;

.importzp sp
.import wait2us
.import wait8us
.import VIA1_DDRA
.import VIA1_RA
.import vdelay
.import popa

.export _puts = printz
.export _cputc = printchar
.export _gotoxy
.export _clrscr = clrscr
.export _printhex = printhex
.export _printword = printword
.export lcd_init = init
.export lcd_printchar = printchar
.export lcd_printhex = printhex
.export lcd_printz = printz
.export lcd_printfz = printfz
.export lcd_BUFFER_PREV = BUFFER_PREV

.zeropage

; generic 16-bit pointer for string operations
PTR:     .res  2
REG:     .res  2
MEM:     .res  2
INIT:    .res  1  ; Set to $01 if LCD was initialized in one of previous boots
ENFLAG:  .res  1  ; Used by writenib

RS  =  %10000000
RW  =  %01000000
EN2 =  %00100000
EN1 =  %00010000

CURSOR_X:  .res  1
CURSOR_Y:  .res  1

ADDR:  .res 2

.segment "SYSRAM"

BUFFER:    .res  160
BUFFER_PREV = BUFFER + 80
BUFFER_CURRENT = BUFFER + 120

.segment "KORE"

; The code below was tested at 4 MHz & 8 MHz, but it should run on any frequency
; as long as CLOCK is set to a proper value.

DD_LINE_ADDR: .byte 0, 64, 0, 64

FONT:
; Not used
    .res 8
; Block
    .byte %11111
    .byte %11111
    .byte %11111
    .byte %11111
    .byte %11111
    .byte %11111
    .byte %11111
    .byte %11111
; Not used
    .res 8
; Not used
    .res 8
; Not used
    .res 8
; Not used
    .res 8
; Not used
    .res 8
; Trident
    .byte %00100
    .byte %10101
    .byte %10101
    .byte %11011
    .byte %11111
    .byte %10101
    .byte %11111
    .byte %00100

BLOCK:

; Initialize LCD
init:
        pha
        phx
        phy

        ; Set up pointer to array with line addresses
        ; lda #<DD_LINE_ADDR
        ; sta P_DD_LINE_ADDR
        ; lda #>DD_LINE_ADDR
        ; sta P_DD_LINE_ADDR+1

        ; Clear screen buffer
        ldx #0
    @clear:
        lda #' '
        sta BUFFER, X
        inx
        cpx #160
        bne @clear

        ; vdelay @ 4 MHz:
        ; $0020 - 8 us
        ; $0080 - 32 us
        ; $0100 - 64 us
        ; $0200 - 128 us
        ; $1000 - 1.024 ms
        ; $4000 - 4.096 ms
        ; $FFFF - ~16.384 ms

        ; vdelay @ 8 MHz:
        ; $0040 - 8 us
        ; $0100 - 32 us
        ; $0200 - 64 us
        ; $0400 - 128 us
        ; $2000 - 1.024 ms
        ; $8000 - 4.096 ms
        ; $FFFF - ~8.192 ms

        ; lda INIT  ; Is LCD already initialized?
        ; bne @postinit
        ; inc
        ; sta INIT

    @init:
        ; https://www.microchip.com/forums/m/tm.aspx?m=1023133&p=1
        ; ldy #$40  ; 1 s
        ldy #$20  ; 256ms
    @longinit:
        lda #$FF
        ldx #$FF
        jsr vdelay  ; 8.192 ms
        dey
        bne @longinit

        ldx #(EN1 | EN2)
        stx ENFLAG
        ; Initialize 4-bit mode
        lda #%0010
        jsr writenib
        lda #$00
        ldx #$80
        jsr vdelay  ; 4 ms

        lda #%0010
        jsr writenib
        lda #$00
        ldx #$04
        jsr vdelay  ; 128 us

        lda #%0010
        jsr writenib
        lda #$00
        ldx #$02
        jsr vdelay  ; 64 us

    @postinit:
        lda #%00101000  ; 4 bit, 2 lines, 5x8
        jsr writecmd
        jsr busy

        lda #%00000110  ; increment, no shift
        jsr writecmd
        jsr busy

        lda #%00001111  ; display on, cursor on, blink on
        jsr writecmd
        jsr busy

        ; Upload 8 characters of custom font
        lda #(%01000000)
        jsr writecmd
        jsr busy
        ldx #$0
    @row:
        lda FONT, X
        jsr writedata
        jsr busy
        inx
        cpx #64
        bne @row

        lda #%00000001  ; Clear screen
        jsr writecmd
        jsr busy
        lda #$00
        ldx #$80
        jsr vdelay  ; 4 ms

        ldx #0
        ldy #3
        jsr gotoxy

    @end:
        ply
        plx
        pla

        rts

; Clear screen
clrscr:
        pha
        phx

        ldx #0
    @clear:
        lda #' '
        sta BUFFER, X
        inx
        cpx #160
        bne @clear

        plx
        pla

        jmp redraw  ; (jsr, rts)

; Write nibble with EN toggle
;
; Arguments:
;   A - nibble with register bit (%x000xxxx)
writenib:
        pha
        phx

        ; ldx #$7F
        ; Set data lines to output
        ldx #(RS | RW | EN2 | EN1 | $F)
        stx VIA1_DDRA

        tax
        ; Assert RS
        and #RS
        sta VIA1_RA
        ; jsr wait8us
        jsr wait2us
        txa

        ; Assert data
        sta VIA1_RA
        ; jsr wait32us
        jsr wait8us

        ; Assert EN
        eor ENFLAG
        sta VIA1_RA
        ; jsr wait8us
        jsr wait2us

        ; Release EN
        eor ENFLAG
        sta VIA1_RA
        ; jsr wait8us
        jsr wait2us

        plx
        pla

        rts

; Write cmd byte with EN toggle
;
; Arguments:
;   A - byte
writecmd:
        pha
        pha

        ; Write high nibble
        lsr
        lsr
        lsr
        lsr
        jsr writenib

        ; Write low nibble
        pla
        and #$0F
        jsr writenib

        pla

        rts

; Write data byte with EN toggle
;
; Arguments:
;   A - byte
writedata:
        pha
        pha

        ; Write high nibble
        lsr
        lsr
        lsr
        lsr
        ora #RS
        jsr writenib

        ; Write low nibble
        pla
        and #$0F
        ora #RS
        jsr writenib

        pla

        rts

; Read byte with EN toggle
;
; Return:
;   A - value
read_clock:
        ; Set data to input
        phx

        ; lda #$70
        lda #(RS | RW | EN2 | EN1)
        sta VIA1_DDRA

        ldx #2
    @next:
        lda #RW  ; RS=0, RW=1, EN=0
        sta VIA1_RA
        ; jsr wait8us
        jsr wait2us
        eor ENFLAG  ; Assert EN
        sta VIA1_RA
        ; jsr wait8us
        jsr wait2us
        lda VIA1_RA  ; read nibble
        and #$0F
        sta MEM - 1, X
        lda #RW  ; RS=0, RW=1, EN
        sta VIA1_RA
        ; jsr wait8us
        jsr wait2us
        dex
        bne @next

        ; MEM[0, 1] = low, high
        lda MEM+1
        asl
        asl
        asl
        asl
        ora MEM

        plx

        rts


; Block while LCD is busy
busy:
        pha
        phx

        ldx ENFLAG

        lda #EN1
        sta ENFLAG
    @check_1:
        jsr read_clock
        and #$80
        bne @check_1

        lda #EN2
        sta ENFLAG
    @check_2:
        jsr read_clock
        and #$80
        bne @check_2

        stx ENFLAG

        plx
        pla

        rts


; Move LCD cursor
;
; Arguments:
;   X - column
;   Y - row
gotoxy:
        pha
        phx
        phy

        stx CURSOR_X
        sty CURSOR_Y
        cpy #2
        bcs @bottom
    @top:
        lda #EN1
        jmp @done
    @bottom:
        lda #EN2
    @done:
        ; Disable cursor for another half
        eor #(EN1 | EN2)
        sta ENFLAG
        lda #%00001100  ; display on, cursor off, blink off
        jsr writecmd
        jsr busy

        ; Enable cursor for current half
        lda ENFLAG
        eor #(EN1 | EN2)
        sta ENFLAG
        lda #%00001111  ; display on, cursor on, blink on
        jsr writecmd
        jsr busy
        ; sta ENFLAG

        ; Get DDRAM addr for line start
        lda DD_LINE_ADDR, Y
        ; Add X
        clc
        adc CURSOR_X
        ; Add instruction flag
        ora #$80
        ; Move cursor
        jsr writecmd
        jsr busy

    @end:
        ply
        plx
        pla

        rts



; ; Clear LCD
; ; Arguments: none
; clear:
;         pha
;         phx
;         phy

;         lda #%00000001 ; clear
;         jsr write_cmd

;         ; Set cursor pos
;         ldx #0
;         ldy #3
;         jsr gotoxy

;         ply
;         plx
;         pla

;         rts


; Print character to LCD
; Do not print anything if no space is left
;
; Arguments:
;   A - character code
printchar:
        pha
        phx
        phy

        ; Check if \n
        cmp #10
        beq @newline

        cmp #8
        beq @backspace

        ; Check if has space
        tax
        lda CURSOR_X
        cmp #39
        beq @end  ; no more space

        ; Print character
        pha
        txa
        jsr writedata
        jsr busy
        pla

        ; Char X-pos -> X, char code -> A
        phx
        tax
        pla

        ; Write to screen buffer
        sta BUFFER_CURRENT, X

        ; Increase cursor X-pos
        inx
        stx CURSOR_X

        jmp @end

    @newline:
        ; Scroll screen memory up by 40 bytes
        ldx #0
    @scroll1:
        lda BUFFER + 40, X
        sta BUFFER, X
        inx
        cpx #120
        bne @scroll1

        ; Fill line 3 with spaces
        ldx #0
    @add_space:
        lda #' '
        sta BUFFER_CURRENT, X
        inx
        cpx #40
        bne @add_space

        jsr redraw

        ldx #0
        ldy #3
        jsr gotoxy

        jmp @end

    @backspace:
        lda CURSOR_X
        beq @end  ; already at first column
        ; Update cursor position & screen buffer
        tax
        dex
        stx CURSOR_X
        lda #' '
        sta BUFFER_CURRENT, X
        ; Move cursor left
        lda #%00010000
        ldx #EN2
        jsr writecmd
        jsr busy
        ; Write space
        lda #' '
        ldx #EN2
        jsr writedata
        jsr busy
        ; Move cursor left
        lda #%00010000
        ldx #EN2
        jsr writecmd
        jsr busy

    @end:
        ply
        plx
        pla

        rts

; Redraw entire screen from memory buffer
redraw:
        pha
        phx
        phy

        ldx #0
        ldy #0
        jsr gotoxy
    @print_line0:
        lda BUFFER, X
        jsr writedata
        jsr busy
        inx
        cpx #40
        bne @print_line0

        ldx #0
        ldy #1
        jsr gotoxy
    @print_line1:
        lda BUFFER + 40, X
        jsr writedata
        jsr busy
        inx
        cpx #40
        bne @print_line1

        ldx #0
        ldy #2
        jsr gotoxy
    @print_line2:
        lda BUFFER + 80, X
        jsr writedata
        jsr busy
        inx
        cpx #40
        bne @print_line2

        ldx #0
        ldy #3
        jsr gotoxy
    @print_line3:
        lda BUFFER_CURRENT, X
        jsr writedata
        jsr busy
        inx
        cpx #40
        bne @print_line3

        ply
        plx
        pla

        rts


; Print zero-terminated string to LCD
;
; Arguments:
;   A - string addr (low)
;   X - string addr (high)
; Return:
;   A - number of characters printed (i. e. string length)
printz:
        phx
        phy

        ; Store string start address to PTR
        sta PTR
        stx PTR+1

        ldy #0

    @printchar:
        lda (PTR), Y
        ; cmp #0
        beq @end

        jsr printchar
        iny
        jmp @printchar

    @end:
        tya
        ply
        plx

        rts

; Print zero-terminated string that follows jsr which calls this function
;
; Registers:
;   A - not preserved
printfz:
        pla         ; low return PC
        clc
        adc #1      ; first byte after jsr
        sta ADDR
        pla         ; high return PC
        adc #0      ; carry
        sta ADDR+1

        phx         ; preserve X
        tax
        lda ADDR    ; A:X now point to string start
        jsr printz  ; A now contains string length minus one (position of trailing zero byte)
        plx

        ; New return address = ADDR + A (no need to add 1)
        clc
        adc ADDR
        sta ADDR    ; low return PC
        lda ADDR+1
        adc #0
        pha         ; high return PC
        lda ADDR
        pha         ; low return PC

        rts

; Print hexadecimal representation (4-bit)
;
; Arguments:
;   A - value (low nibble)
printnibble:
        pha

        and #$0F
        cmp #10
        bcs @letter ; >= 10

    @digit:
        clc
        adc #48  ; 0..9 -> ascii
        jsr printchar
        jmp @end

    @letter:
        clc
        adc #55  ; 10..15 -> ascii
        jsr printchar

    @end:
        pla

        rts

; Print hexadecimal representation (8-bit)
;
; Arguments:
;   A - value
printhex:
        pha
        phx

        tax
        ; High nibble
        lsr
        lsr
        lsr
        lsr
        jsr printnibble
        txa
        jsr printnibble

        plx
        pla

        rts


; Print hexadecimal representation (16-bit)
;
; Arguments:
;   A:X - value
printword:
        pha

        txa
        jsr printhex
        pla
        jsr printhex

        rts


; Print binary representation
;
; Arguments:
;   A - value
printbin:
        pha
        phx
        phy

        ldx #8
        tay
    @again:
        tya  ; restore A & set sign bit
        bmi @one
    @zero:
        lda #'0'
        jmp @print
    @one:
        lda #'1'
    @print:
        jsr printchar
        tya
        rol
        tay
        dex
        bne @again

        ply
        plx
        pla

        rts

crlf:
        pha

        lda #10
        jsr printchar

        pla

        rts

; __fastcall__ variants
_gotoxy:
        tay  ; 2nd arg
        jsr popa
        tax  ; 1st arg
        jsr gotoxy

        rts
