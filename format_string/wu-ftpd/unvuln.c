#include <stdio.h>

int main(int argc, char* argv[])
{
  int protected = 0;
  char buff[512];

  snprintf(buff, sizeof(buff), "%s", argv[1]);
  buff[sizeof(buff)-1] = 0;

  if(protected)
  {
    // Now Give root or admin rights to user
    printf ("Root privileges given to the user \n");
  }
  
  return 0;
}
