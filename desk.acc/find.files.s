        .setcpu "6502"

        .include "apple2.inc"
        .include "../inc/apple2.inc"
        .include "../mgtk.inc"
        .include "../desktop.inc"
        .include "../macros.inc"

;;; ============================================================

        .org $800

        ;; Desktop Resources
        pointer_cursor                 := $D2AD
        insertion_point_cursor         := $D2DF

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
        jsr     init

        ;; tear down/exit
        sta     ALTZPON
        lda     LCBANK1
        lda     LCBANK1

        ;; back to main for exit
        sta     RAMRDOFF
        sta     RAMWRTOFF
        rts
.endscope

;;; ============================================================

da_window_id    := 63
da_width        := 460
da_height       := 144
da_left         := (screen_width - da_width)/2
da_top          := (screen_height - da_height)/2

str_title:
        PASCAL_STRING "Eyes"

;;; TODO: Allow resizing

.proc winfo
window_id:      .byte   da_window_id
options:        .byte   MGTK::option_dialog_box
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
screen: DEFINE_POINT 0, 0, screen
window: DEFINE_POINT 0, 0, window
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

frame_rect1:    DEFINE_RECT 4, 2, da_width-4, da_height-2
frame_rect2:    DEFINE_RECT 5, 3, da_width-5, da_height-3

find_label_textpos: DEFINE_POINT 16, 20
find_label:         DEFINE_STRING "Find:"
input_rect:         DEFINE_RECT 50, 10, da_width-250, 21
input_textpos:      DEFINE_POINT 12, 20

ok_button_rect:    DEFINE_RECT da_width-235, 10, da_width-135, 21
ok_button_textpos: DEFINE_POINT da_width-235+5, 20
ok_button_label:   DEFINE_STRING {"Search         ",GLYPH_RETURN}

cancel_button_rect:    DEFINE_RECT da_width-120, 10, da_width-20, 21
cancel_button_textpos: DEFINE_POINT da_width-120+5, 20
cancel_button_label:   DEFINE_STRING "Cancel        Esc"

penxor: .byte   MGTK::penXOR

cursor_ip_flag: .byte   0


;;; ============================================================

.proc init
        sta     ALTZPON
        lda     LCBANK1
        lda     LCBANK1


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
        cmp     #MGTK::event_kind_no_event
        beq     handle_no_event

        ;; TODO: Blink IP

        jmp     input_loop
.endproc

.proc exit
        MGTK_CALL MGTK::SetCursor, pointer_cursor

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
        jmp     input_loop
.endproc

;;; ============================================================

.proc handle_no_event
        copy16  event_params::xcoord, screentowindow_params::screen::xcoord
        copy16  event_params::ycoord, screentowindow_params::screen::ycoord
        MGTK_CALL MGTK::ScreenToWindow, screentowindow_params

        MGTK_CALL MGTK::MoveTo, screentowindow_params::window
        MGTK_CALL MGTK::InRect, input_rect
        cmp     #MGTK::inrect_inside
        beq     inside

outside:
        bit     cursor_ip_flag
        bpl     done
        lda     #0
        sta     cursor_ip_flag
        MGTK_CALL MGTK::SetCursor, pointer_cursor
        jmp     done

inside:
        bit     cursor_ip_flag
        bmi     done
        lda     #$FF
        sta     cursor_ip_flag
        MGTK_CALL MGTK::SetCursor, insertion_point_cursor

done:   jmp     input_loop
.endproc

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

        MGTK_CALL MGTK::SetPenMode, penxor
        MGTK_CALL MGTK::FrameRect, frame_rect1
        MGTK_CALL MGTK::FrameRect, frame_rect2

        MGTK_CALL MGTK::MoveTo, find_label_textpos
        MGTK_CALL MGTK::DrawText, find_label
        MGTK_CALL MGTK::FrameRect, input_rect

        MGTK_CALL MGTK::FrameRect, ok_button_rect
        MGTK_CALL MGTK::MoveTo, ok_button_textpos
        MGTK_CALL MGTK::DrawText, ok_button_label

        MGTK_CALL MGTK::FrameRect, cancel_button_rect
        MGTK_CALL MGTK::MoveTo, cancel_button_textpos
        MGTK_CALL MGTK::DrawText, cancel_button_label

        MGTK_CALL MGTK::ShowCursor
done:   rts

tmpw:   .word   0
.endproc


;;; ============================================================

da_end  = *
.assert * < $1B00, error, "DA too big"
        ;; I/O Buffer starts at MAIN $1C00
        ;; ... but icon tables start at AUX $1B00
