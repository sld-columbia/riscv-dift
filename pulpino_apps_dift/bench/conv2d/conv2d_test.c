#include "common.h"
#include "stdio.h"

#define IMG_SIZE 10

static int16_t coeffs[] __sram = {
  1, 4, 6, 4, 1,
  4,16,24,16, 4,
  6,24,36,24, 6,
  4,16,24,16, 4,
  1, 4, 6, 4, 1 };

static const int16_t check[IMG_SIZE * IMG_SIZE] = {
  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
  0,  0, 22, 23, 24, 25, 26, 27,  0,  0,
  0,  0, 32, 33, 34, 35, 36, 37,  0,  0,
  0,  0, 42, 43, 44, 45, 46, 47,  0,  0,
  0,  0, 52, 53, 54, 55, 56, 57,  0,  0,
  0,  0, 62, 63, 64, 65, 66, 67,  0,  0,
  0,  0, 72, 73, 74, 75, 76, 77,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
};

static int16_t img_in[IMG_SIZE * IMG_SIZE] __sram;
static int16_t img_out[IMG_SIZE * IMG_SIZE] __sram;

extern void conv2d(int16_t *, int16_t *, const int16_t *,
                   int, int, int, uint16_t);

void test_setup() {
  for (int i = 0; i != IMG_SIZE*IMG_SIZE; i++){
    img_in[i] = i;
    asm volatile ("p.spsw x0, 0(%[img]);"                
                 :
                 :[img] "r" (img_in+i));
  }
}

void test_clear() {
  memset(img_out, 0, IMG_SIZE*IMG_SIZE);
}

void test_run() {
  conv2d(img_in, img_out, coeffs, IMG_SIZE, IMG_SIZE, 5, 8);
}

int test_check() {
  for(int i = 0; i != IMG_SIZE*IMG_SIZE; i = i+10){
    for(int j = 0; j != IMG_SIZE; j++){
      printf("%2d ", img_out[i+j]);
    }
    printf("\n");
  }
  return 0 == memcmp(img_out, check, IMG_SIZE*IMG_SIZE);
}
