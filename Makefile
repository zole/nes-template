PROGRAM = hello

### Uncomment to start your project:
# AS_SOURCES = start nes main nmi audio
# C_SOURCES =

### Demo:
ifndef AS_SOURCES
AS_SOURCES = start nes demo audio
endif

# Override space allocated to the C stack by the linker script
# C_STACK_SIZE = 0x100

ASMINC = res FamiStudio/SoundEngine
BININC = res
OUT = build
EMULATOR = /Applications/Mesen.app/Contents/MacOS/Mesen --enableStdout

### Things below here are less likely to need editing

CC65_TARGET = nes
CC = cc65
LD = ld65
AS = ca65

LDCFG = nes_nrom.cfg
CFLAGS = -t $(CC65_TARGET) --debug-info -W const-comparison,no-effect	
## optimize:
CFLAGS += -O
## match $(LDCFG):
CFLAGS += --bss-name RAM
ASFLAGS = -t $(CC65_TARGET) --debug-info -W z
ASFLAGS += ${foreach dir,$(ASMINC),-I $(dir)}
ASFLAGS += ${foreach dir,$(BININC),--bin-include-dir $(dir)}
LDFLAGS = --warn-align-waste

ifneq ($(strip $(C_SOURCES)),)
USE_C = yes
ASFLAGS += -D USE_C=1
LDFLAGS += --lib nes.lib
	ifneq ($(strip $(C_STACK_SIZE)),)
	LDFLAGS += --define __STACKSIZE__=$(C_STACK_SIZE)
	endif
else
LDFLAGS += --define __STACKSIZE__=0
endif

SRC = $(AS_SOURCES) $(C_SOURCES)
OBJS = ${addprefix $(OUT)/, ${addsuffix .o, $(SRC)}}
DEPS = $(OBJS:.o=.d)

########################################

# Disables implicit rules, for some reason
.SUFFIXES:

.SECONDARY: 

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
		$(LDFLAGS) \
		-o $@

ifdef USE_C
# Compile C to asm
$(OUT)/%.s: %.c $(LDCFG)
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) --create-dep $(OUT)/$(<:.c=.d) -o $@ $<
endif

# Assemble asm
$(OUT)/%.o: %.s $(LDCFG)
	@mkdir -p $(dir $@)
	$(AS) $(ASFLAGS) --create-dep $(OUT)/$(<:.s=.d) --listing $(OUT)/$*.lst -o $@ $<

# asm files in the build directory are assumed to be compiled C
$(OUT)/%.o: $(OUT)/%.s
	$(AS) $(ASFLAGS) --listing $(OUT)/$*.lst -o $@ $<


play: $(PROGRAM).nes
	$(EMULATOR) $<

clean:
	$(RM) $(OUT)/* $(PROGRAM).nes $(PROGRAM).map $(PROGRAM).dbg
