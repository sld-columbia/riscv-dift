#include <stdio.h>
#include <string.h>
#include <stdlib.h>

char* dummy_args[] = {"QPOP_bftpd", "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\xe0\x03\x00\x00", NULL};

void secretFunction()
{
  printf("Congratulations!\n");
  printf("You have entered in the secret function!\n");

  exit(0);
}

void echo(char* s)
{
  char buffer[20];

  strcpy(buffer, s);
  //printf("You entered: %s\n", buffer);    
}

int main(int argc, char* argv[])
{
  volatile int a = 1;
  int i;
  argv = dummy_args;
  argc = sizeof(dummy_args)/sizeof(dummy_args[0])-1;

  for(i=0; i<strlen(argv[1]); i++){
    asm volatile ("p.spsw x0, 0(%[argv]);"                
                 :
                 :[argv] "r" (argv[1]+i));
  }

  if(a)
    echo(argv[1]);
  else
    secretFunction();

  return 0;
}
