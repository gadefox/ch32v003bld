TARGET := ch32v003bld
WCHSDK_MCU := ch32/v003

include wchsdk/makefile
#include lib/ch32usb/makefile

OUTDIR := out
#SRCS += $(wildcard src/*.c)
INC += -Isrc

SRCOBJS := $(patsubst %.c,$(OUTDIR)/%.o,$(SRCS))
ASMOBJS := $(patsubst %.S,$(OUTDIR)/%_s.o,$(ASMS))
OBJS := $(SRCOBJS) $(ASMOBJS)

CFLAGS += -g -Os $(INC) -DUSE_TINY_BOOT
LDFLAGS += -T src/ch32v003.ld -Wl,-Map=$(OUTDIR)/$(TARGET).map

.PHONY: all build clean

all: build

$(OUTDIR)/%.o: %.c | $(OUTDIR)
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

$(OUTDIR)/%_s.o: %.S | $(OUTDIR)
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

$(OUTDIR)/$(TARGET).bin: $(OBJS) | $(OUTDIR)
	$(CC) $(CFLAGS) $(OBJS) $(LDFLAGS) -o $(OUTDIR)/$(TARGET).elf
	$(OBJCOPY) -O binary $(OUTDIR)/$(TARGET).elf $(OUTDIR)/$(TARGET).bin
	$(OBJCOPY) -O ihex $(OUTDIR)/$(TARGET).elf $(OUTDIR)/$(TARGET).hex
	$(OBJDUMP) -S $(OUTDIR)/$(TARGET).elf > $(OUTDIR)/$(TARGET).lst

$(OUTDIR):
	mkdir -p $(OUTDIR)

build: $(OUTDIR)/$(TARGET).bin

clean:
	rm -rf $(OUTDIR)
