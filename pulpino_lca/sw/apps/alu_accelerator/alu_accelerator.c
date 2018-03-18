#include <stdio.h>

#define APB_BASE_ADDRESS 0x1A118000
//#define AXI_BASE_ADDRESS 0x00200000
#define AXI_BASE_ADDRESS 0x00100F00

#define START_CMD        0x01

#define OP_REG           0x00
#define NROWS_REG        0x04
#define NCOLS_REG        0x08
#define OFFSET_DIN1_REG  0x0c
#define OFFSET_DIN2_REG  0x10
#define OFFSET_DOUT_REG  0x14

#define CSR_REG          0x18
#define DONE_REG         0x1c

/* Reference */
unsigned char regs[256] = {0x0, 0x0, 0x0, 0x0,
                           0x0, 0x0, 0x0, 0x0,
                           0x0, 0x0, 0x0, 0x0,
                           0x0, 0x0, 0x0, 0x0};

unsigned read_reg(unsigned offset)
{
    unsigned *reg = (unsigned *)(APB_BASE_ADDRESS + offset);
    unsigned value = *reg;
    return value;
}

void write_reg(unsigned offset, unsigned value)
{
    unsigned *reg = (unsigned *)(APB_BASE_ADDRESS + offset);
    *reg = value;
}

void exec_accelerator(unsigned op, unsigned nrows, unsigned ncols, unsigned offset_din1, unsigned offset_din2, unsigned offset_dout, unsigned *errors)
{
    unsigned i;
    unsigned done;

    // Reset memory
    printf("INFO: reset memory\n");


    for (i = 0; i < 3*nrows*ncols; i++)
    {
        unsigned *data_ptr = (unsigned*)(AXI_BASE_ADDRESS + (i*sizeof(unsigned)));
        *(data_ptr) = 0x00000000;
        //printf ("mem[0x%08x]: 0x%08x\n", data_ptr, *data_ptr);
    }

    // Init memory
    printf("INFO: init memory\n");

    {
        unsigned *data_ptr = (unsigned*)(AXI_BASE_ADDRESS);
        *(data_ptr + 0) =  0x00001000;
        *(data_ptr + 1) =  0x00002000;
        *(data_ptr + 2) =  0x00003000;
        *(data_ptr + 3) =  0x00004000;
        *(data_ptr + 4) =  0x00005000;
        *(data_ptr + 5) =  0x00006000;
        *(data_ptr + 6) =  0x00007000;
        *(data_ptr + 7) =  0x00008000;
        *(data_ptr + 8) =  0x00009000;
        *(data_ptr + 9) =  0x0000a000;
        *(data_ptr + 10) = 0x0000b000;
        *(data_ptr + 11) = 0x0000c000;

        *(data_ptr + 12) = 0x00000800;
        *(data_ptr + 13) = 0x00000800;
        *(data_ptr + 14) = 0x00000800;
        *(data_ptr + 15) = 0x00000800;
        *(data_ptr + 16) = 0x00000400;
        *(data_ptr + 17) = 0x00000400;
        *(data_ptr + 18) = 0x00000400;
        *(data_ptr + 19) = 0x00000400;
        *(data_ptr + 20) = 0x00000200;
        *(data_ptr + 21) = 0x00000200;
        *(data_ptr + 22) = 0x00000200;
        *(data_ptr + 23) = 0x00000200;

        *(data_ptr + 24) = 0xf0f0f0f0;
        *(data_ptr + 25) = 0xf0f0f0f0;
        *(data_ptr + 26) = 0xf0f0f0f0;
        *(data_ptr + 27) = 0xf0f0f0f0;
        *(data_ptr + 28) = 0xf0f0f0f0;
        *(data_ptr + 29) = 0xf0f0f0f0;
        *(data_ptr + 30) = 0xf0f0f0f0;
        *(data_ptr + 31) = 0xf0f0f0f0;
        *(data_ptr + 32) = 0xf0f0f0f0;
        *(data_ptr + 33) = 0xf0f0f0f0;
        *(data_ptr + 34) = 0xf0f0f0f0;
        *(data_ptr + 35) = 0xf0f0f0f0;
    }

    // Dump memory
    printf("INFO: dump memory after memory init\n");
    unsigned *data_ptr = (unsigned*)(AXI_BASE_ADDRESS);
    for (i = 0; i < 3*nrows*ncols; i++)
    {
        unsigned data = *(data_ptr);
        printf ("INFO:    mem[0x%08x]: 0x%08x\n", data_ptr, data);

        data_ptr++;
    }

    printf("INFO: configure accelerator\n");
    printf("INFO:    op          (0x%08x, %u)\n", (APB_BASE_ADDRESS + OP_REG), op);
    printf("INFO:    nrows       (0x%08x, %u)\n", (APB_BASE_ADDRESS + NROWS_REG), nrows);
    printf("INFO:    ncols       (0x%08x, %u)\n", (APB_BASE_ADDRESS + NCOLS_REG), ncols);
    printf("INFO:    offset_din1 (0x%08x, 0x%08x)\n", (APB_BASE_ADDRESS + OFFSET_DIN1_REG), AXI_BASE_ADDRESS + (offset_din1*sizeof(unsigned)));
    printf("INFO:    offset_din2 (0x%08x, 0x%08x)\n", (APB_BASE_ADDRESS + OFFSET_DIN2_REG), AXI_BASE_ADDRESS + (offset_din2*sizeof(unsigned)));
    printf("INFO:    offset_dout (0x%08x, 0x%08x)\n", (APB_BASE_ADDRESS + OFFSET_DOUT_REG), AXI_BASE_ADDRESS + (offset_dout*sizeof(unsigned)));
    printf("INFO:    csr         (0x%08x, 0x%x)\n", (APB_BASE_ADDRESS + CSR_REG), START_CMD);

    write_reg(OP_REG, op);
    write_reg(NROWS_REG, nrows);
    write_reg(NCOLS_REG, ncols);
    write_reg(OFFSET_DIN1_REG, AXI_BASE_ADDRESS + (offset_din1*sizeof(unsigned)));
    write_reg(OFFSET_DIN2_REG, AXI_BASE_ADDRESS + (offset_din2*sizeof(unsigned)));
    write_reg(OFFSET_DOUT_REG, AXI_BASE_ADDRESS + (offset_dout*sizeof(unsigned)));

    printf("INFO: accelerator exec\n");
    write_reg(CSR_REG, START_CMD);

    done = 0x0;
    do
    {
        done = read_reg(DONE_REG);
    } while (done != 0x1);

    printf("INFO: dump memory after accelerator exec\n");
    for (i = 0; i < 3*nrows*ncols; i++)
    {
        unsigned *data_ptr = (unsigned*)(AXI_BASE_ADDRESS + (i*sizeof(unsigned)));
        unsigned data = *(data_ptr);
        printf ("INFO:    mem[0x%08x]: 0x%08x\n", data_ptr, data);
    }
}



int main()
{
    unsigned i, errors = 0;
    printf("INFO: ALU device\n");
    printf("INFO:    - APB @ 0x%08x\n", APB_BASE_ADDRESS);
    printf("INFO:    - AXI @ 0x%08x\n", AXI_BASE_ADDRESS);

    exec_accelerator('+', 3, 4, 0, 12, 24, &errors);

    if (errors > 0)
    {
        printf("ERROR: validation failed! (%d errors)\n", errors);
        return (1);
    } else {
        printf("INFO: validation passed!\n");
        return (0);
    }

    return (0);
}
