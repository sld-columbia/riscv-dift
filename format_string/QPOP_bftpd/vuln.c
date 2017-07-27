#include <stdio.h>

int main(int argc, char* argv[])
{
  char outbuf[512];
  char buffer[512];

  sprintf(buffer, "ERR Wrong Command: %400s", argv[1]);
  sprintf(outbuf, buffer);

  return 0;
}
