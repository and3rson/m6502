;
; SD card driver
;
; Reference:
; http://elm-chan.org/docs/mmc/mmc_e.html
;

.import wait8us
.import wait32us
.import wait2ms
.import VIA1_RB

.export sdc_init=init
.export _sdc_select_sector=select_sector
.export _sdc_read_sector=read_sector
.export _sdc_read_block_start=read_block_start
.export _sdc_read_block_byte=read_block_byte
.export _sdc_read_block_word=read_block_word
.export _sdc_read_block_end=read_block_end
; .export sdc_read_sector=read_sector
.export sdc_SECTOR_DATA=SECTOR_DATA
.exportzp sdc_ERR=ERR

.zeropage

; TODO: Remove prefixes
SDC_MISO  =  $1  ; Slave's DO
SDC_MOSI  =  $2  ; Slave's DI
SDC_SCK   =  $4
SDC_CS    =  $8

; TODO: Remove underscores

SDC_HEADER = %01000000

SELECTED_SEC: .res 2
DEST: .res 2

ERR: .res 1
BYTE: .res 1

.segment "SYSRAM"

SECTOR_DATA: .res 512

.segment "KORE"

; Initialize SD card
;
; Return:
;   C - set if error
init:
        pha
        phx

        ; Wait at least 1 ms
        jsr wait2ms

        lda VIA1_RB
        ora #(SDC_MOSI | SDC_CS)  ; DI=1, CS=1
        and #(SDC_SCK ^ $FF)  ; SCK=0
        sta VIA1_RB

        ; Send 74 clock cycles
        ldx #80*2
    @warmup:
        eor #SDC_SCK
        sta VIA1_RB
        dex
        bne @warmup

        jsr enable

        ; CMD0 - init
        jsr send_cmd0
        jsr wait_byte
        cmp #$01
        bne @readiness_timeout
        jsr read_byte  ; read tail

        ; CMD8 - send voltage
        jsr send_voltage_check
        jsr wait_byte  ; read header
        jsr skip_byte4  ; 32 bits
        jsr skip_byte  ; read tail
        cmp #$01
        bne @voltage_failed
        ; Read 32-bit voltage response

        ; CMD58 (7A) - send OCR
        jsr send_ocr
        jsr wait_byte  ; read header
        jsr skip_byte4  ; 32 bits
        jsr skip_byte  ; read tail
        cmp #$01
        bne @ocr_failed

        ; CMD55 - send app cmd
        jsr send_app
        jsr wait_byte  ; read header
        jsr skip_byte  ; read tail
        cmp #$01
        bne @app_failed

        ; CMD41 - send app op cond
        jsr send_op_cond
        jsr wait_byte  ; read header
        jsr skip_byte  ; read tail
        cmp #$01  ; initialization in progress?
        bne @op_cond_failed

        ldx #$FF  ; 256 attempts
    @wait_init:
        ; CMD55 - send app cmd
        jsr send_app
        jsr wait_byte  ; read header
        jsr skip_byte  ; read tail

        ; CMD41 - send app op cond
        jsr send_op_cond
        jsr wait_byte  ; read header
        jsr skip_byte  ; read tail
        cmp #$00  ; initialization finished?
        beq @wait_ok

        jsr wait32us
        dex
        bne @wait_init  ; retry
        ; Max attempts reached, fail
        jmp @init_timeout

    @wait_ok:
        ; CMD58 (7A) - send OCR
        jsr send_ocr
        jsr wait_byte  ; read header
        jsr skip_byte4  ; 32 bits
        jsr skip_byte  ; read tail
        ; Bit 30 of OCR should now contain 1 (the card is a high-capacity card known as SDHC/SDXC)

        lda #0
        ldx #2
        jsr _set_blocklen
        ; cmp #$01
        ; !!!
        cmp #$00
        bne @set_blocklen_failed

        clc
        jmp @end

    @readiness_timeout:
        lda #$E1
        jmp @err

    @voltage_failed:  ; SDHC unsupported, possibly card is SDSC
        lda #$E2
        jmp @err

    @ocr_failed:
        lda #$E3
        jmp @err

    @app_failed:
        lda #$E4
        jmp @err

    @op_cond_failed:
        lda #$E5
        jmp @err

    @init_timeout:
        lda #$E6
        jmp @err

    @set_blocklen_failed:
        lda #$E7

    @err:
        sta ERR
        sec

    @end:
        jsr disable

        plx
        pla

        rts

