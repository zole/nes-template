PROGRAM = hello
### Blank project:
# SRC = start nes main nmi audio
### Demo:
SRC = start nes demo audio


ASMINC = res FamiStudio/SoundEngine
BININC = res
OUT = build

EMULATOR = /Applications/Mesen.app/Contents/MacOS/Mesen --enableStdout

CC65_TARGET = nes
CC = cc65
LD = ld65
ASM = ca65

LDCFG = nes_nrom.cfg
CFLAGS = -t $(CC65_TARGET) --bss-name RAM --debug-info -O -W const-comparison,no-effect	
ASMFLAGS = -t $(CC65_TARGET) --debug-info -W z
ASMFLAGS += ${foreach dir,$(ASMINC),-I $(dir)}
ASMFLAGS += ${foreach dir,$(BININC),--bin-include-dir $(dir)}

OBJS = ${addprefix $(OUT)/, ${addsuffix .o, $(SRC)}}
DEPS = $(OBJS:.o=.d)

########################################

# Disables implicit rules, for some reason
.SUFFIXES:

.PHONY: all clean play

all: $(PROGRAM).nes

-include $(DEPS)

# --dbgfile generates debug symbols that Mesen can read
$(PROGRAM).nes: $(OBJS) $(LDCFG)
	@mkdir -p $(dir $@)
	$(LD) $(OBJS) \
	    --config $(LDCFG) \
		--mapfile $(OUT)/$(PROGRAM).map \
		--dbgfile $(PROGRAM).dbg \
		--lib nes.lib \
		-o $@

# Compile C to asm
$(OUT)/%.s: %.c $(LDCFG)
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) --create-dep $(OUT)/$(<:.c=.d) -o $@ $<

# Assemble asm
$(OUT)/%.o: %.s $(LDCFG)
	@mkdir -p $(dir $@)
	$(ASM) $(ASMFLAGS) --create-dep $(OUT)/$(<:.s=.d) --listing $(OUT)/$*.lst -o $@ $<

# asm files in the build directory are assumed to be compiled C
$(OUT)/%.o: $(OUT)/%.s
	$(ASM) $(ASMFLAGS) --listing $(OUT)/$*.lst -o $@ $<


play: $(PROGRAM).nes
	$(EMULATOR) $<

clean:
	$(RM) $(OUT)/* $(PROGRAM).nes $(PROGRAM).map $(PROGRAM).dbg
