;;;******************************************************
;;; ProDOS #17
;;; Recursive ProDOS Catalog Routine
;;;
;;; Revised by Dave Lyons, Keith Rollin, & Matt Deatherage (November 1989)
;;; Written by Greg Seitz (December 1983)
;;;
;;; From http://www.1000bit.it/support/manuali/apple/technotes/pdos/tn.pdos.17.html
;;;
;;; Converted to ca65 syntax
;;;******************************************************

        .org $800
        .setcpu "6502"

;;;******************************************************
;;;
;;; Recursive ProDOS Catalog Routine
;;;
;;; by: Greg Seitz 12/83
;;;     Pete McDonald 1/86
;;;     Keith Rollin 7/88
;;;     Dave Lyons 11/89
;;;
;;; This program shows the latest "Apple Approved"
;;; method for reading a directory under ProDOS 8.
;;; READ_BLOCK is not used, since it is incompatible
;;; with AppleShare file servers.
;;;
;;; November 1989: The file_count field is no longer
;;; used (all references to ThisEntry were removed).
;;; This is because the file count can change on the fly
;;; on AppleShare volumes.  (Note that the old code was
;;; accidentally decrementing the file count when it
;;; found an entry for a deleted file, so some files
;;; could be left off the end of the list.)
;;;
;;; Also, ThisBlock now gets incremented when a chunk
;;; of data is read from a directory.  Previously, this
;;; routine could get stuck in an endless loop when
;;; a subdirectory was found outside the first block of
;;; its parent directory.
;;;
;;; Limitations:  This routine cannot reach any
;;; subdirectory whose pathname is longer than 64
;;; characters, and it will not operate correctly if
;;; any subdirectory is more than 255 blocks long
;;; (because ThisBlock is only one byte).
;;;
;;;******************************************************
;;;
;;; Equates
;;;
;;; Zero page locations
;;;
dirName   :=   $80           ; pointer to directory name
entPtr    :=   $82           ; ptr to current entry
;;;
;;; ProDOS command numbers
;;;
MLI       :=   $BF00         ; MLI entry point
mliGetPfx :=   $C7           ; GET_PREFIX
mliOpen   :=   $C8           ; Open a file command
mliRead   :=   $CA           ; Read a file command
mliClose  :=   $CC           ; Close a file command
mliSetMark :=  $CE           ; SET_MARK command
EndOfFile :=   $4C           ; EndOfFile error
;;;
;;; BASIC.SYSTEM stuff
;;;
GetBufr   :=   $BEF5         ; BASIC.SYSTEM get buffer routine
;;;
;;; Offsets into the directory
;;;
oType     :=   $0            ; offset to file type byte
oEntLen   :=   $23           ; length of each dir. entry
oEntBlk   :=   $24           ; entries in each block
;;;
;;; Monitor routines
;;;
cout      :=   $FDED         ; output a character
crout     :=   $FD8E         ; output a RETURN
prbyte    :=   $FDDA         ; print byte in hex
space     :=   $A0           ; a space character
;;;
;;;******************************************************
;;;
Start     :=   *
;;;
;;; Simple routine to test the recursive ReadDir
;;; routine. It gets an I/O buffer for ReadDir, gets
;;; the current prefix, sets the depth of recursion
;;; to zero, and calls ReadDir to process all of the
;;; entries in the directory.
;;;
          lda   #4            ; get an I/O buffer
          jsr   GetBufr
          bcs   exit          ; didn't get it
          sta   ioBuf+1
;;;
;;; Use the current prefix for the name of the
;;; directory to display.  Note that the string we
;;; pass to ReadDir has to end with a "/", and that
;;; the result of GET_PREFIX does.
;;;
          jsr   MLI
          .byte    mliGetPfx
          .word    GetPParms
          bcs   exit
;;;
          lda   #0
          sta   Depth
;;;
          lda   #<nameBuffer
          ldx   #>nameBuffer
          jsr   ReadDir
;;;
exit      :=   *
          rts
