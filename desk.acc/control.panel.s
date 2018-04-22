        .setcpu "6502"

        .include "apple2.inc"
        .include "../inc/apple2.inc"
        .include "../inc/prodos.inc"
        .include "../mgtk.inc"
        .include "../desktop.inc"
        .include "../macros.inc"

;;; ============================================================

        .org $800

entry:

;;; Copy the DA to AUX for easy bank switching
.scope
        lda     ROMIN2
        copy16  #$0800, STARTLO
        copy16  #da_end, ENDLO
        copy16  #$0800, DESTINATIONLO
        sec                     ; main>aux
        jsr     AUXMOVE
        lda     LCBANK1
        lda     LCBANK1
.endscope

.scope
        ;; run the DA
        sta     RAMRDON
        sta     RAMWRTON
        sta     ALTZPON
        lda     LCBANK1
        lda     LCBANK1
        jsr     init

        ;; tear down/exit
        sta     ALTZPON
        lda     LCBANK1
        lda     LCBANK1
        sta     RAMRDOFF
        sta     RAMWRTOFF
        rts
.endscope

;;; ============================================================

screen_width    := 560
screen_height   := 192

da_window_id    := 61
da_width        := 300
da_height       := 70
da_left         := (screen_width - da_width)/2
da_top          := (screen_height - da_height - 8)/2

str_title:
        PASCAL_STRING "Control Panel"

.proc winfo
window_id:      .byte   da_window_id
options:        .byte   MGTK::option_go_away_box
title:          .addr   str_title
hscroll:        .byte   MGTK::scroll_option_none
vscroll:        .byte   MGTK::scroll_option_none
hthumbmax:      .byte   32
hthumbpos:      .byte   0
vthumbmax:      .byte   32
vthumbpos:      .byte   0
status:         .byte   0
reserved:       .byte   0
mincontwidth:   .word   da_width
mincontlength:  .word   da_height
maxcontwidth:   .word   da_width
maxcontlength:  .word   da_height
port:
viewloc:        DEFINE_POINT da_left, da_top
mapbits:        .addr   MGTK::screen_mapbits
mapwidth:       .word   MGTK::screen_mapwidth
maprect:        DEFINE_RECT 0, 0, da_width, da_height, maprect
pattern:        .res    8, $FF
colormasks:     .byte   MGTK::colormask_and, MGTK::colormask_or
penloc:          DEFINE_POINT 0, 0
penwidth:       .byte   1
penheight:      .byte   1
penmode:        .byte   0
textback:       .byte   $7F
textfont:       .addr   DEFAULT_FONT
nextwinfo:      .addr   0
.endproc

;;; ============================================================


.proc event_params
kind:  .byte   0
;;; event_kind_key_down
key             := *
modifiers       := * + 1
;;; event_kind_update
window_id       := *
;;; otherwise
xcoord          := *
ycoord          := * + 2
        .res    4
.endproc

.proc findwindow_params
mousex:         .word   0
mousey:         .word   0
which_area:     .byte   0
window_id:      .byte   0
.endproc

.proc trackgoaway_params
clicked:        .byte   0
.endproc

.proc dragwindow_params
window_id:      .byte   0
dragx:          .word   0
dragy:          .word   0
moved:          .byte   0
.endproc

.proc winport_params
window_id:      .byte   da_window_id
port:           .addr   grafport
.endproc


.proc screentowindow_params
window_id:      .byte   da_window_id
        DEFINE_POINT 0, 0, screen
        DEFINE_POINT 0, 0, window
.endproc
        mx := screentowindow_params::window::xcoord
        my := screentowindow_params::window::ycoord

.proc grafport
viewloc:        DEFINE_POINT 0, 0
mapbits:        .word   0
mapwidth:       .word   0
cliprect:       DEFINE_RECT 0, 0, 0, 0
pattern:        .res    8, 0
colormasks:     .byte   0, 0
penloc:         DEFINE_POINT 0, 0
penwidth:       .byte   0
penheight:      .byte   0
penmode:        .byte   0
textback:       .byte   0
textfont:       .addr   0
.endproc


;;; ============================================================

.proc init
        MGTK_CALL MGTK::OpenWindow, winfo
        jsr     draw_window
        MGTK_CALL MGTK::FlushEvents
        ;; fall through
.endproc

