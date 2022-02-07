# A Hardware Dynamic Information Flow Tracking Architecture for Low-level Security on a RISC-V Core

These guidelines were originally part of Christian Palmiero's Master Thesis at Politecnico di Torino (April 2018). Christian integrated DIFT on RI5CY which is a small 4-stage RISC-V core from ETH Zurich and University of Bologna. More details about the original cores are available at
* https://github.com/pulp-platform
* https://www.pulp-platform.org

Recently, Giuseppe Di Guglielmo integrated ESP Loosely-Coupled Accelerator into PULPino (SoC). The following sections describe how to instantiate a LCA as well.

## PULPino

PULPino is an open-source single-core microcontroller system, based on 32-bit RISC-V cores developed at ETH Zurich. PULPino is configurable to use either the RISCY (RI5CY ?) or the zero-riscy core.

## DIFT-Integration Steps for RI5CY

DIFT modifications for RI5CY are in the [repository](git@dev.sld.cs.columbia.edu:riscv-dift.git) of the SLD Group (Columbia University). The repository contains only the DIFT modifications to the core and must be integrated into the official RI5CY code. The following steps describe how to manually integrate Christian's DIFT extension to a certain revision ([7ad47f3761](https://github.com/pulp-platform/pulpino/tree/7ad47f3761db74a8f681d952e125664fd5abe71e)) of RI5CY. In the future, we should consider to mantain this code in a branch of RI5CY.

### Preliminaries

PULPino has the following requirements:
* ModelSim in reasonably recent version (I tested it with version 10.5c)
* CMake >= 2.8.0, versions greater than 3.1.0 recommended due to support for ninja
* python2 >= 2.6
* ri5cy GNU toolchain

This `README.md` is part of the [repository](git@dev.sld.cs.columbia.edu:riscv-dift.git) and should sit in the `MS_Thesis` directory. If it is not, please clone the repository first:
```
git clone git@github.com:sld-columbia/riscv-dift.git MS_Thesis
cd MS_Thesis
```

At this point, you can define your installation and working directory:
```
export ROOT_DIR=$PWD/..
```
If you run `ls $ROOD_DIR`, it should return `MS_Thesis`.

### Code Integration

Install the RI5CY Gnu toolchain and add the binaries to the `PATH` variable:
```
cd $ROOD_DIR
git clone https://github.com/pulp-platform/ri5cy_gnu_toolchain
cd ri5cy_gnu_toolchain
cp $ROOD_DIR/MS_Thesis/riscv_tools_delta/riscv_tools_delta.tar.gz .
make
PATH=$ROOT_DIR/ri5cy_gnu_toolchain/install/bin:$PATH
```

Clone the pulpino repository and to jump back to a specific commit:
```
git clone https://github.com/pulp-platform/pulpino
cd pulpino
git reset --hard 7ad47f3761db74a8f681d952e125664fd5abe71e
```

PULPino uses multiple git subrepositories. W.r.t. commit `7ad47f37`, there were some URL changes, thus it is necessary to update the `update-ips.py` script. The file `ips_list.yml` should be updated to some specific commits. Finally, to clone those subrepositores and update them to those specific commits:
```
git checkout e00d3c2809c29b8e0efdb73d7792b2a4f35e13ef update-ips.py
cp $ROOD_DIR/MS_Thesis/ips_list.yml .
./update-ips.py
```

Replace all the files and folders stored in the `pulpino/ips/riscv` folder with the ones stored in `MS_Thesis/pulpino/ips/ri5cy`:
```
cd ips/riscv
cp -r $ROOT_DIR/MS_Thesis/pulpino/ips/ri5cy/* .
```

Replace all the files and folders stored in the `pulpino/rtl` folder with the ones stored in `MS_Thesis/pulpino/rtl`:
```
cd ../../rtl
cp -r $ROOT_DIR/MS_Thesis/pulpino/rtl/* .
```

Replace the `qprintf.c` file stored in the `pulpino/sw/libs/string\_lib/src` folder with the ones stored in `MS_Thesis/pulpino/sw/libs/string\_lib/src`:
```
cd ../../pulpino/sw/libs/string_lib/src
cp $ROOT_DIR/MS_Thesis/pulpino/sw/libs/string_lib/src/qprintf.c .
```

Replace the `pulpino/vsim/tcl_files` and the `pulpino/vsim/vcompile` folders with the ones stored in `MS_Thesis/pulpino/vsim`:
```
cd ../../../../vsim
cp -r $ROOT_DIR/MS_Thesis/pulpino/vsim/* .
```

Add some Xilinx libraries for simulation to the current directory (`$ROOT_DIR/MS_Thesis/pulpino/vsim`):
```
wget http://espdev.cs.columbia.edu/dift-pulpino/xilinx_libs.tar.gz
tar xfz xilinx_libs.tar.gz
rm xilinx_libs.tar.gz
```

Open `pulpino/sw/ref/crt0.riscv.S` and substitute the `eret` instruction (line 238) with the `mret` instruction.

### Simulation

