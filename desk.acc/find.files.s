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

results_window_id    := da_window_id+1
results_width        := da_width - 60
results_width_sb     := results_width + 20
results_height       := da_height - 40
results_left         := da_left + (da_width - results_width_sb) / 2
results_top          := da_top + 30

str_title:
        PASCAL_STRING "Find Files"

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

.proc winfo_results
window_id:      .byte   results_window_id
options:        .byte   MGTK::option_dialog_box
title:          .addr   0
hscroll:        .byte   MGTK::scroll_option_none
vscroll:        .byte   MGTK::scroll_option_normal
hthumbmax:      .byte   0
hthumbpos:      .byte   0
vthumbmax:      .byte   255
vthumbpos:      .byte   0
status:         .byte   0
reserved:       .byte   0
mincontwidth:   .word   results_width
mincontlength:  .word   results_height
maxcontwidth:   .word   results_width
maxcontlength:  .word   results_height * 2 ; TODO: increase
port:
viewloc:        DEFINE_POINT results_left, results_top
mapbits:        .addr   MGTK::screen_mapbits
mapwidth:       .word   MGTK::screen_mapwidth
cliprect:       DEFINE_RECT 0, 0, results_width, results_height
penpattern:     .res    8, $FF
colormasks:     .byte   MGTK::colormask_and, MGTK::colormask_or
penloc:         DEFINE_POINT 0, 0
penwidth:       .byte   1
penheight:      .byte   1
penmode:        .byte   0
textbg:         .byte   MGTK::textbg_white
fontptr:        .addr   DEFAULT_FONT
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

.proc findcontrol_params
mousex:         .word   0
mousey:         .word   0
which_ctl:      .byte   0
which_part:     .byte   0
.endproc

.proc trackthumb_params
which_ctl:      .byte   MGTK::ctl_vertical_scroll_bar
mousex:         .word   0
mousey:         .word   0
thumbpos:       .byte   0
thumbmoved:     .byte   0
.endproc

.proc updatethumb_params
which_ctl:      .byte   MGTK::ctl_vertical_scroll_bar
thumbpos:       .byte   0
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
find_label:         PASCAL_STRING "Find:"
input_rect:         DEFINE_RECT 50, 10, da_width-250, 21
input_textpos:      DEFINE_POINT 55, 20

        ;; figure out coords here
.proc input_mapinfo
        DEFINE_POINT 75, 35
        .addr   MGTK::screen_mapbits
        .byte   MGTK::screen_mapwidth
        .byte   0
        DEFINE_RECT 0, 0, 358, 100
.endproc



search_button_rect:    DEFINE_RECT da_width-235, 10, da_width-135, 21
search_button_textpos: DEFINE_POINT da_width-235+5, 20
search_button_label:   PASCAL_STRING {"Search         ",GLYPH_RETURN}

cancel_button_rect:    DEFINE_RECT da_width-120, 10, da_width-20, 21
cancel_button_textpos: DEFINE_POINT da_width-120+5, 20
cancel_button_label:   PASCAL_STRING "Cancel        Esc"

penxor: .byte   MGTK::penXOR

cursor_ip_flag: .byte   0

buf_left:       .res    17, 0   ; input text before IP
buf_right:      .res    17, 0   ; input text at/after IP
buf_search:     .res    17, 0   ; search term

suffix: PASCAL_STRING "  "

ip_blink_counter:       .byte   0
ip_blink_flag:          .byte   0

;;; ============================================================

.proc init
        sta     ALTZPON
        lda     LCBANK1
        lda     LCBANK1

        ;; Prep input string
        lda     #0
        sta     buf_left

        lda     #1
        sta     buf_right
        lda     GLYPH_INSPT
        sta     buf_right+1

        lda     #0
        sta     ip_blink_flag
        lda     machine_speed
        sta     ip_blink_counter

        MGTK_CALL MGTK::OpenWindow, winfo
        MGTK_CALL MGTK::OpenWindow, winfo_results
        jsr     draw_window
        jsr     draw_input_text
        MGTK_CALL MGTK::FlushEvents
        ;; fall through
.endproc

.proc input_loop
        jsr     blink_ip
        MGTK_CALL MGTK::GetEvent, event_params
        bne     exit
        lda     event_params::kind
        cmp     #MGTK::event_kind_button_down
        bne     :+
        jmp     handle_down
:       cmp     #MGTK::event_kind_key_down
        bne     :+
        jmp     handle_key
:       cmp     #MGTK::event_kind_no_event
        bne     :+
        jmp     handle_no_event
:       jmp     input_loop
.endproc

.proc exit
        MGTK_CALL MGTK::SetCursor, pointer_cursor

        MGTK_CALL MGTK::CloseWindow, winfo_results
        MGTK_CALL MGTK::CloseWindow, winfo
        DESKTOP_CALL DT_REDRAW_ICONS
        rts
.endproc

;;; ============================================================

