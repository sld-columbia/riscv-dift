#include "common.h"
#include <stdio.h>

#define N 32
#define L 32
#define M 32

typedef uint8_t elem_t;

static elem_t mA[N*L] __sram;
static elem_t mB[L*M] __sram;
static elem_t mC[N*M] __sram;
#ifdef TRANSPOSE_B
static elem_t mBt[L*M] __sram;
#endif

#ifndef TRANSPOSE_B
extern void matmul(const elem_t *, const elem_t *, elem_t *,
                   unsigned, unsigned, unsigned);
#else
extern void matmul(const elem_t *, const elem_t *, elem_t *, elem_t *,
                   unsigned, unsigned, unsigned);
#endif

static void init(elem_t *m, unsigned len) {
  for (unsigned i = 0; i != len; ++i){
    m[i] = i % 4;
    asm volatile ("p.spsw x0, 0(%[m]);"                
                 :
                 :[m] "r" (m+i));
  }
} 

void test_setup() {
  init(mA, N*L);
  init(mB, L*M);
  init(mC, N*M);
}

void test_clear() {}

void test_run() {
  #ifndef TRANSPOSE_B
  matmul(mA, mB, mC, N, L, M);
  #else
  matmul(mA, mB, mBt, mC, N, L, M);
  #endif
}

int test_check() {
  for(int i = 0; i != N; i++){
    for(int j = 0; j != M; j++){
      printf("%2d ", mC[i*M+j]);
    }
    printf("\n");
  }
  return crc32(mC, N*M) == 0xd5639a47;
}
