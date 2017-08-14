#include <stdio.h>
#include <stdlib.h>

char* dummy_args[] = {"integer_ovf_1v", "98", "EEEEEEEC", NULL};

int main (int argc, char * argv[])
{
  int x;
  int y;

  argv = dummy_args;    
  argc = sizeof(dummy_args)/sizeof(dummy_args[0])-1; 

  x = strtol(argv[1], NULL, 16);
  y = strtol(argv[2], NULL, 16);

  /* Check is being bypassed here */
  if((x+y) > 256)
  {
    return -1;
  }
  else
  {
    printf("Congratulations!\n");
    printf("%u + %u = %u\n", x, y, x+y);
  }
 
  return 0;
}