.proc blink_ip
        dec     ip_blink_counter
        bne     done
        lda     machine_speed
        sta     ip_blink_counter

        bit     ip_blink_flag
        bmi     clear

set:    lda     #$FF
        sta     ip_blink_flag
        lda     #GLYPH_SPC
        sta     buf_right+1
        jsr     draw_input_text
        rts


clear:  lda     #0
        sta     ip_blink_flag
        lda     #GLYPH_INSPT
        sta     buf_right+1
        jsr     draw_input_text

done:   rts
.endproc

;;; ============================================================

.proc handle_key
        lda     event_params::key
        cmp     #CHAR_ESCAPE
        beq     exit

        ;;         cmp #CHAR_ENTER
        ;;         beq do_search
        cmp     #CHAR_LEFT
        bne     :+
        jmp     do_left
:       cmp     #CHAR_RIGHT
        bne     :+
        jmp     do_right
:       cmp     #CHAR_DELETE
        bne     :+
        jmp     do_delete

        ;; Valid characters are . 0-9 A-Z a-z
:       cmp     #'.'
        beq     do_char
        cmp     #'0'
        bcc     ignore_char
        cmp     #'9'+1
        bcc     do_char
        cmp     #'A'
        bcc     ignore_char
        cmp     #'Z'+1
        bcc     do_char
        cmp     #'a'
        bcc     ignore_char
        cmp     #'z'+1
        bcc     do_char
        ;; fall through
.endproc

ignore_char:
        ;;         jsr     beep ; ?
        jmp     input_loop

;;; ; ------------------------------------------------------------

.proc do_char
        ;; check length
        tax
        clc
        lda     buf_left
        adc     buf_right
        cmp     #17             ; max length is 15, plus ip
        bcs     ignore_char

        ;; append char
        txa
        ldx     buf_left
        inx
        sta     buf_left,x
        stx     buf_left
        jsr     draw_input_text
        jmp     input_loop
.endproc

;;; ; ------------------------------------------------------------


.proc do_left
        lda     buf_left            ; length of string to left of IP
        beq     done

        ;; shift right string up one (apart from IP)
        ldx     buf_right
        ldy     buf_right
        iny
:       cpx     #1
        beq     :+
        lda     buf_right,x
        sta     buf_right,y
        dex
        dey
        bne     :-              ; always

        ;; move char from end of left string to just after IP in right string
:       ldx     buf_left
        lda     buf_left,x
        sta     buf_right+2

        ;; adjust lengths
        dec     buf_left
        inc     buf_right

        jsr     draw_input_text

done:   jmp     input_loop
.endproc

;;; ; ------------------------------------------------------------

.proc do_right
        lda     buf_right            ; length of string from IP rightwards
        cmp     #2              ; must be at least one char (plus IP)
        bcc     done

        ;; copy char from start of right to end of left
        lda     buf_right+2
        ldx     buf_left
        inx
        sta     buf_left,x

        ;; shift right string down one (apart from IP)
        ldx     #3
        ldy     #2
:       lda     buf_right,x
        sta     buf_right,y
        inx
        iny
        cpy     buf_right
        bcc     :-

        ;; adjust lengths
        inc     buf_left
        dec     buf_right

        jsr     draw_input_text

done:   jmp     input_loop
.endproc

;;; ; ------------------------------------------------------------


.proc do_delete
        lda     buf_left            ; length of string to left of IP
        beq     done

        dec     buf_left
        jsr     draw_input_text

done:   jmp     input_loop
.endproc


;;; ; ------------------------------------------------------------

.proc do_search
        ;; Concatenate left/right strings
        ldx     buf_left
        beq     right

        ;; Copy left
:       lda     buf_left,x
        sta     buf_search,x
        dex
        bpl     :-
        ldx     buf_left

        ;; Append right
right:
        ldy     #1
:       cpy     buf_right
        beq     done_concat
        iny
        inx
        lda     buf_right,y
        sta     buf_search,x
        bne     :-              ; always

done_concat:
        stx     buf_search

        ;;  TODO!!!!!
        jmp     input_loop
.endproc


;;; ============================================================

.proc handle_down
        copy16  event_params::xcoord, findwindow_params::mousex
        copy16  event_params::ycoord, findwindow_params::mousey
        MGTK_CALL MGTK::FindWindow, findwindow_params
        lda     findwindow_params::which_area
        cmp     #MGTK::area_content
        bne     done
        lda     findwindow_params::window_id
        cmp     #results_window_id
        beq     results
        cmp     #da_window_id
        bne     done

        ;; Click in DA content area
        addr_call button_press, search_button_rect
        beq     :+
        bmi     done
        jmp     do_search

:       addr_call button_press, cancel_button_rect
        beq     :+
        bmi     done
        jmp     exit

:
done:   jmp     input_loop

        ;; Click in Results content area
results:
        copy16  event_params::xcoord, findcontrol_params::mousex
        copy16  event_params::ycoord, findcontrol_params::mousey
        MGTK_CALL MGTK::FindControl, findcontrol_params
        lda     findcontrol_params::which_ctl
        cmp     #MGTK::ctl_vertical_scroll_bar
        bne     done

        jmp     handle_scroll
