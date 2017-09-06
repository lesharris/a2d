        .setcpu "65C02"
        .org $800

        .include "../inc/prodos.inc"
        .include "../inc/auxmem.inc"
        .include "../inc/applesoft.inc"
        .include "a2d.inc"

L0020           := $0020
L00B1           := $00B1
L4015           := $4015

        jmp     L0804

L0803:  .byte   0

L0804:  tsx
        stx     L0803
        lda     $C082
        lda     #$46
        sta     $3C
        lda     #$08
        sta     $3D
        lda     #$E4
        sta     $3E
        lda     #$13
        sta     $3F
        lda     #$46
        sta     $42
        lda     #$08
        sta     $43
        sec
        jsr     AUXMOVE
        lda     #$46
        sta     $03ED
        lda     #$08
        sta     $03EE
        php
        pla
        ora     #$40
        pha
        plp
        sec
        jmp     XFER

L083B:  lda     LCBANK1
        lda     LCBANK1
        ldx     L0803
        txs
        rts

        lda     $C082
        jmp     L0D18

L084C:  lda     LCBANK1
        lda     LCBANK1
        ldx     #$10
L0854:  lda     L088D,x
        sta     L0020,x
        dex
        bpl     L0854
        jsr     L0020
        lda     $C082
        lda     #$34
        jsr     L089E
        lda     LCBANK1
        lda     LCBANK1
        bit     L089D
        bmi     L0878
        jsr     UNKNOWN_CALL
        .byte   $0C
        .addr   0
L0878:  lda     #$00
        sta     L089D
        lda     $C082
        jsr     A2D
        .byte   $3C
        .addr   L08D1
        jsr     A2D
        .byte   $04
        .addr   L0C6E
        rts

L088D:  sta     RAMRDOFF
        sta     RAMWRTOFF
        jsr     L4015
        sta     RAMRDON
        sta     RAMWRTON
        rts

L089D:  brk
L089E:  sta     L08D1
        lda     L0CBD
        cmp     #$BF
        bcc     L08AE
        lda     #$80
        sta     L089D
        rts

L08AE:  jsr     A2D
        .byte   $3C
        .addr   L08D1
        jsr     A2D
        .byte   $04
        .addr   L0C6E
        lda     L08D1
        cmp     #$34
        bne     L08C4
        jmp     L12E8

L08C4:  rts