.proc input_loop
        MGTK_CALL MGTK::GetEvent, event_params
        bne     exit
        lda     event_params::kind
        cmp     #MGTK::event_kind_button_down
        beq     handle_down
        cmp     #MGTK::event_kind_key_down
        beq     handle_key
        jmp     input_loop
.endproc

.proc exit
        MGTK_CALL MGTK::CloseWindow, winfo
        DESKTOP_CALL DT_REDRAW_ICONS
        rts
.endproc

;;; ============================================================

.proc handle_key
        lda     event_params::key
        cmp     #CHAR_ESCAPE
        beq     exit
        bne     input_loop
.endproc

;;; ============================================================

.proc handle_down
        copy16  event_params::xcoord, findwindow_params::mousex
        copy16  event_params::ycoord, findwindow_params::mousey
        MGTK_CALL MGTK::FindWindow, findwindow_params
        bne     exit
        lda     findwindow_params::window_id
        cmp     winfo::window_id
        bne     input_loop
        lda     findwindow_params::which_area
        cmp     #MGTK::area_close_box
        beq     handle_close
        cmp     #MGTK::area_dragbar
        beq     handle_drag
        cmp     #MGTK::area_content
        beq     handle_click
        jmp     input_loop
.endproc

;;; ============================================================

.proc handle_close
        MGTK_CALL MGTK::TrackGoAway, trackgoaway_params
        lda     trackgoaway_params::clicked
        beq     input_loop
        bne     exit
.endproc

;;; ============================================================

.proc handle_drag
        copy    winfo::window_id, dragwindow_params::window_id
        copy16  event_params::xcoord, dragwindow_params::dragx
        copy16  event_params::ycoord, dragwindow_params::dragy
        MGTK_CALL MGTK::DragWindow, dragwindow_params
common: lda     dragwindow_params::moved
        bpl     :+

        ;; Draw DeskTop's windows
        sta     RAMRDOFF
        sta     RAMWRTOFF
        jsr     JUMP_TABLE_REDRAW_ALL
        sta     RAMRDON
        sta     RAMWRTON

        ;; Draw DA's window
        jsr     draw_window

        ;; Draw DeskTop icons
        DESKTOP_CALL DT_REDRAW_ICONS

:       jmp     input_loop

.endproc

;;; ============================================================

fatbit_w := 8
fatbit_ws := 3                  ; shift
fatbit_h := 4
fatbit_hs := 2                  ; shift
fatbits_rect:
        DEFINE_RECT 20, 15, 20 + 8 * fatbit_w + 1, 15 + 8 * fatbit_h + 1, fatbits_rect

;;; ============================================================



.proc handle_click
moved:  copy16  event_params::xcoord, screentowindow_params::screen::xcoord
        copy16  event_params::ycoord, screentowindow_params::screen::ycoord
        MGTK_CALL MGTK::ScreenToWindow, screentowindow_params

        dec16   mx
        cmp16   mx, fatbits_rect::x1
        bcc     bail
        dec16   my
        cmp16   my, fatbits_rect::y1
        bcs     continue
bail:   jmp     done

continue:
        sub16   mx, fatbits_rect::x1, mx
        sub16   my, fatbits_rect::y1, my

        ldy     #fatbit_ws
:       lsr16   mx
        dey
        bne     :-
        cmp16   mx, #8
        bcs     done

        ldy     #fatbit_hs
:       lsr16   my
        dey
        bne     :-
        cmp16   my, #8
        bcs     done

        ldx     mx
        ldy     my
        lda     pattern,y
        eor     mask,x
        sta     pattern,y

        MGTK_CALL MGTK::GetWinPort, winport_params
        MGTK_CALL MGTK::SetPort, grafport
        MGTK_CALL MGTK::HideCursor
        jsr     draw_bits
        MGTK_CALL MGTK::ShowCursor

done:   jmp     input_loop

mask:   .byte   1<<0, 1<<1, 1<<2, 1<<3, 1<<4, 1<<5, 1<<6, 1<<7

.endproc

;;; ============================================================

penXOR:         .byte   MGTK::penXOR
pencopy:        .byte   MGTK::pencopy
penBIC:         .byte   MGTK::penBIC
notpencopy:     .byte   MGTK::notpencopy

pattern:
        .byte   %01010101
        .byte   %10101010
        .byte   %01010101
        .byte   %10101010
        .byte   %01010101
        .byte   %10101010
        .byte   %01010101
        .byte   %10101010

