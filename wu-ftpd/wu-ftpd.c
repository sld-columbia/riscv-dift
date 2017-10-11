#include <stdio.h>
#include <string.h>
#include <stdlib.h>

void secretFunction()
{
  printf("Congratulations!\n");
  printf("You have entered in the secret function!\n");

  exit(0);
}

void echo()
{
  register int i asm("x8");

  printf("%224u%n%35u%n%253u%n%n", 1, (int*) (i-4), 1, (int*) (i-3), 1, (int*) (i-2), (int*) (i-1));

  return;
}

int main(int argc, char* argv[])
{ 
  volatile int a = 1;

  if(a)
    echo();
  else
    secretFunction();

  return 0;
}