L08C5:  .byte   $00
L08C6:  .byte   $00
L08C7:  .byte   $00,$00,$00
L08CA:  .byte   $00
L08CB:  .byte   $00
L08CC:  .byte   $00
L08CD:  .byte   $00,$00,$00
L08D0:  .byte   $00
L08D1:  .byte   $00,$6E,$0C
L08D4:  .byte   $80
L08D5:  .byte   $00,$0C,$00,$15,$00,$E1,$0A,$03
        .byte   $00,$00,$00,$00,$00,$14,$00,$0C
        .byte   $00,$63,$13,$00,$1F,$00,$0D,$00
        .byte   $16,$00,$1E,$00,$1F,$00,$29,$00
        .byte   $15,$00,$E1,$0A,$03,$00,$00,$00
        .byte   $00,$00,$14,$00,$0C,$00,$65,$30
        .byte   $00,$1F,$00,$2A,$00,$16,$00,$3B
        .byte   $00,$1F,$00,$45,$00,$15,$00,$E1
        .byte   $0A,$03,$00,$00,$00,$00,$00,$14
        .byte   $00,$0C,$00,$3D,$4C,$00,$1F,$00
        .byte   $46,$00,$16,$00,$57,$00,$1F,$00
        .byte   $61,$00,$15,$00,$E1,$0A,$03,$00
        .byte   $00,$00,$00,$00,$14,$00,$0C,$00
        .byte   $2A,$68,$00,$1F,$00,$62,$00,$16
        .byte   $00,$73,$00,$1F,$00,$0C,$00,$25
        .byte   $00,$E1,$0A,$03,$00,$00,$00,$00
        .byte   $00,$14,$00,$0C,$00,$37,$13,$00
        .byte   $2F,$00,$0D,$00,$26,$00,$1E,$00
        .byte   $2F,$00,$29,$00,$25,$00,$E1,$0A
        .byte   $03,$00,$00,$00,$00,$00,$14,$00
        .byte   $0C,$00,$38,$30,$00,$2F,$00,$2A
        .byte   $00,$26,$00,$3B,$00,$2F,$00,$45
        .byte   $00,$25,$00,$E1,$0A,$03,$00,$00
        .byte   $00,$00,$00,$14,$00,$0C,$00,$39
        .byte   $4C,$00,$2F,$00,$46,$00,$26,$00
        .byte   $57,$00,$2F,$00,$61,$00,$25,$00
        .byte   $E1,$0A,$03,$00,$00,$00,$00,$00
        .byte   $14,$00,$0C,$00,$2F,$68,$00,$2F
        .byte   $00,$62,$00,$26,$00,$73,$00,$2F
        .byte   $00,$0C,$00,$34,$00,$E1,$0A,$03
        .byte   $00,$00,$00,$00,$00,$14,$00,$0C
        .byte   $00,$34,$13,$00,$3E,$00,$0D,$00
        .byte   $35,$00,$1E,$00,$3E,$00,$29,$00
        .byte   $34,$00,$E1,$0A,$03,$00,$00,$00
        .byte   $00,$00,$14,$00,$0C,$00,$35,$30
        .byte   $00,$3E,$00,$2A,$00,$35,$00,$3B
        .byte   $00,$3E,$00,$45,$00,$34,$00,$E1
        .byte   $0A,$03,$00,$00,$00,$00,$00,$14
        .byte   $00,$0C,$00,$36,$4C,$00,$3E,$00
        .byte   $46,$00,$35,$00,$57,$00,$3E,$00
        .byte   $61,$00,$34,$00,$E1,$0A,$03,$00
        .byte   $00,$00,$00,$00,$14,$00,$0C,$00
        .byte   $2D,$68,$00,$3E,$00,$62,$00,$35
        .byte   $00,$73,$00,$3E,$00,$0C,$00,$43
        .byte   $00,$E1,$0A,$03,$00,$00,$00,$00
        .byte   $00,$14,$00,$0C,$00,$31,$13,$00
        .byte   $4D,$00,$0D,$00,$44,$00,$1E,$00
        .byte   $4D,$00,$29,$00,$43,$00,$E1,$0A
        .byte   $03,$00,$00,$00,$00,$00,$14,$00
        .byte   $0C,$00,$32,$30,$00,$4D,$00,$2A
        .byte   $00,$44,$00,$3B,$00,$4D,$00,$45
        .byte   $00,$43,$00,$E1,$0A,$03,$00,$00
        .byte   $00,$00,$00,$14,$00,$0C,$00,$33
        .byte   $4C,$00,$4D,$00,$46,$00,$44,$00
        .byte   $57,$00,$4D,$00,$0C,$00,$52,$00
        .byte   $08,$0B,$08,$00,$00,$00,$00,$00
        .byte   $31,$00,$0C,$00,$30,$13,$00,$5C
        .byte   $00,$0D,$00,$53,$00,$3B,$00,$5C
        .byte   $00,$45,$00,$52,$00,$E1,$0A,$03
        .byte   $00,$00,$00,$00,$00,$14,$00,$0C
        .byte   $00,$2E,$4E,$00,$5C,$00,$46,$00
        .byte   $53,$00,$57,$00,$5C,$00,$61,$00
        .byte   $43,$00,$70,$0B,$03,$00,$00,$00
        .byte   $00,$00,$14,$00,$1B,$00,$2B,$68
        .byte   $00,$5C,$00,$62,$00,$44,$00,$73
        .byte   $00,$5C,$00,$00,$00,$00,$40,$7E
        .byte   $7F,$1F,$7E,$7F,$1F,$7E,$7F,$1F
        .byte   $7E,$7F,$1F,$7E,$7F,$1F,$7E,$7F
        .byte   $1F,$7E,$7F,$1F,$7E,$7F,$1F,$7E
        .byte   $7F,$1F,$7E,$7F,$1F,$00,$00,$00
        .byte   $01,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$7F,$7E,$7F,$7F,$7F,$7F
        .byte   $7F,$3F,$7E,$7E,$7F,$7F,$7F,$7F
        .byte   $7F,$3F,$7E,$7E,$7F,$7F,$7F,$7F
        .byte   $7F,$3F,$7E,$7E,$7F,$7F,$7F,$7F
        .byte   $7F,$3F,$7E,$7E,$7F,$7F,$7F,$7F
        .byte   $7F,$3F,$7E,$7E,$7F,$7F,$7F,$7F
        .byte   $7F,$3F,$7E,$7E,$7F,$7F,$7F,$7F
        .byte   $7F,$3F,$7E,$7E,$7F,$7F,$7F,$7F
        .byte   $7F,$3F,$7E,$7E,$7F,$7F,$7F,$7F
        .byte   $7F,$3F,$7E,$7E,$7F,$7F,$7F,$7F
        .byte   $7F,$3F,$7E,$00,$00,$00,$00,$00
        .byte   $00,$00,$7E,$01,$00,$00,$00,$00
        .byte   $00,$00,$7E,$00,$00,$40,$7E,$7F
        .byte   $1F,$7E,$7F,$1F,$7E,$7F,$1F,$7E
        .byte   $7F,$1F,$7E,$7F,$1F,$7E,$7F,$1F
        .byte   $7E,$7F,$1F,$7E,$7F,$1F,$7E,$7F
        .byte   $1F,$7E,$7F,$1F,$7E,$7F,$1F,$7E
        .byte   $7F,$1F,$7E,$7F,$1F,$7E,$7F,$1F
        .byte   $7E,$7F,$1F,$7E,$7F,$1F,$7E,$7F
        .byte   $1F,$7E,$7F,$1F,$7E,$7F,$1F,$7E
        .byte   $7F,$1F,$7E,$7F,$1F,$7E,$7F,$1F
        .byte   $7E,$7F,$1F,$7E,$7F,$1F,$7E,$7F
        .byte   $1F,$00,$00,$00,$01,$00,$00
