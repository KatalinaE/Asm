#include <stdio.h>

int main()
{
	FILE *in = NULL;
	in = fopen("vzlom(1).com", "rb+");
	if (in == NULL) {
		return -1;
	}
	
	int pos = 0;
	pos = 0x23;
	int fseek_status = fseek(in, pos, SEEK_SET);
	if (fseek_status == -1) {
		return -1;
	}
	
	int symb = 0;
	symb = 0x74;
	putc(symb, in);
	
	fclose(in);
	
	return 0;
}