black_pattern:
        .byte   %00000000
        .byte   %00000000
        .byte   %00000000
        .byte   %00000000
        .byte   %00000000
        .byte   %00000000
        .byte   %00000000
        .byte   %00000000


preview_l       := 99
preview_t       := 15
preview_r       := 180
preview_b       := 48
preview_s       := 21

preview_rect:
        DEFINE_RECT preview_l+1, preview_s + 1, preview_r - 1, preview_b - 1

preview_line:
        DEFINE_RECT preview_l, preview_s, preview_r, preview_s

preview_frame:
        DEFINE_RECT preview_l, preview_t, preview_r, preview_b

        arr_w := 6
        arr_h := 5
        arr_inset := 5

.proc rarr_params
viewloc:        DEFINE_POINT preview_r - arr_inset - arr_w, preview_t+1
mapbits:        .addr   rarr_bitmap
mapwidth:       .byte   1
reserved:       .byte   0
cliprect:       DEFINE_RECT 0, 0, arr_w-1, arr_h-1
.endproc

rarr_bitmap:
        .byte   px(%1100000)
        .byte   px(%1111000)
        .byte   px(%1111110)
        .byte   px(%1111000)
        .byte   px(%1100000)

.proc larr_params
viewloc:        DEFINE_POINT preview_l + arr_inset + 1, preview_t+1
mapbits:        .addr   larr_bitmap
mapwidth:       .byte   1
reserved:       .byte   0
cliprect:       DEFINE_RECT 0, 0, arr_w-1, arr_h-1
.endproc

larr_bitmap:
        .byte   px(%0000110)
        .byte   px(%0011110)
        .byte   px(%1111110)
        .byte   px(%0011110)
        .byte   px(%0000110)

;;; ============================================================

.proc draw_window
        ;; Defer if content area is not visible
        MGTK_CALL MGTK::GetWinPort, winport_params
        cmp     #MGTK::error_window_obscured
        bne     :+
        rts
:
        MGTK_CALL MGTK::SetPort, grafport
        MGTK_CALL MGTK::HideCursor

        MGTK_CALL MGTK::SetPenMode, penBIC
        MGTK_CALL MGTK::FrameRect, fatbits_rect
        MGTK_CALL MGTK::PaintBits, larr_params
        MGTK_CALL MGTK::PaintBits, rarr_params

        MGTK_CALL MGTK::SetPenMode, penXOR
        MGTK_CALL MGTK::FrameRect, preview_frame

        MGTK_CALL MGTK::SetPenMode, penBIC
        MGTK_CALL MGTK::FrameRect, preview_line

        jsr     draw_bits

done:   MGTK_CALL MGTK::ShowCursor
        rts

.endproc

bitpos:    DEFINE_POINT    0, 0, bitpos

.proc draw_bits
        MGTK_CALL MGTK::SetPenMode, pencopy
        MGTK_CALL MGTK::SetPattern, pattern
        MGTK_CALL MGTK::PaintRect, preview_rect

        MGTK_CALL MGTK::SetPattern, winfo::pattern
        MGTK_CALL MGTK::SetPenSize, size

        copy    #0, ypos
        add16   fatbits_rect::y1, #1, bitpos::ycoord

yloop:  copy    #0, xpos
        add16   fatbits_rect::x1, #1, bitpos::xcoord
        ldy     ypos
        lda     pattern, y
        sta     row

xloop:  ror     row
        bcc     zero
        lda     #MGTK::pencopy
        bpl     store
zero:   lda     #MGTK::notpencopy
store:  sta     mode

        MGTK_CALL MGTK::SetPenMode, mode
        MGTK_CALL MGTK::MoveTo, bitpos
        MGTK_CALL MGTK::LineTo, bitpos

next_x: inc     xpos
        lda     xpos
        cmp     #8
        beq     next_y

        add16   bitpos::xcoord, #fatbit_w, bitpos::xcoord
        jmp     xloop

next_y: inc     ypos
        lda     ypos
        cmp     #8
        beq     done

        add16   bitpos::ycoord, #fatbit_h, bitpos::ycoord
        jmp     yloop

done:   rts

xpos:   .byte   0
ypos:   .byte   0
row:    .byte   0

mode:   .byte   0
size:   .byte fatbit_w, fatbit_h

.endproc


;;; ============================================================

da_end  = *
.assert * < $1B00, error, "DA too big"
        ;; I/O Buffer starts at MAIN $1C00
        ;; ... but icon tables start at AUX $1B00
