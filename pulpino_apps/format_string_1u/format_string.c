#include  <stdio.h>
#include  <string.h>
#include  <stdlib.h>

int main (int argc, char **argv)
{
  char buf[100];
  
  //snprintf(buf, sizeof(buf), argv[1]) ;
  strncpy(buf, argv[1], sizeof(buf));
  buf[sizeof(buf)-1] = 0;
  printf("Buffer size is: (%d)\nData input: %s\n", strlen(buf), buf);
	
  return 0;
}
