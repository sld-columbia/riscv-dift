#include <stdio.h>
#include <string.h>

char* dummy_args[] = {"buffer_ovf_1u", "hhhhhhhhhhhhhhhhhhhh", NULL};

int main(int argc, char* argv[])
{
    char buff[15];
    int pass = 0;
    argv = dummy_args;    
    argc = sizeof(dummy_args)/sizeof(dummy_args[0])-1; 

    strncpy(buff, argv[1], sizeof(buff)-1);

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
