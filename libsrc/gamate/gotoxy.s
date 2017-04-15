;
; void gotoxy (unsigned char x, unsigned char y);
;

        .export         gotoxy, _gotoxy
        .import         popa, plot

        .include        "gamate.inc"
        .include        "extzp.inc"

gotoxy:
        jsr     popa            ; Get X

_gotoxy:
        sta     CURS_Y          ; Set Y
        jsr     popa            ; Get X
        sta     CURS_X          ; Set X
        jmp     plot            ; Set the cursor position

;-------------------------------------------------------------------------------
; force the init constructor to be imported

        .import initconio
conio_init      = initconio
