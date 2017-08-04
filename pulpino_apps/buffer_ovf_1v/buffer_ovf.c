#include <stdio.h>
#include <string.h>

int main(void)
{
    char buff[15];
    int pass = 0;

    strcpy(buff,"hhhhhhhhhhhhhhhhhhhh");
    
    if(strcmp(buff, "thegeekstuff"))
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