In order to run a simple "helloworld" application in ModelSim, execute the following commands:
```
cd $ROOT_DIR/pulpino/sw
mkdir build
cd build
cp $ROOT_DIR/MS_Thesis/pulpino/sw/build/cmake_configure.riscv.gcc.sh .
source cmake_configure.riscv.gcc.sh
make vcompile
make helloworld.vsimc
```

In order to add a new application, follow this guide:
* open the `pulpino/sw/apps/CmakeLists.txt` file, go to line 164 and add
```
add_subdirectory(new_app)
```
* `mkdir $ROOT_DIR/pulpino/sw/apps/new_app`
* `cd $ROOT_DIR/pulpino/sw/apps/new_app `
* create a `CMakeLists.txt` file with content
```
add_application(new_app new_app.c)
```
* create a new_app.c application file
* go to `$ROOT_DIR/pulpino/sw/build`
* execute
```
source cmake_configure.riscv.gcc.sh
```
* launch
```
make new_app.vsimc
```

Three applications can be used in order to evaluate the correctness of our security scheme:
* `$ROOT_DIR/MS_Thesis/pulpino_apps_dift/QPOP_bftpd/QPOP_bftpd.c`
* `$ROOT_DIR/MS_Thesis/pulpino_apps_dift/wilander_testbed/mytest.c`
* `$ROOT_DIR/MS_Thesis/pulpino_apps_dift/wu-ftpd/wu-ftpd.c`

For example:
```
cd $ROOT_DIR/pulpino/sw/apps
mkdir buffer_overflow
cd buffer_overflow
cp $ROOT_DIR/MS_Thesis/pulpino_apps_dift/wilander_testbed/mytest.c buffer_overflow.c
echo "add_application(buffer_overflow buffer_overflow.c)" > CMakeLists.txt
```

Then add `add_subdirectory(buffer_overflow)` at line 164 of `pulpino/sw/apps/CmakeLists.txt`.

Finally:
```
cd $ROOT_DIR/pulpino/sw/build
source cmake_configure.riscv.gcc.sh
make buffer_overflow.vsimc
```

## LCA-Integration Steps for PULPino (RI5CY)

Replace all the files and folders stored in the `pulpino/rtl` folder with the ones stored in `MS_Thesis/pulpino-lca/rtl`:
```
cd $ROOT_DIR/pulpino/rtl
cp -r $ROOT_DIR/MS_Thesis/pulpino-lca/rtl/* .
```

In order to add the application running the LCA example, follow this guide:
* open the `pulpino/sw/apps/CmakeLists.txt` file, go to line 164 and add
```
add_subdirectory(alu_accelerator)
```
* copy the the application `alu_accelerator` in the folder `pulpino/sw/apps` from `MS_Thesis/pulpino-lca/sw`
```
cd $ROOT_DIR/pulpino/sw/apps
cp -r $ROOT_DIR/MS_Thesis/pulpino-lca/sw/apps/alu_accelerator .
```

## FPGA Deployment

In order to synthesize the design onto an FPGA board:
* replace the `pulpino/fpga/pulpino/tcl/run.tcl` and the `pulpino/fpga/pulpino/tcl/src_files.tcl` with the ones stored in `MS_Thesis/pulpino/fpga/pulpino/tcl`:
```
cp $ROOT_DIR/MS_Thesis/pulpino/fpga/pulpino/tcl/* $ROOT_DIR/pulpino/fpga/pulpino/tcl
```

