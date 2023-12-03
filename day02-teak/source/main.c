#include <3ds.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "cdc_bin.h"

// set MSB to get Luma3DS mapping for all-access, strong order
vu16* const dspP = (vu16*)(0x1FF00000 | (1 << 31));
vu16* const dspD = (vu16*)(0x1FF40000 | (1 << 31));

int main() {
	gfxInitDefault();

	consoleInit(GFX_TOP, NULL);

	printf("Hello!\n");


	Result res = dspInit();
    printf("dspInit: %08lX\n", res);
	if (R_FAILED(res))
		goto end;
    bool loaded = false;
	res = DSP_LoadComponent(cdc_bin, cdc_bin_size, 0xFF, 0xFF, &loaded);
    printf("DSP_LoadComponent: %08lX\n", res);
	if (!loaded || R_FAILED(res)) {
		printf("Failed to load DSP binary\n");
		goto end;
	}

	FILE *const input_file = fopen("sdmc:/aoc_input.txt", "r");
	fseek(input_file, 0, SEEK_END);
	const size_t len = ftell(input_file);
	fseek(input_file, 0, SEEK_SET);
	u8 *buf = malloc(len);
	fread(buf, 1, len, input_file);
	fclose(input_file);
	memcpy((void*) (dspD + 0x1000), buf, len);
	free(buf);
	((u8*) (dspD + 0x1000))[len] = 0;
	dspD[0] = 0xFFFF;
	printf("Waiting for the DSP to finish...\n\n");
	int wait = 100;
	while (dspD[0] != 1) {
		svcSleepThread(10 * 1000 * 1000);
		if (!(wait--)) {
			printf("ded\n");
			break;
		}
	}

	printf("DSP says %s\n", (char*) (dspD + 0x7f31));
	printf("Part 1: %hu\n", dspD[0x7f10]);
	printf("Part 2: %hu\n", dspD[0x7f11]);
	printf("debug: %hu %hu %hu %hu\n", dspD[0x7f18], dspD[0x7f19], dspD[0x7f1A], dspD[0x7f1B]);

end:
	printf("\nPress start to exit\n");

    while (aptMainLoop()) {
        hidScanInput();

        u32 kDown = hidKeysDown();

        if (kDown & KEY_START)
            break;

        // Flush and swap framebuffers
        gfxFlushBuffers();
        gfxSwapBuffers();

        // Wait for VBlank
        gspWaitForVBlank();
    }

    dspExit();
    gfxExit();

    return 0;
}

