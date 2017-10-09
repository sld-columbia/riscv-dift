#include <stdio.h>

int main (int argc, char * argv[])
{
  int x = 0X98;
  int y = 0xEEEEEEEC;

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
