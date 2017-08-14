#include <stdio.h>
#include "string_lib.h"

char* dummy_args[] = {"format_string_1v", "2", "Foo %x %x %x", NULL};

int main (int argc, char* argv[])
{
  argv = dummy_args;    
  argc = sizeof(dummy_args)/sizeof(dummy_args[0])-1; 

  //void syslog(int priority, const char *format, ...);
  my_syslog(2, argv[2]);  
	
  return 0;
}
