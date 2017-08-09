#include <stdio.h>
#include <string.h>

/*****************************************************************/
/*            Location: BSS     Target: global variable          */
/*****************************************************************/

static char buff[15];
static int pass = 0;

int main(void)
{
    printf("Enter the password : \n");
    gets(buff);

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
