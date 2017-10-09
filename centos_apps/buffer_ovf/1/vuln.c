#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char* argv[])
{
    char buff[15];
    int pass = 0;

    if (argc =! 2)
    {
      fprintf(stderr, "Right usage: ./vuln password");
      exit(1);
    }

    strcpy(buff, argv[1]);

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
