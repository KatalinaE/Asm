#include <iostream>
#include <stdio.h>
#include <assert.h>

using namespace std;

int main()
{
	FILE *in = NULL;
	in = fopen("vzlom(1).com", "rb+");
	assert(in);
	
	int fseek_error = fseek(in, 0x23, SEEK_SET);
	assert(fseek_error != -1);
	
	putc(0x74, in);
	
	fclose(in);
	
	return 0;
}