L0BC4:  .byte   $00
L0BC5:  .byte   $00
L0BC6:  .byte   $00
L0BC7:  .byte   $00
L0BC8:  .byte   $00
L0BC9:  .byte   $00
L0BCA:  .byte   $00
L0BCB:  .byte   $00
L0BCC:  .byte   $01,$00,$00,$00,$81,$00,$60,$00
L0BD4:  .byte   $77,$DD,$77,$DD,$77,$DD,$77,$DD
        .byte   $00
L0BDD:  .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00
L0BE6:  .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .byte   $00
L0BEF:  .byte   $7F
L0BF0:  .byte   $0A,$00,$05,$00,$78,$00,$11,$00
L0BF8:  .byte   $0B,$00,$06,$00,$77,$00,$10,$00
L0C00:  .byte   $03,$0C,$01
L0C03:  .byte   $00
L0C04:  .byte   $07,$0C
L0C06:  .byte   $0F
L0C07:  .byte   $00
L0C08:  .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00
L0C15:  .byte   $00,$00
L0C17:  .byte   $1A,$0C
L0C19:  .byte   $0F
L0C1A:  .byte   $00
L0C1B:  .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00
L0C28:  .byte   $00,$00
L0C2A:  .byte   $2D,$0C,$0A,$20,$20,$20,$20,$20
        .byte   $20,$20,$20,$20,$20
L0C37:  .byte   $3A,$0C,$06,$45,$72,$72,$6F,$72
        .byte   $20
L0C40:  .byte   $07
L0C41:  .byte   $0C,$0F
L0C43:  .byte   $00,$00
L0C45:  .byte   $34
L0C46:  .byte   $00,$00,$10,$00
L0C4A:  .byte   $0F,$00,$10,$00
L0C4E:  .byte   $45,$00,$10,$00,$00,$00,$00,$00
        .byte   $00,$00
L0C58:  .byte   $73
L0C59:  .byte   $00
L0C5A:  .byte   $F7
L0C5B:  .byte   $FF,$68,$0C,$01,$00,$00,$00,$00
        .byte   $00,$06,$00,$05,$00,$41,$35,$47
        .byte   $37,$36,$49
