#include <stdio.h>
#include <string.h>

#define SIZE 15
    
static char buff[SIZE];
static int pass = 0;

int main(void)
{
    printf("Enter the password : \n");
    fgets(buff, SIZE, stdin);

    buff[strlen(buff)-1] = '\0';

    if(strncmp(buff, "thegeekstuff", SIZE))
    {
        printf ("Wrong Password \n");
    }
    else
    {
        printf ("Correct Password \n");
        pass = 1;
    }

    if(pass)
    {
       /* Now Give root or admin rights to user*/
        printf ("Root privileges given to the user \n");
    }

    return 0;
}
