#include <stdio.h>
#include <stdint.h>
#include <string.h>

void bad_function(char *input)
{
  char dest_buffer[32];
  signed char input_len = strlen(input);

  if (input_len < 32)
  {
    strcpy(dest_buffer, input);
    printf("The first command line argument is %s\n", dest_buffer);
  }
  else
  {
    printf("Error – input is too long for buffer\n");
  }
}

int main(int argc, char *argv[])
{
  bad_function("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");  
  
  return 0;
}