L0C6E:  .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00
L0C93:  .byte   $00,$00,$0D,$00,$00,$20,$80,$00
        .byte   $00,$00,$00,$00,$2F,$02,$B1,$00
L0CA3:  .byte   $00,$01,$02
L0CA6:  .byte   $06
L0CA7:  .byte   $34,$02,$E1,$0C,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$82,$00,$60,$00
        .byte   $82,$00,$60,$00
L0CBB:  .byte   $D2
L0CBC:  .byte   $00
L0CBD:  .byte   $3C
L0CBE:  .byte   $00,$00,$20,$80,$00,$00,$00,$00
        .byte   $00,$82,$00,$60,$00,$FF,$FF,$FF
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$00,$00
        .byte   $00,$00,$00,$01,$01,$00,$7F,$00
        .byte   $88,$00,$00,$04,$43,$61,$6C,$63
L0CE6:  .byte   $00,$00,$02,$00,$06,$00,$0E,$00
        .byte   $1E,$00,$3E,$00,$7E,$00,$1A,$00
        .byte   $30,$00,$30,$00,$60,$00,$00,$00
        .byte   $03,$00,$07,$00,$0F,$00,$1F,$00
        .byte   $3F,$00,$7F,$00,$7F,$01,$7F,$00
        .byte   $78,$00,$78,$00,$70,$01,$70,$01
        .byte   $01,$01
L0D18:  sta     ALTZPON
        lda     LCBANK1
        lda     LCBANK1
        jsr     A2D
        .byte   $1A
        .addr   L08D4
        jsr     A2D
        .byte   $38
        .addr   L0CA7
        jsr     A2D
        .byte   $03
        .addr   L0C6E
        jsr     A2D
        .byte   $04
        .addr   L0C6E
        jsr     A2D
        .byte   $2B
        .addr   0
        lda     #$01
        sta     L08C5
        jsr     A2D
        .byte   $2D
        .addr   L08C5
        jsr     A2D
        .byte   $2A
        .addr   L08C5
        lda     $C082
        jsr     L128E
        lda     #$34
        jsr     L089E
        jsr     L129E
        lda     #$3D
        sta     L0BC6
        lda     #$00
        sta     L0BC5
        sta     L0BC7
        sta     L0BC8
        sta     L0BC9
        sta     L0BCA
        sta     L0BCB
        ldx     #$1C
L0D79:  lda     L13CB,x
        sta     $B0,x
        dex
        bne     L0D79
        lda     #$00
        sta     $D8
        lda     #$AE
        sta     $36
        lda     #$13
        sta     $37
        lda     #$01
        jsr     FLOAT
        ldx     #$52
        ldy     #$0C
        jsr     ROUND
        lda     #$00
        jsr     FLOAT
        jsr     FADD
        jsr     FOUT
        lda     #$07
        jsr     FMULT
        lda     #$00
        jsr     FLOAT
        ldx     #$52
        ldy     #$0C
        jsr     ROUND
        tsx
        stx     L0BC4
        lda     #$3D
        jsr     L0F6A
        lda     #$43
        jsr     L0F6A
        jsr     A2D
        .byte   $24
        .addr   L0CE6
L0DC9:  jsr     A2D
        .byte   $2A
        .addr   L08C5
        lda     L08C5
        cmp     #$01
        bne     L0DDC
        jsr     L0DE6
        jmp     L0DC9

L0DDC:  cmp     #$03
        bne     L0DC9
        jsr     L0E6F
        jmp     L0DC9

L0DE6:  lda     LCBANK1
        lda     LCBANK1
        jsr     A2D
        .byte   $40
        .addr   L08C6
        lda     $C082
        lda     L08CA
        cmp     #$02
        bcc     L0E03
        lda     L08CB
        cmp     #$34
        beq     L0E04
L0E03:  rts

L0E04:  lda     L08CA
        cmp     #$02
        bne     L0E13
        jsr     L0E95
        bcc     L0E03
        jmp     L0F6A

