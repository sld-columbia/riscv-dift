#include <stdio.h>
#include <string.h>

void secretFunction()
{
    printf("Congratulations!\n");
    printf("You have entered in the secret function!\n");
}

void echo()
{
    char buffer[20];

    strcpy(buffer, "");
    printf("You entered: %s\n", buffer);    
}

int main()
{
    volatile int a = 1;
    
    if(a)
      echo();
    else
      secretFunction();

    return 0;
}