.endproc


;;; ============================================================
;;; Results scroll

.proc handle_scroll
        lda     findcontrol_params::which_part
        cmp     #MGTK::part_up_arrow
        beq     done            ; TODO: Scroll!
        cmp     #MGTK::part_down_arrow
        beq     done            ; TODO: Scroll!
        cmp     #MGTK::part_page_up
        beq     done            ; TODO: Scroll!
        cmp     #MGTK::part_page_down
        beq     done            ; TODO: Scroll!
        cmp     #MGTK::part_thumb
        bne     done
        copy16  event_params::xcoord, trackthumb_params::mousex
        copy16  event_params::ycoord, trackthumb_params::mousey
        MGTK_CALL MGTK::TrackThumb, trackthumb_params
        lda     trackthumb_params::thumbmoved
        beq     done
        ;; TODO: Update thumb
done:   jmp     input_loop
.endproc

;;; ============================================================
;;; Call with rect addr in A,X
;;; Returns: 0 (beq) if outside, $FF (bmi) if canceled, 1 if clicked

.proc button_press
        outside         := 0
        canceled        := $FF
        clicked         := 1

        stax    inrect_addr
        stax    fillrect_addr
        jsr     test_rect
        beq     :+
        return  #outside

:       jsr     invert_rect

        lda     #0
        sta     down_flag

loop:   MGTK_CALL MGTK::GetEvent, event_params
        lda     event_params::kind
        cmp     #MGTK::event_kind_button_up
        beq     exit

        jsr     test_rect
        beq     inside

        lda     down_flag       ; outside but was inside?
        beq     invert
        jmp     loop

inside: lda     down_flag       ; already depressed?
        bne     invert
        jmp     loop

invert: jsr     invert_rect
        lda     down_flag
        clc
        adc     #$80
        sta     down_flag
        jmp     loop

exit:   lda     down_flag       ; was depressed?
        beq     :+
        return  #canceled
:       jsr     invert_rect     ; invert one last time
        return  #clicked

down_flag:
        .byte   0

test_rect:
        copy16  event_params::xcoord, screentowindow_params::screen::xcoord
        copy16  event_params::ycoord, screentowindow_params::screen::ycoord
        MGTK_CALL MGTK::ScreenToWindow, screentowindow_params
        MGTK_CALL MGTK::MoveTo, screentowindow_params::window
        MGTK_CALL MGTK::InRect, 0, inrect_addr
        cmp     #MGTK::inrect_inside
        rts

invert_rect:
        MGTK_CALL MGTK::GetWinPort, winport_params
        MGTK_CALL MGTK::SetPort, grafport
        MGTK_CALL MGTK::SetPenMode, penxor
        MGTK_CALL MGTK::PaintRect, 0, fillrect_addr
        rts
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
        MGTK_CALL MGTK::SetPort, grafport
        MGTK_CALL MGTK::HideCursor

        MGTK_CALL MGTK::SetPenMode, penxor
        MGTK_CALL MGTK::FrameRect, frame_rect1
        MGTK_CALL MGTK::FrameRect, frame_rect2

        MGTK_CALL MGTK::MoveTo, find_label_textpos
        addr_call draw_string, find_label
        MGTK_CALL MGTK::FrameRect, input_rect

        MGTK_CALL MGTK::FrameRect, search_button_rect
        MGTK_CALL MGTK::MoveTo, search_button_textpos
        addr_call draw_string, search_button_label

        MGTK_CALL MGTK::FrameRect, cancel_button_rect
        MGTK_CALL MGTK::MoveTo, cancel_button_textpos
        addr_call draw_string, cancel_button_label

        MGTK_CALL MGTK::ShowCursor
done:   rts
.endproc

;;; ============================================================

.proc draw_input_text
        MGTK_CALL MGTK::GetWinPort, winport_params
        MGTK_CALL MGTK::SetPort, grafport
        MGTK_CALL MGTK::MoveTo, input_textpos
        MGTK_CALL MGTK::HideCursor
        addr_call draw_string, buf_left
        addr_call draw_string, buf_right
        addr_call draw_string, suffix
        MGTK_CALL MGTK::ShowCursor
        rts
.endproc

;;; ============================================================
;;; Helper to draw a PASCAL_STRING; call with addr in A,X

.proc draw_string
        PARAM_BLOCK params, $06
addr:   .res    2
length: .res    1
        END_PARAM_BLOCK

        stax    params::addr
        ldy     #0
        lda     (params::addr),y
        beq     done
        sta     params::length
        inc16   params::addr
        MGTK_CALL MGTK::DrawText, params
done:   rts
.endproc

;;; ============================================================

da_end  = *
.assert * < $1B00, error, "DA too big"
        ;; I/O Buffer starts at MAIN $1C00
        ;; ... but icon tables start at AUX $1B00