L0E13:  cmp     #$05
        bne     L0E53
        jsr     A2D
        .byte   $43
        .addr   L08D0
        lda     L08D0
        beq     L0E03
L0E22:  lda     LCBANK1
        lda     LCBANK1
        jsr     A2D
        .byte   $39
        .addr   L0C45
        jsr     UNKNOWN_CALL
        .byte   $0C
        .addr   0
        lda     $C082
        jsr     A2D
        .byte   $1A
        .addr   L08D5
        ldx     #$09
L0E3F:  lda     L0E4A,x
        sta     L0020,x
        dex
        bpl     L0E3F
        jmp     L0020

L0E4A:  sta     RAMRDOFF
        sta     RAMWRTOFF
        jmp     L083B

L0E53:  cmp     #$03
        bne     L0E03
        lda     #$34
        sta     L08C5
        lda     LCBANK1
        lda     LCBANK1
        jsr     A2D
        .byte   $44
        .addr   L08C5
        lda     $C082
        jsr     L084C
        rts

L0E6F:  lda     L08C7
        bne     L0E94
        lda     L08C6
        cmp     #$1B
        bne     L0E87
        lda     L0BC5
        bne     L0E85
        lda     L0BCB
        beq     L0E22
L0E85:  lda     #$43
L0E87:  cmp     #$7F
        beq     L0E91
        cmp     #$60
        bcc     L0E91
        and     #$5F
L0E91:  jmp     L0F6A

L0E94:  rts

L0E95:  lda     #$34
        sta     L08C5
        jsr     A2D
        .byte   $46
        .addr   L08C5
        lda     L08CB
        ora     L08CD
        bne     L0E94
        lda     L08CC
        ldx     L08CA
        cmp     #$16
        bcc     L0F22
        cmp     #$22
        bcs     L0EBF
        jsr     L0F38
        bcc     L0F22
        lda     L0F23,x
        rts

L0EBF:  cmp     #$25
        bcc     L0F22
        cmp     #$31
        bcs     L0ED0
        jsr     L0F38
        bcc     L0F22
        lda     L0F27,x
        rts

L0ED0:  cmp     #$34
        bcc     L0F22
        cmp     #$40
        bcs     L0EE1
        jsr     L0F38
        bcc     L0F22
        lda     L0F2B,x
        rts

L0EE1:  cmp     #$43
        bcc     L0F22
        cmp     #$4F
        bcs     L0EF3
        jsr     L0F38
        bcc     L0F22
        sec
        lda     L0F2F,x
        rts

L0EF3:  cmp     #$52
        bcs     L0F06
        lda     L08CA
        cmp     #$61
        bcc     L0F22
        cmp     #$74
        bcs     L0F22
        lda     #$2B
        sec
        rts

L0F06:  cmp     #$5E
        bcs     L0F22
        jsr     L0F38
        bcc     L0F13
        lda     L0F33,x
        rts

L0F13:  lda     L08CA
        cmp     #$0C
        bcc     L0F22
        cmp     #$3D
        bcs     L0F22
        lda     #$30
        sec
        rts

L0F22:  clc
L0F23:  rts

        .byte   $43,$45,$3D
L0F27:  .byte   $2A,$37,$38,$39
L0F2B:  .byte   $2F,$34,$35,$36
L0F2F:  .byte   $2D,$31,$32,$33
L0F33:  .byte   $2B,$30,$30,$2E,$2B
L0F38:  cpx     #$0C
        bcc     L0F68
        cpx     #$20
        bcs     L0F44
        ldx     #$01
        sec
        rts

L0F44:  cpx     #$29
        bcc     L0F68
        cpx     #$3D
        bcs     L0F50
        ldx     #$02
        sec
        rts

L0F50:  cpx     #$45
        bcc     L0F68
        cpx     #$59
        bcs     L0F5C
        ldx     #$03
        sec
        rts

L0F5C:  cpx     #$61
        bcc     L0F68
        cpx     #$74
        bcs     L0F68
        ldx     #$04
        sec
        rts

L0F68:  clc
        rts

