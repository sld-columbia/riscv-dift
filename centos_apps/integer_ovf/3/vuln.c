/*
CVE-2011-1092: PHP shmop_read() Integer Overflow
This bug was discovered and reported to the PHP team by Jose Carlos Norte. 
The bug affects shmop_read() function which can be found in ext/shmop/shmop.c source code file.
*/

#define SIZE 0x7FFFFFFF // 0x7FFFFFFF = 2147483647 = 2^31-1 
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char* shmop_read(int start, int count);

int main(int argc, char* argv[])
{
  // Ok
  //shmop_read(10,10);

  // This call fails
  shmop_read(1,2147483647);

  return 0;
}

char* shmop_read(int start, int count)
{
  int type;
  char* startaddr;
  int bytes;
  char *return_string;

  if(start < 0 || start > SIZE)
  {
    printf("start is out of range\n");
    return 0;
  }

  // Integer ovf on the check start+count>size
  if(start+count > SIZE || count < 0)
  {
    printf("count is out of range\n");
    return 0;
  }

  startaddr = (char*)start;

  bytes = count ? count : SIZE - start;

  return_string = (char*)malloc(bytes+1);
  memcpy(return_string, startaddr, bytes);
  return_string[bytes] = 0;

  return return_string;
}