;;;
;;;******************************************************
;;;******************************************************
;;;
ReadDir   :=   *
;;;
;;;  This is the actual recursive routine. It takes as
;;;  input a pointer to the directory name to read in
;;;  A,X (lo,hi), opens it, and starts to read the
;;;  entries. When it encounters a filename, it calls
;;;  the routine "VisitFile". When it encounters a
;;;  directory name, it calls "VisitDir".
;;;
;;;  The directory pathname string must end with a "/"
;;;  character.
;;;
;;;******************************************************
;;;
          sta   dirName       ; save a pointer to name
          stx   dirName+1
;;;
          sta   OpenName      ; set up OpenFile params
          stx   OpenName+1
;;;
ReadDir1  :=   *             ; recursive entry point
          jsr   OpenDir       ; open the directory as a file
          bcs   done
;;;
          jmp   nextEntry     ; jump to the end of the loop
;;;
loop      :=   *
          ldy   #oType        ; get type of current entry
          lda   (entPtr),y
          and   #$F0          ; look at 4 high bits
          cmp   #0            ; inactive entry?
          beq   nextEntry     ; yes - bump to next one
          cmp   #$D0          ; is it a directory?
          beq   ItsADir       ; yes, so call VisitDir
          jsr   VisitFile     ; no, it's a file
          jmp   nextEntry
;;;
ItsADir:  jsr     VisitDir
nextEntry :=   *
          jsr   GetNext       ; get pointer to next entry
          bcc   loop          ; Carry set means we're done
done      :=   *             ; moved before PHA (11/89 DAL)
          pha                 ; save error code
;;;
          jsr   MLI           ; close the directory
          .byte    mliClose
          .word    CloseParms
;;;
          pla                 ;we're expecting EndOfFile error
          cmp   #EndOfFile
          beq   hitDirEnd
;;;
;;; We got an error other than EndOfFile -- report the
;;; error clumsily ("ERR=$xx").
;;;
          pha
          lda   #'E'|$80
          jsr   cout
          lda   #'R'|$80
          jsr   cout
          jsr   cout
          lda   #'='|$80
          jsr   cout
          lda   #'$'|$80
          jsr   cout
          pla
          jsr   prbyte
          jsr   crout
;;;
hitDirEnd :=   *
          rts
;;;
;;;******************************************************
;;;
OpenDir   :=   *
;;;
;;;  Opens the directory pointed to by OpenParms
;;;  parameter block. This pointer should be init-
;;;  ialized BEFORE this routine is called. If the
;;;  file is successfully opened, the following
;;;  variables are set:
;;;
;;;     xRefNum     ; all the refnums
;;;     entryLen    ; size of directory entries
;;;     entPtr     ; pointer to current entry
;;;     ThisBEntry  ; entry number within this block
;;;     ThisBlock   ; offset (in blocks) into dir.
;;;
          jsr   MLI           ; open dir as a file
          .byte    mliOpen
          .word    OpenParms
          bcs   OpenDone
;;;
          lda   oRefNum       ; copy the refnum return-
          sta   rRefNum       ; ed by Open into the
          sta   cRefNum       ; other param blocks.
          sta   sRefNum
;;;
          jsr   MLI           ; read the first block
          .byte    mliRead
          .word    ReadParms
          bcs   OpenDone
;;;
          lda   buffer+oEntLen ; init 'entryLen'
          sta   entryLen
;;;
          lda   #<(buffer+4)     ; init ptr to first entry
          sta   entPtr
          lda   #>(buffer+4)
          sta   entPtr+1
;;;
          lda   buffer+oEntBlk ; init these values based on
          sta   ThisBEntry    ; values in the dir header
          sta   entPerBlk
;;;
          lda   #0            ; init block offset into dir.
          sta   ThisBlock
;;;
          clc                 ; say that open was OK
;;;
OpenDone  :=   *
          rts
;;;
;;;******************************************************
;;;
VisitFile :=   *
;;;
;;; Do whatever is necessary when we encounter a
;;; file entry in the directory. In this case, we
;;; print the name of the file.
;;;
          jsr   PrintEntry
          jsr   crout
          rts