L0F6A:  cmp     #$43
        bne     L0F9C
        ldx     #$EB
        ldy     #$08
        lda     #$63
        jsr     L120A
        lda     #$00
        jsr     FLOAT
        ldx     #$52
        ldy     #$0C
        jsr     ROUND
        lda     #$3D
        sta     L0BC6
        lda     #$00
        sta     L0BC5
        sta     L0BCB
        sta     L0BC7
        sta     L0BC8
        sta     L0BC9
        jmp     L129E

L0F9C:  cmp     #$45
        bne     L0FC7
        ldx     #$08
        ldy     #$09
        lda     #$65
        jsr     L120A
        ldy     L0BC8
        bne     L0FC6
        ldy     L0BCB
        bne     L0FBE
        inc     L0BCB
        lda     #$31
        sta     L0C15
        sta     L0C28
L0FBE:  lda     #$45
        sta     L0BC8
        jmp     L1107

L0FC6:  rts

L0FC7:  cmp     #$3D
        bne     L0FD3
        pha
        ldx     #$25
        ldy     #$09
        jmp     L114C

L0FD3:  cmp     #$2A
        bne     L0FDF
        pha
        ldx     #$42
        ldy     #$09
        jmp     L114C

L0FDF:  cmp     #$2E
        bne     L1003
        ldx     #$BB
        ldy     #$0A
        jsr     L120A
        lda     L0BC7
        ora     L0BC8
        bne     L1002
        lda     L0BCB
        bne     L0FFA
        inc     L0BCB
L0FFA:  lda     #$2E
        sta     L0BC7
        jmp     L1107

L1002:  rts

L1003:  cmp     #$2B
        bne     L100F
        pha
        ldx     #$D8
        ldy     #$0A
        jmp     L114C

L100F:  cmp     #$2D
        bne     L1030
        pha
        ldx     #$2A
        ldy     #$0A
        lda     L0BC8
        beq     L102B
        lda     L0BC9
        bne     L102B
        sec
        ror     L0BC9
        pla
        pha
        jmp     L10FF

L102B:  pla
        pha
        jmp     L114C

L1030:  cmp     #$2F
        bne     L103C
        pha
        ldx     #$B6
        ldy     #$09
        jmp     L114C

L103C:  cmp     #$30
        bne     L1048
        pha
        ldx     #$9E
        ldy     #$0A
        jmp     L10FF

L1048:  cmp     #$31
        bne     L1054
        pha
        ldx     #$47
        ldy     #$0A
        jmp     L10FF

L1054:  cmp     #$32
        bne     L1060
        pha
        ldx     #$64
        ldy     #$0A
        jmp     L10FF

L1060:  cmp     #$33
        bne     L106C
        pha
        ldx     #$81
        ldy     #$0A
        jmp     L10FF

L106C:  cmp     #$34
        bne     L1078
        pha
        ldx     #$D3
        ldy     #$09
        jmp     L10FF

L1078:  cmp     #$35
        bne     L1084
        pha
        ldx     #$F0
        ldy     #$09
        jmp     L10FF

L1084:  cmp     #$36
        bne     L1090
        pha
        ldx     #$0D
        ldy     #$0A
        jmp     L10FF

L1090:  cmp     #$37
        bne     L109C
        pha
        ldx     #$5F
        ldy     #$09
        jmp     L10FF

L109C:  cmp     #$38
        bne     L10A8
        pha
        ldx     #$7C
        ldy     #$09
        jmp     L10FF

L10A8:  cmp     #$39
        bne     L10B4
        pha
        ldx     #$99
        ldy     #$09
        jmp     L10FF

L10B4:  cmp     #$7F
        bne     L10FE
        ldy     L0BCB
        beq     L10FE
        cpy     #$01
        bne     L10C7
        jsr     L11F5
        jmp     L12A4

L10C7:  dec     L0BCB
        ldx     #$00
        lda     L0C15
        cmp     #$2E
        bne     L10D6
        stx     L0BC7
L10D6:  cmp     #$45
        bne     L10DD
        stx     L0BC8
L10DD:  cmp     #$2D
        bne     L10E4
        stx     L0BC9