*Note to the reader:* The following steps are from the [official PULPino repository](https://github.com/pulp-platform/pulpino/tree/master/fpga) and have been tested and here reported for your convenience.

Set the environment variable `BOARD` to `zedboard`. In the Bash this means

```
export BOARD="zedboard"
```

This environment variable has to be set during compilation of all FPGA related components. The components that are affected by the BOARD variable are:
* pulpemu
* u-boot
* devicetree
* spiloader

### Requirements

This synthesis flow has been tested with `Vivado 2015.1` on CentOS 7, there is no guarantee that it is going to work with any other version without modifications to the scripts.

For convenience reasons it is best to connect the ZedBoard to your local network. This way you can easily transfer files from your host computer to the Linux running on the ARM cores of the ZYNQ.

### Get Started

1. Make sure you have the Vivado toolchain and the Xilinx SDK toolchain in your PATH before continuing. The Vivado toolchain is required to generate the bitstream, while the SDK contains the ARM compiler that is used for cross-compiling linux and applications. For example:
```
source /tools/Xilinx/Vivado/2015.1/settings64.sh
```

2. Type `make all` in the `pulpino/fpga` directory. This builds the FPGA bitstream for the ZedBoard, downloads and compiles `linux` and `u-boot`, prepares the `fsbl` and `devicetree`, downloads and compiles `buildroot` and builds the `boot.bin` image for booting the ZYNQ.
```
cd $ROOT_DIR/pulpino/fpga
make
```

3. Prepare the SD card and the ZedBoard for booting via SD card. To prepare the card, follow the [Xilinx guide](http://www.wiki.xilinx.com/Prepare+Boot+Medium).

4. Copy the `BOOT.BIN`, `uImage` and `devicetree.dtb` files to the first partition of the SD card. Those files can be found inside the `pulpino/fpga/sw/sd_image` folder.
```
sudo mount /dev/sdXX /mnt/sd/boot
sudo cp $ROOT_DIR/pulpino/fpga/sw/sd_image/BOOT.BIN /mnt/sd/boot
sudo cp $ROOT_DIR/pulpino/fpga/sw/sd_image/uImage /mnt/sd/boot
sudo cp $ROOT_DIR/pulpino/fpga/sw/sd_image/devicetree.dtb /mnt/sd/boot
sudo umount /mnt/sd/boot
```

5. Extract the content of the `pulpino/fpga/sw/sd_image/rootfs.tar` archive and put it on the second partition of the SD card. You are ready now:
```
sudo mount /dev/sdXY /mnt/sd/root
sudo sudo tar xvf $ROOT_DIR/pulpino/fpga/sw/sd_image/rootfs.tar -C /mnt/sd/root
sudo umount /mnt/sd/root
```

6. Configure the Zedboard jumpers to boot from SD card:
```
JP6 shorted

JP7  [MODE0] - GND
JP8  [MODE1] - GND
JP9  [MODE2] - 3V3
JP10 [MODE3] - 3V3
JP11 [MODE4] - GND
```

6. Put the SD card into the ZedBoard and boot the system. You can use minicom or any other terminal emulator tool to communicate with the UART of the ZedBoard.
```
zynq-boot> boot
```

7. You should now be able to login to the ZYNQ and have a fully working Linux running on it.

8. To be able to login to Linux via ssh, you have to make sure that Linux is able to access the local network. By default it will try to get an IP address via DHCP. You can check with `ifconfig` and friends if your device has gotten an IP address and use it to connect to it via a host.

9. In order to login use the following credentials:
```
username: root
password: pulp
```

The `boot.bin` and `rootfs.tar` files can be found under the folder `sw/sd_image`.


### Running applications on PULPino

1. Make sure you have a fully working Linux running on the ZYNQ.

2. Currently the only method to load a program into the PULPino system is via SPI. Linux uses its SPI master to communicate with PULPino's SPI slave and writes directly into the instruction and data memory of PULPino. The spiload program which can be found under sw/apps/spiload takes care of this.

3. Compile the spiload application for the ZYNQ. Just type `make` inside the `pulpino/fpga/sw/apps/spiload` folder.
```
cd $ROOT_DIR/pulpino/fpga/sw/apps/spiload
make
```

4. Transfer this program to the ZYNQ. We suggest using scp, but any other method works as well of course.

5. Now you need to compile the program you want to run on PULPino. Please take a look at the README in pulpino/sw directory which explains how applications can be compiled using cmake. Use this flow to compile your application. We need the spi_stim.txt file from the applications slm_files subfolder.

6. Transfer the spi_stim.txt file to the ZYNQ.

7. Run the spiload application on the ZYNQ like this
```
./spiload ./spi_stim.txt
```
This resets PULPino, transfers the application to the memories of PULPino and starts it.


As an alternative, there is a cmake target for running applications on fpga directly. Just call
```
make applicationName.fpga
```

You need to be able to ssh into the Linux running on the ZYNQ fpga (e.g. using public keys) and you need to setup the environment variable `$FPGA_HOSTNAME`. Take a look at the script `./sw/utils/run-on-fpga.sh` to understand how it works.

### stdout via printf on PULPino

When PULPino is run on the FPGA, it transfers all output via printf via UART to the ARM host processor in the ZYNQ. To display it, either use a console program like minicom to read directly from the serial port, or specify a timeout when using `spiload`. `spiload` will connect to the serial port and display everything that PULPino sends via UART until the timeout expires.

### Connected peripherals & communication with PULPino

PULPino includes a set of built-in peripherals like SPI, UART and GPIOs. The SPI slave peripheral is connected to the SPI master of the ZYNQ, thus it is possible to directly write to any memory address of PULPino from outside.

UART is connected to UART0 of the ZYNQ and is available under /dev/ttyPS0 in linux.

Some of GPIO pins are connected to LEDs, switches and buttons on the ZedBoard.

Specifically the following is connected:

```
PULPino GPIO pin  0: SW 0
PULPino GPIO pin  1: SW 1
PULPino GPIO pin  2: SW 2
PULPino GPIO pin  3: SW 3
PULPino GPIO pin  4: SW 4
PULPino GPIO pin  5: SW 5
PULPino GPIO pin  6: SW 6
PULPino GPIO pin  7: SW 7

PULPino GPIO pin  8: LD 0
PULPino GPIO pin  9: LD 1
PULPino GPIO pin 10: LD 2
PULPino GPIO pin 11: LD 3
PULPino GPIO pin 12: LD 4
PULPino GPIO pin 13: LD 5
PULPino GPIO pin 14: LD 6
PULPino GPIO pin 15: LD 7

PULPino GPIO pin 16: BTNC
PULPino GPIO pin 17: BTND
PULPino GPIO pin 18: BTNL
PULPino GPIO pin 19: BTNR
PULPino GPIO pin 20: BTNU
```