;;;
;;;******************************************************
;;;
VisitDir  :=   *
;;;
;;; Print the name of the subdirectory we are looking
;;; at, appending a "/" to it (to indicate that it's
;;; a directory), and then calling RecursDir to list
;;; everything in that directory.
;;;
          jsr   PrintEntry    ; print dir's name
          lda   #'/'|$80      ; tack on / at end
          jsr   cout
          jsr   crout
;;;
          jsr   RecursDir     ; enumerate all entries in sub-dir.
;;;
          rts
;;;
;;;******************************************************
;;;
RecursDir :=   *
;;;
;;; This routine calls ReadDir recursively. It
;;;
;;; - increments the recursion depth counter,
;;; - saves certain variables onto the stack
;;; - closes the current directory
;;; - creates the name of the new directory
;;; - calls ReadDir (recursively)
;;; - restores the variables from the stack
;;; - restores directory name to original value
;;; - re-opens the old directory
;;; - moves to our last position within it
;;; - decrements the recursion depth counter
;;;
          inc   Depth         ; bump this for recursive call
;;;
;;; Save everything we can think of (the women,
;;; the children, the beer, etc.).
;;;
          lda   entPtr+1
          pha
          lda   entPtr
          pha
          lda   ThisBEntry
          pha
          lda   ThisBlock
          pha
          lda   entryLen
          pha
          lda   entPerBlk
          pha
;;;
;;; Close the current directory, as ReadDir will
;;; open files of its own, and we don't want to
;;; have a bunch of open files lying around.
;;;
          jsr   MLI
          .byte    mliClose
          .word    CloseParms
;;;
          jsr   ExtendName    ; make new dir name
;;;
          jsr   ReadDir1      ; enumerate the subdirectory
;;;
          jsr   ChopName      ; restore old directory name
;;;
          jsr   OpenDir       ; re-open it back up
          bcc   reOpened
;;;
;;; Can't continue from this point -- exit in
;;; whatever way is appropriate for your
;;; program.
;;;
          brk
;;;
reOpened  :=   *
;;;
;;; Restore everything that we saved before
;;;
          pla
          sta   entPerBlk
          pla
          sta   entryLen
          pla
          sta   ThisBlock
          pla
          sta   ThisBEntry
          pla
          sta   entPtr
          pla
          sta   entPtr+1
;;;
          lda   #0
          sta   Mark
          sta   Mark+2
          lda   ThisBlock     ; reset last position in dir
          asl   a             ; = to block # times 512
          sta   Mark+1
          rol   Mark+2
;;;
          jsr   MLI           ; reset the file marker
          .byte    mliSetMark
          .word    SetMParms
;;;
          jsr   MLI           ; now read in the block we
          .byte    mliRead       ; were on last.
          .word    ReadParms
;;;
          dec   Depth
          rts
;;;
;;;******************************************************
;;;
ExtendName :=  *
;;;
;;; Append the name in the current directory entry
;;; to the name in the directory name buffer. This
;;; will allow us to descend another level into the
;;; disk hierarchy when we call ReadDir.
;;;
          ldy   #0            ; get length of string to copy
          lda   (entPtr),y
          and   #$0F
          sta   extCnt        ; save the length here
          sty   srcPtr        ; init src ptr to zero
;;;
          ldy   #0            ; init dest ptr to end of
          lda   (dirName),y   ; the current directory name
          sta   destPtr
;;;
extloop   :=   *
          inc   srcPtr        ; bump to next char to read
          inc   destPtr       ; bump to next empty location
          ldy   srcPtr        ; get char of sub-dir name
          lda   (entPtr),y
          ldy   destPtr       ; tack on to end of cur. dir.
          sta   (dirName),y
          dec   extCnt        ; done all chars?
          bne   extloop       ; no - so do more
;;;
          iny
          lda   #'/'          ; tack "/" on to the end
          sta   (dirName),y
;;;
          tya                 ; fix length of filename to open
          ldy   #0
          sta   (dirName),y
;;;
          rts
;;;
extCnt: .res    1
srcPtr: .res    1
destPtr:        .res    1
;;;
;;;
;;;******************************************************
;;;
ChopName  :=   *
;;;
;;; Scans the current directory name, and chops
;;; off characters until it gets to a /.
;;;
          ldy   #0            ; get len of current dir.
          lda   (dirName),y
          tay