L10E4:  ldx     #$0D
L10E6:  lda     L0C07,x
        sta     L0C08,x
        sta     L0C1B,x
        dex
        dey
        bne     L10E6
        lda     #$20
        sta     L0C08,x
        sta     L0C1B,x
        jmp     L12A4

L10FE:  rts

L10FF:  jsr     L120A
        bne     L1106
        pla
        rts

L1106:  pla
L1107:  sec
        ror     L0BCA
        ldy     L0BCB
        bne     L111C
        pha
        jsr     L128E
        pla
        cmp     #$30
        bne     L111C
        jmp     L12A4

L111C:  sec
        ror     L0BC5
        cpy     #$0A
        bcs     L114B
        pha
        ldy     L0BCB
        beq     L113E
        lda     #$0F
        sec
        sbc     L0BCB
        tax
L1131:  lda     L0C07,x
        sta     L0C06,x
        sta     L0C19,x
        inx
        dey
        bne     L1131
L113E:  inc     L0BCB
        pla
        sta     L0C15
        sta     L0C28
        jmp     L12A4

L114B:  rts

L114C:  jsr     L120A
        bne     L1153
        pla
        rts

L1153:  lda     L0BC6
        cmp     #$3D
        bne     L1167
        lda     L0BCA
        bne     L1173
        lda     #$00
        jsr     FLOAT
        jmp     L1181

L1167:  lda     L0BCA
        bne     L1173
        pla
        sta     L0BC6
        jmp     L11F5

L1173:  lda     #$07
        sta     $B8
        lda     #$0C
        sta     $B9
        jsr     L00B1
        jsr     FIN
L1181:  pla
        ldx     L0BC6
        sta     L0BC6
        lda     #$52
        ldy     #$0C
        cpx     #$2B
        bne     L1196
        jsr     FADD
        jmp     L11C0

L1196:  cpx     #$2D
        bne     L11A0
        jsr     FSUB
        jmp     L11C0

L11A0:  cpx     #$2A
        bne     L11AA
        jsr     FMULT
        jmp     L11C0

L11AA:  cpx     #$2F
        bne     L11B4
        jsr     FDIV
        jmp     L11C0

L11B4:  cpx     #$3D
        bne     L11C0
        ldy     L0BCA
        bne     L11C0
        jmp     L11F5

L11C0:  ldx     #$52
        ldy     #$0C
        jsr     ROUND
        jsr     FOUT
        ldy     #$00
L11CC:  lda     $0100,y
        beq     L11D4
        iny
        bne     L11CC
L11D4:  ldx     #$0E
L11D6:  lda     $FF,y
        sta     L0C07,x
        sta     L0C1A,x
        dex
        dey
        bne     L11D6
        cpx     #$00
        bmi     L11F2
L11E7:  lda     #$20
        sta     L0C07,x
        sta     L0C1A,x
        dex
        bpl     L11E7
L11F2:  jsr     L12A4
L11F5:  jsr     L127E
        lda     #$00
        sta     L0BCB
        sta     L0BC7
        sta     L0BC8
        sta     L0BC9
        sta     L0BCA
        rts

L120A:  stx     L122F
        stx     L1253
        stx     L1273
        sty     L122F+1
        sty     L1253+1
        sty     L1273+1
        jsr     A2D
        .byte   $08
        .addr   L0BDD
        jsr     A2D
        .byte   $07
        .addr   L0CA6
        sec
        ror     $FC
L122B:  jsr     A2D
        .byte   $11
L122F:  .addr   0
L1231:  jsr     A2D
        .byte   $2A
        .addr   L08C5
        lda     L08C5
        cmp     #$04
        bne     L126B
        lda     #$34
        sta     L08C5
        jsr     A2D
        .byte   $46
        .addr   L08C5
        jsr     A2D
        .byte   $0E
        .addr   L08CA
        jsr     A2D
        .byte   $13
L1253:  .addr   0
        bne     L1261
        lda     $FC
        beq     L1231
        lda     #$00
        sta     $FC
        beq     L122B
L1261:  lda     $FC
        bne     L1231
        sec
        ror     $FC
        jmp     L122B

L126B:  lda     $FC
        beq     L1275
        jsr     A2D
        .byte   $11
