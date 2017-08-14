#include <stdio.h>
#include <string.h>

char* dummy_args[] = {"integer_ovf_2u", "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA", NULL};

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
  argv = dummy_args;    
  argc = sizeof(dummy_args)/sizeof(dummy_args[0])-1; 

  good_function(argv[1]);  

  return 0;
}