ChopLoop  :=   *
          dey                 ; bump to previous char
          lda   (dirName),y
          cmp   #'/'
          bne   ChopLoop
          tya
          ldy   #0
          sta   (dirName),y
          rts
;;;
;;;******************************************************
;;;
GetNext   :=   *
;;;
;;; This routine is responsible for making a pointer
;;; to the next entry in the directory. If there are
;;; still entries to be processed in this block, then
;;; we simply bump the pointer by the size of the
;;; directory entry. If we have finished with this
;;; block, then we read in the next block, point to
;;; the first entry, and increment our block counter.
;;;
          dec   ThisBEntry    ; dec count for this block
          beq   ReadNext      ; done w/this block, get next one
;;;
          clc                 ; else bump up index
          lda   entPtr
          adc   entryLen
          sta   entPtr
          lda   entPtr+1
          adc   #0
          sta   entPtr+1
          clc                 ; say that the buffer's good
          rts
;;;
ReadNext  :=   *
          jsr   MLI           ; get the next block
          .byte    mliRead
          .word    ReadParms
          bcs   DirDone
;;;
          inc   ThisBlock
;;;
          lda   #<(buffer+4)     ; set entry pointer to beginning
          sta   entPtr        ; of first entry in block
          lda   #>(buffer+4)
          sta   entPtr+1
;;;
          lda   entPerBlk     ; re-init 'entries in this block'
          sta   ThisBEntry
          dec   ThisBEntry
          clc                 ; return 'No error'
          rts
;;;
DirDone   :=   *
          sec               ; return 'an error occurred' (error in A)
          rts
;;;
;;;******************************************************
;;;
PrintEntry :=  *
;;;
;;; Using the pointer to the current entry, this
;;; routine prints the entry name. It also pays
;;; attention to the recursion depth, and indents
;;; by 2 spaces for every level.
;;;
          lda   Depth         ; indent two blanks for each level
          asl   a             ; of directory nesting
          tax
          beq   spcDone
spcloop:  lda   #space
          jsr   cout
          dex
          bne   spcloop
spcDone   :=   *
;;;
          ldy   #0            ; get byte that has the length byte
          lda   (entPtr),y
          and   #$0F          ; get just the length
          tax
PrntLoop  :=   *
          iny                 ; bump to the next char.
          lda   (entPtr),y    ; get next char
          ora   #$80          ; COUT likes high bit set
          jsr   cout          ; print it
          dex                 ; printed all chars?
          bne   PrntLoop      ; no - keep going
          rts
;;;
;;;******************************************************
;;;
;;; Some global variables
;;;
Depth:  .res    1             ; amount of recursion
ThisBEntry:     .res   1             ; entry in this block
ThisBlock:      .res    1             ; block with dir
entryLen:       .res    1             ; length of each directory entry
entPerBlk:      .res    1             ; entries per block
;;;
;;;******************************************************
;;;
;;; ProDOS command parameter blocks
;;;
OpenParms :=   *
          .byte    3             ; number of parms
OpenName: .res     2             ; pointer to filename
ioBuf:    .word    0             ; I/O buffer
oRefNum:  .res     1             ; returned refnum
;;;
ReadParms :=   *
          .byte    4             ; number of parms
rRefNum:  .res     1             ; refnum from Open
          .word    buffer        ; pointer to buffer
reqAmt:   .word    512           ; amount to read
retAmt:   .res     2             ; amount actually read
;;;
CloseParms :=  *
          .byte    1             ; number of parms
cRefNum:  .res     1             ; refnum from Open
;;;
SetMParms :=   *
          .byte    2             ; number of parms
sRefNum:  .res     1             ; refnum from Open
Mark:     .res     3             ; file position
;;;
GetPParms :=  *
          .byte    1             ; number of parms
          .word    nameBuffer    ; pointer to buffer
;;;
buffer:   .res     512           ; enough for whole block
;;;
nameBuffer: .res   64            ; space for directory name