L1273:  .addr   0
L1275:  jsr     A2D
        .byte   $07
        .addr   L0CA3
        lda     $FC
        rts

L127E:  ldy     #$0E
L1280:  lda     #$20
        sta     L0C06,y
        dey
        bne     L1280
        lda     #$30
        sta     L0C15
        rts

L128E:  ldy     #$0E
L1290:  lda     #$20
        sta     L0C19,y
        dey
        bne     L1290
        lda     #$30
        sta     L0C28
        rts

L129E:  jsr     L127E
        jsr     L128E
L12A4:  ldx     #$07
        ldy     #$0C
        jsr     L12C0
        jsr     A2D
        .byte   $19
        .addr   L0C04
        rts

L12B2:  ldx     #$1A
        ldy     #$0C
        jsr     L12C0
        jsr     A2D
        .byte   $19
        .addr   L0C17
        rts

L12C0:  stx     L0C40
        sty     L0C41
        jsr     A2D
        .byte   $18
        .addr   L0C40
        lda     #$69
        sec
        sbc     L0C43
        sta     L0C46
        jsr     A2D
        .byte   $0E
        .addr   L0C4A
        jsr     A2D
        .byte   $19
        .addr   L0C2A
        jsr     A2D
        .byte   $0E
        .addr   L0C46
        rts

L12E8:  jsr     A2D
        .byte   $26
        .addr   0
        jsr     A2D
        .byte   $08
        .addr   L0BD4
        jsr     A2D
        .byte   $11
        .addr   L0BCC
        jsr     A2D
        .byte   $08
        .addr   L0BDD
        jsr     A2D
        .byte   $12
        .addr   L0BF0
        jsr     A2D
        .byte   $08
        .addr   L0BE6
        jsr     A2D
        .byte   $11
        .addr   L0BF8
        jsr     A2D
        .byte   $0C
        .addr   L0BEF
        lda     #$D6
        sta     $FA
        lda     #$08
        sta     $FB
L1320:  ldy     #$00
        lda     ($FA),y
        beq     L1363
        lda     $FA
        sta     L1347
        ldy     $FB
        sty     L1347+1
        clc
        adc     #$11
        sta     L134D
        bcc     L1339
        iny
L1339:  sty     L134D+1
        ldy     #$10
        lda     ($FA),y
        sta     L0C03
        jsr     A2D
        .byte   $14
L1347:  .addr   0
        jsr     A2D
        .byte   $0E
L134D:  .addr   0
        jsr     A2D
        .byte   $19
        .addr   L0C00
        lda     $FA
        clc
        adc     #$1D
        sta     $FA
        bcc     L1320
        inc     $FB
        jmp     L1320

L1363:  ldx     L0CBC
        lda     L0CBB
        clc
        adc     #$73
        sta     L0C58
        bcc     L1372
        inx
L1372:  stx     L0C59
        ldx     L0CBE
        lda     L0CBD
        sec
        sbc     #$16
        sta     L0C5A
        bcs     L1384
        dex
L1384:  stx     L0C5B
        jsr     A2D
        .byte   $06
        .addr   L0C93
        jsr     A2D
        .byte   $14
        .addr   L0C58
        lda     #$34
        sta     L08D1
        jsr     A2D
        .byte   $3C
        .addr   L08D1
        jsr     A2D
        .byte   $04
        .addr   L0C6E
        jsr     A2D
        .byte   $25
        .addr   0
        jsr     L12B2
        rts

        jsr     L129E
        jsr     A2D
        .byte   $0E
        .addr   L0C4E
        jsr     A2D
        .byte   $19
        .addr   L0C37
        jsr     L11F5
        lda     #$3D
        sta     L0BC6
        ldx     L0BC4
        txs
L13CB           := * + 2
        jmp     L0DC9

L13CC:  inc     $B8
        bne     L13D2
        inc     $B9
L13D2:  lda     $EA60
        cmp     #$3A
        bcs     L13E3
        cmp     #$20
        beq     L13CC
        sec
        sbc     #$30
        sec
        sbc     #$D0
L13E3:  rts