; Enable SD card
enable:
        pha
        phx

        lda VIA1_RB
        ldx #16  ; Pulse clock, 8 cycles
    @pulse:
        eor #SDC_SCK  ; Toggle edge
        sta VIA1_RB
        ; nop
        ; nop
        dex
        bne @pulse

        and #(SDC_CS ^ $FF)  ; Assert CS
        sta VIA1_RB

        ; Wait for CS to settle
        ; jsr wait32us
        jsr wait8us

        plx
        pla

        rts

; Disable SD card
disable:
        pha

        lda VIA1_RB
        ora #SDC_CS  ; Release CS
        sta VIA1_RB

        ; Wait for CS to settle
        lda #16
    @again:
        dec
        bne @again

        pla

        rts

; Set sector for reading
;
; Arguments:
;
;   A - sector low byte
;   X - sector high byte
select_sector:
        sta SELECTED_SEC
        stx SELECTED_SEC+1

        rts

; Read selected sector into memory (512 bytes)
; NOTE: select_sector must be called first!
; NOTE: Reading blocks only up to number 65535 is supported (16-bit LBA).
;
;   A - destination low byte
;   X - destination high byte
; Return:
;   A - error code, 0 if no error

; Start reading block
; NOTE: Reading blocks only up to number 65535 is supported (16-bit LBA).
read_sector:
        jsr enable

        sta DEST
        stx DEST+1

        lda SELECTED_SEC
        ldx SELECTED_SEC+1
        jsr read_block_start
        cmp #0
        bne @end  ; error

        ldy #0
    @next1:
        jsr read_block_byte
        sta (DEST), Y
        iny
        bne @next1

        inc DEST+1  ; Advance pointer 256 bytes forward

        ldy #0
    @next2:
        jsr read_block_byte
        sta (DEST), Y
        iny
        bne @next2

        jsr read_block_end

        lda #0
        jmp @end

    @end:
        jmp disable  ; (jsr, rts)

; Start reading of block
;
; Arguments:
;   A - low byte
;   X - high byte
; Return:
;   A - error code, 0 if no error
read_block_start:
        jsr enable

        jsr send_read_single_block
        jsr wait_byte
        cmp #0  ; ok?
        beq @header_ok
        lda #$A1
        jmp @end
    @header_ok:

        jsr wait_byte  ; Wait for data token
        cmp #$FE
        beq @token_ok  ; error
        lda #$A2
        jmp @end
    @token_ok:

        ; ok
        lda #0
        jmp @end

    @end:
        rts

; Read next byte from block
;
; Return:
;   A - byte
read_block_byte = read_byte

; Read next word from block (little-endian)
;
; Return:
;   A:X - word
read_block_word:
        jsr read_byte
        pha
        jsr read_byte
        tax
        pla
        rts

; Finish block reading
; Must be called only after all data was read.
read_block_end:
        pha

        ; Read checksum
        jsr skip_byte
        jsr skip_byte

        lda #$FF  ; Is this needed? https://electronics.stackexchange.com/a/375423/273764
        jsr write_byte

        pla

        jmp disable  ; (jsr, rts)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Private routines follow below


; Set block length for reading
; NOTE: Card needs to be enabled/disabled before/after call to this function.
; NOTE: Block length only up to number 65535 is supported (16-bit LBA).
;
; Arguments:
;   A - low byte
;   X - high byte
; Return:
;   C - set if error
_set_blocklen:
        pha
        phx

        jsr send_set_blocklen
        jsr wait_byte  ; read header
        jsr skip_byte  ; read tail
        cmp #$00
        bne @err

        ; ok
        clc
        jmp @end

    @err:
        sec
        sta ERR

    @end:
        plx
        pla

        rts

; CMD17 (51)
send_read_single_block:
        pha

        pha  ; low byte
        phx  ; high byte

        lda #(17 | SDC_HEADER)
        jsr write_byte
        ; TODO
        lda #0
        jsr write_byte
        jsr write_byte
        pla
        jsr write_byte  ; high byte
        pla
        jsr write_byte  ; low byte
        lda #$3B  ; CRC & stop bit
        jsr write_byte

        pla

        rts

