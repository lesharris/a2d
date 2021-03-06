
CC65 = ~/dev/cc65/bin
CAFLAGS = --target apple2enh --list-bytes 0
CCFLAGS = --config asm.cfg

OUTDIR = out

HEADERS = $(wildcard ../*.inc) $(wildcard ../inc/*.inc) $(wildcard *.inc)

SEGMENTS = loader mgtk desktop invoker \
        ovl1 ovl1a ovl1b ovl1c ovl2 ovl34567

TARGETS = $(patsubst %,$(OUTDIR)/%.built,$(SEGMENTS)) out/sys.SYS

.PHONY: clean all
all: $(OUTDIR) $(TARGETS)

$(OUTDIR):
	mkdir -p $(OUTDIR)

clean:
	rm -f $(OUTDIR)/*.o
	rm -f $(OUTDIR)/*.list
	rm -f $(OUTDIR)/*.inc
	rm -f $(OUTDIR)/*.built
	rm -f $(OUTDIR)/*.sys

$(OUTDIR)/desktop_res.inc: desktop_res.s desktop_res_builder.s res/build_res_inc.pl
	$(CC65)/ca65 $(CAFLAGS) --listing $(OUTDIR)/desktop_res.list -o $@ desktop_res_builder.s
	cat $(OUTDIR)/desktop_res.list | res/build_res_inc.pl > $@

$(OUTDIR)/desktop.o: desktop.s $(HEADERS) desktop_aux.s desktop_lc.s desktop_main.s desktop_res.s
	$(CC65)/ca65 $(CAFLAGS) --listing $(basename $@).list -o $@ $<

$(OUTDIR)/ovl34567.o: ovl34567.s $(HEADERS) $(OUTDIR)/desktop_res.inc ovl3.s ovl4.s ovl5.s ovl6.s ovl7.s
	$(CC65)/ca65 $(CAFLAGS) --listing $(basename $@).list -o $@ $<

$(OUTDIR)/%.o: %.s $(HEADERS) $(OUTDIR)/desktop_res.inc
	$(CC65)/ca65 $(CAFLAGS) --listing $(basename $@).list -o $@ $<

# Built DeskTop segments
$(OUTDIR)/%.built: $(OUTDIR)/%.o asm.cfg
	$(CC65)/ld65 $(CCFLAGS) -o '$@' $<

# System Files .SYS
$(OUTDIR)/%.SYS: $(OUTDIR)/%.o
	$(CC65)/ld65 $(CCFLAGS) -o '$@' $<
	xattr -wx prodos.AuxType '00 20' $@
