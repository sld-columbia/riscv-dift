// Copyright 2016 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the “License”); you may not use this file except in
// compliance with the License. You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an “AS IS” BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

#include <stdio.h>
#include <string.h>

char* dummy_args[] = {"helloworld", "Hello World!!!!!", NULL};

int main(int argc, char* argv[])
{
  argv = dummy_args;
  argc = sizeof(dummy_args)/sizeof(dummy_args[0])-1;

  /* TAG INITIALIZATION */
  for(int j=0; j<strlen(argv[1]); j++) {
    asm volatile ("p.spsw x0, 0(%[ovf]);"                
                 :
                 :[ovf] "r" (argv[1]+j));
  }

  printf("%s\n", argv[1]);

  return 0;
}