; CMD0 - Init
send_cmd0:
        pha

        lda #(0 | SDC_HEADER)
        jsr write_byte
        lda #0  ; arguments
        jsr write_byte
        jsr write_byte
        jsr write_byte
        jsr write_byte
        lda #$95  ; CRC & stop bit
        jsr write_byte

        pla

        rts

; CMD8
send_voltage_check:
        pha

        lda #(8 | SDC_HEADER)
        jsr write_byte
        lda #0  ; arguments
        jsr write_byte
        jsr write_byte
        lda #1
        jsr write_byte
        lda #$AA
        jsr write_byte
        lda #$87  ; CRC & stop bit
        jsr write_byte

        pla

        rts

; CMD58 (7A)
send_ocr:
        pha

        lda #(58 | SDC_HEADER)
        jsr write_byte
        lda #0  ; arguments
        jsr write_byte
        jsr write_byte
        jsr write_byte
        jsr write_byte
        lda #%01110101  ; CRC & stop bit
        jsr write_byte

        pla

        rts

; CMD55
send_app:
        pha

        lda #(55 | SDC_HEADER)
        jsr write_byte
        lda #0  ; arguments
        jsr write_byte
        jsr write_byte
        jsr write_byte
        jsr write_byte
        ; lda #%11111111  ; CRC & stop bit
        lda #$55  ; CRC & stop bit
        jsr write_byte

        pla

        rts

; CMD41
send_op_cond:
        pha

        lda #(41 | SDC_HEADER)
        jsr write_byte
        lda #%01000000  ; arguments
        jsr write_byte
        lda #0
        jsr write_byte
        jsr write_byte
        jsr write_byte
        ; lda #%11111111  ; CRC & stop bit
        lda #$77  ; CRC & stop bit
        jsr write_byte

        pla

        rts

; CMD16
send_set_blocklen:
        pha
        phx

        pha  ; low byte
        phx  ; high byte

        lda #(16 | SDC_HEADER)
        jsr write_byte
        lda #0  ; arguments
        jsr write_byte
        jsr write_byte
        pla  ; high byte
        jsr write_byte
        pla  ; low byte
        jsr write_byte
        lda #$81  ; CRC & stop bit
        jsr write_byte

        plx
        pla

        rts

; Write SPI byte
;
; Arguments:
;   A - byte
write_byte:
        pha
        phx
        phy

        ldx #8
    @send_bit:
        tay
        and #$80
        bne @set_1
    @set_0:
        lda VIA1_RB
        and #(SDC_MOSI ^ $FF)
        jmp @write
    @set_1:
        lda VIA1_RB
        ora #SDC_MOSI
    @write:
        sta VIA1_RB

        lda VIA1_RB
        ; Pulse clock
        eor #SDC_SCK
        sta VIA1_RB
        ; nop
        ; nop
        eor #SDC_SCK
        sta VIA1_RB
        ; nop
        ; nop

        tya
        rol

        dex
        bne @send_bit

        ply
        plx
        pla

        rts

; Read SPI byte
;
; Return:
;   A - byte
read_byte:
        phx

        ldx #8
        lda VIA1_RB
    @read_bit:
        ; Pulse clock
        eor #SDC_SCK
        sta VIA1_RB
        ; nop
        ; nop

        lda VIA1_RB
        ror
        rol BYTE

        lda VIA1_RB
        eor #SDC_SCK
        sta VIA1_RB
        ; nop
        ; nop

        dex
        bne @read_bit

        lda BYTE

        plx

        rts

; Read & disregard 1 byte
skip_byte:
        pha

        jsr read_byte

        pla

        rts

; Read & disregard 4 bytes
skip_byte4:
        pha

        jsr read_byte
        jsr read_byte
        jsr read_byte
        jsr read_byte

        pla

        rts

; Wait for byte on MISO
;
; Return:
;   A - received byte or $FF if no data was read (MISO stayed high & timed out)
wait_byte:
        phx

        ldx #$FF  ; 255 attempts
    @again:
        jsr read_byte
        cmp #$FF  ; is busy?
        bne @end  ; no, return data
        ; jsr wait32us
        jsr wait8us
        dex
        bne @again  ; try again
        ; Max attempts reached, return $FF

    @end:
        plx

        rts
