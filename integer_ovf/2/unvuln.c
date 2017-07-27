#include <stdio.h>
#include <string.h>

void good_function(char *input)
{
  char dest_buffer[32];
  int input_len = strlen(input);

  if (input_len < 32)
  {
    strncpy(dest_buffer, input, 32);
    printf("The first command line argument is %s\n", dest_buffer);
  }
  else
  {
    printf("Error – input is too long for buffer\n");
  }
}

int main(int argc, char *argv[])
{
  if (argc > 1)
  {
    good_function(argv[1]);  
  }
  else
  {
    printf("No command line argument was given.\n");
  }

  return 0;
}

