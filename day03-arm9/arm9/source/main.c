#include "common.h"
#include "draw.h"
#include "hid.h"
#include "i2c.h"
#include "fatfs/ff.h"

#include <stdlib.h>

static void mcu_poweroff()
{
	i2cWriteRegister(I2C_DEV_MCU, 0x20, 1 << 0);
	while (1) ;
}

static u32 wait_any_key_pressed()
{
	u32 pad;
	while (~HID_PAD & BUTTON_NONE);
	while (!((pad = ~HID_PAD) & BUTTON_NONE));
	return pad;
}

static void wait_any_key_poweroff()
{
	Debug("Press any key to poweroff.\n");
	wait_any_key_pressed();
	mcu_poweroff();
}

static FATFS fs;
static FIL file;
u8 *const spareMem = (void *) 0x08000100;

char *solve(u8 *input);

int main(int argc, char *argv[])
{
	InitScreenFbs(argc, argv);
	ClearScreenFull(true, true);
	DebugClear();

	//i2cWriteRegister(I2C_DEV_MCU, 0x29, 6);

	Debug("I am *firmly*... ware.\n\n");

	Debug("Initializing SD... ");

	if (f_mount(&fs, "0:", 1) != FR_OK) {
		Debug("failed. That's not good.\n");
		wait_any_key_poweroff();
	}
	Debug("success\n\n");

	UINT br = 0;
	FSIZE_t size;
	if (f_open(&file, "input.txt", FA_READ | FA_OPEN_EXISTING) != FR_OK) {
		Debug("WHERE IS THE input.txt\n");
		f_unmount("0:");
		wait_any_key_poweroff();
	}
	size = f_size(&file);
	if (f_read(&file, spareMem, size, &br) != FR_OK) {
		Debug("WHAT\n");
		f_unmount("0:");
		wait_any_key_poweroff();
	}
	spareMem[size] = 0;
	f_unmount("0:");

	const char *const out = solve(spareMem);
	Debug(out);

	wait_any_key_poweroff();
}
