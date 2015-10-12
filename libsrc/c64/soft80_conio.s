;
; Groepaz/Hitmen, 11.10.2015
;
; Low level init code for soft80 screen output/console input
;

        .constructor    soft80_init, 8
        .destructor     soft80_shutdown

        .import         soft80_kclrscr, soft80_charset
        .export         soft80_internal_textcolor, soft80_internal_bgcolor
        .export         soft80_internal_cursorxlsb

        .importzp       ptr1, ptr2, ptr3

        .include        "c64.inc"
        .include        "soft80.inc"

soft80_init:
        lda     soft80_first_init
        bne     @skp
        jsr     firstinit
@skp:
        ; the "color voodoo" in other parts of the code relies on the vram and
        ; colorram being set up as expected, which is why we cant use the
        ; _bgcolor and _textcolor functions here.

        lda     646                             ; use current textcolor
        and     #$0f
        sta     soft80_internal_textcolor

        lda     VIC_BG_COLOR0                   ; use current bgcolor
        and     #$0f
        sta     soft80_internal_bgcolor
        asl     a
        asl     a
        asl     a
        asl     a
        ora     soft80_internal_textcolor
        sta     CHARCOLOR

        lda     #$3b
        sta     VIC_CTRL1
        lda     #$00
        sta     CIA2_PRA
        lda     #$68
        sta     VIC_VIDEO_ADR
        lda     #$c8
        sta     VIC_CTRL2

        jmp     soft80_kclrscr

soft80_shutdown:
        lda     #$1b
        sta     VIC_CTRL1
        lda     #$03
        sta     CIA2_PRA
        lda     #$15
        sta     VIC_VIDEO_ADR
        rts

        .segment "INIT"
firstinit:
        ; copy charset to RAM under I/O
        sei
        lda     $01
        pha
        lda     #$34
        sta     $01

        inc     soft80_first_init

        lda     #>soft80_charset
        sta     ptr1+1
        lda     #<soft80_charset
        sta     ptr1
        lda     #>soft80_lo_charset
        sta     ptr2+1
        lda     #<soft80_lo_charset
        sta     ptr2
        lda     #>soft80_hi_charset
        sta     ptr3+1
        lda     #<soft80_hi_charset
        sta     ptr3

        ldx     #4
@l2:
        ldy     #0
@l1:
        lda     (ptr1),y
        sta     (ptr2),y
        asl     a
        asl     a
        asl     a
        asl     a
        sta     (ptr3),y
        iny
        bne     @l1
        inc     ptr1+1
        inc     ptr2+1
        inc     ptr3+1
        dex
        bne     @l2

        ; copy the kplot tables to ram under I/O
        ;ldx     #0              ; is 0
@l3:
        lda     soft80_tables_data_start,x
        sta     soft80_bitmapxlo,x
        lda     soft80_tables_data_start + (soft80_tables_data_end - soft80_tables_data_start - $100) ,x
        sta     soft80_bitmapxlo + (soft80_tables_data_end - soft80_tables_data_start - $100),x
        inx
        bne     @l3

        pla
        sta     $01
        cli
        rts

; the following tables take up 267 bytes, used by kplot
soft80_tables_data_start:

soft80_bitmapxlo_data:
        .repeat 80,col
        .byte <((col/2)*8)
        .endrepeat
soft80_bitmapxhi_data:
        .repeat 80,col
        .byte >((col/2)*8)
        .endrepeat
soft80_vramlo_data:
        .repeat 25,row
        .byte <(soft80_vram+(row*40))
        .endrepeat
        .byte 0,0,0,0,0,0,0     ; padding to next page
soft80_vramhi_data:
        .repeat 25,row
        .byte >(soft80_vram+(row*40))
        .endrepeat
soft80_bitmapylo_data:
        .repeat 25,row
        .byte <(soft80_bitmap+(row*40*8))
        .endrepeat
soft80_bitmapyhi_data:
        .repeat 25,row
        .byte >(soft80_bitmap+(row*40*8))
        .endrepeat

soft80_tables_data_end:

;-------------------------------------------------------------------------------
; FIXME: when the code is fixed to use the "init" segment, these variables must
;        be moved into a section other than .bss so they survive after the init
;        code has been run.

        .data           ; FIXME
soft80_internal_textcolor:
        .res 1
soft80_internal_bgcolor:
        .res 1
soft80_internal_cursorxlsb:
        .res 1

        .data
soft80_first_init:
        .byte 0         ; flag to check first init, this really must be in .data
