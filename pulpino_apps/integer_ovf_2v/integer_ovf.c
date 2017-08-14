#include <stdio.h>
#include <stdint.h>
#include <string.h>

char* dummy_args[] = {"integer_ovf_2v", "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA", NULL};

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
  argv = dummy_args;    
  argc = sizeof(dummy_args)/sizeof(dummy_args[0])-1; 
 
  bad_function(argv[1]);  
  
  return 0;
}

