TARGET = gear_ratios

ARM9_LOAD      = 0x08000100
ARM9_ENTRY     = $(ARM9_LOAD)
ARM9_BIN       = arm9/$(TARGET)_arm9.bin

.PHONY: all bins clean .FORCE
.FORCE:

all: $(TARGET).firm

$(TARGET).firm: $(ARM9_BIN)
	firmtool build $@ -n $(ARM9_ENTRY) -e 0 -D $(ARM9_BIN) -A $(ARM9_LOAD) -C NDMA -i

$(ARM9_BIN): .FORCE
	@$(MAKE) -C arm9


clean:
	@$(MAKE) -C arm9 clean
	@rm -f $(TARGET).firm
