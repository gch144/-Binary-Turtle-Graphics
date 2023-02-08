#include "stdio.h"
#include "stdlib.h"

extern int turtle(
	unsigned char *dest_bitmap,
	unsigned char *commands,
	unsigned int commands_size
);

#define bitmap_size 90056
#define binary_size 4096

const char* binpath = "error.bin";
const char* tplpath = "tpl.bmp";
const char* bmppath = "out.bmp";

char bitmap[bitmap_size];
char binary[binary_size];

int main(int argc, char** argv)
{
	printf("Reading template... ");
	FILE* hFile = fopen(tplpath, "rb");	
	if (!hFile) {
		printf("Couldn't open the bitmap template!\n");	
		return -1;
	}
	else printf("OK\n");
	fread(bitmap, sizeof(char), bitmap_size, hFile);
	fclose(hFile);
	
	printf("Reading program... ");
	hFile = fopen(binpath, "rb");	
	if (!hFile) {
		printf("Couldn't open the program binary!\n");	
		return -1;
	}
	else printf("OK\n");
	unsigned int size = fread(binary, sizeof(char), binary_size, hFile);
	fclose(hFile);
	
	printf("Running program... ");
	int result = turtle(bitmap + 56, binary, size);// offset for the header
	
	switch (result)
	{
		case 0:
			printf("OK\n");
			break;
		case -1:
			printf("Invalid program size\n");
			return result;
	}
	
	printf("Writing result...");
	hFile = fopen(bmppath, "wb");	
	if (!hFile) {
		printf("Couldn't open the result bitmap!\n");	
		return -1;
	}
	else printf("OK\n");
	fwrite(bitmap, sizeof(char), bitmap_size, hFile);
	fclose(hFile);
	
	
	return result;
}