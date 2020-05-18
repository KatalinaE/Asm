#include <iostream>
#include <stdio.h>
#include <assert.h>

using namespace std;

int main()
{
	FILE *in = NULL;
	in = fopen("vzlom(1).com", "rb+");
	assert(in);
	
	int pos = 0;
	pos = 0x23;
	int fseek_error = fseek(in, pos, SEEK_SET);
	assert(fseek_error != -1);
	
	int symb = 0;
	symb = 0x74;
	putc(symb, in);
	
	fclose(in);
	
	return 0;
}
