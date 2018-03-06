PULPino has the following requirements:
* ModelSim in reasonably recent version (I tested it with version 10.5c)
* CMake >= 2.8.0, versions greater than 3.1.0 recommended due to support for ninja
* python2 >= 2.6
* ri5cy GNU toolchain

This `README.md` should sit in the `MS_Thesis` directory. If it is not, define the installation and working directory:
```
export ROOT_DIR=$PWD/..
```
If you run `ls $ROOD_DIR`, it should return `MS_Thesis`.

Install the ri5cy gnu toolchain and add the binaries to the `PATH` variable:
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
cp $ROOD_DIR/MS_Thesis/pulpino_apps_dift/wilander_testbed/mytest.c buffer_overflow.c
echo "add_application(buffer_overflow buffer_overflow.c)" > CMakeLists.txt
```

Then add `add_subdirectory(buffer_overflow)` at line 164 of `pulpino/sw/apps/CmakeLists.txt`.

Finally:
```
cd $ROOT_DIR/pulpino/sw/build
source cmake_configure.riscv.gcc.sh
make buffer_overflow.vsimc
```

In order to synthesize the design onto an FPGA board:
* replace the `pulpino/fpga/pulpino/tcl/run.tcl` and the `pulpino/fpga/pulpino/tcl/src_files.tcl` with the ones stored in `MS_Thesis/pulpino/fpga/pulpino/tcl`:
```
cp $ROOT_DIR/MS_Thesis/pulpino/fpga/pulpino/tcl/* $ROOT_DIR/pulpino/fpga/pulpino/tcl
```
* follow the guide written in https://github.com/pulp-platform/pulpino/tree/master/fpga
