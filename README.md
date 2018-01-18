PULPino has the following requirements:
* ModelSim in reasonably recent version (I tested it with version 10.5c)
* CMake >= 2.8.0, versions greater than 3.1.0 recommended due to support for ninja
* python2 >= 2.6
* ri5cy GNU toolchain

Install the ri5cy gnu toolchain and add the binaries to the PATH variable:
```
git clone https://github.com/pulp-platform/ri5cy_gnu_toolchain
cd ri5cy_gnu_toolchain
cp your_path/MS_Thesis/riscv_tools_delta/riscv_tools_delta.tar.gz .
make
PATH=your_path/ri5cy_gnu_toolchain/install/bin:$PATH
```

Clone the pulpino repository and to jump back to a specific commit:
```
git clone https://github.com/pulp-platform/pulpino
cd pulpino
git reset --hard 7ad47f3761db74a8f681d952e125664fd5abe71e
```

PULPino uses multiple git subrepositories. To clone those subrepositores and update them, use:
```
./update-ips.py
```

Replace all the files and folders stored in the pulpino/ips/riscv folder with the ones stored in MS\_Thesis/pulpino/ips/ri5cy:
```
cd ips/riscv
cp -r your_path/MS_Thesis/pulpino/ips/ri5cy/* .
```

Replace all the files and folders stored in the pulpino/rtl folder with the ones stored in MS\_Thesis/pulpino/rtl:
```
cd ../../rtl
cp -r your_path/MS_Thesis/pulpino/rtl/* .
```

Replace the qprintf.c file stored in the pulpino/sw/libs/string\_lib/src folder with the ones stored in MS\_Thesis/pulpino/sw/libs/string\_lib/src:
```
cd ../../pulpino/sw/libs/string_lib/src
cp your_path/MS_Thesis/pulpino/sw/libs/string_lib/src/qprintf.c .
```

Replace the pulpino/vsim/tcl\_files and the pulpino/vsim/vcompile folders with the ones stored in MS\_Thesis/pulpino/vsim:
```
cd ../../../../vsim
cp -r your_path/MS_Thesis/pulpino/vsim/* .
```

```
wget http://espdev.cs.columbia.edu/dift-pulpino/xilinx_libs.tar.gz
tar xfz xilinx_libs.tar.gz
rm xilinx_libs.tar.gz
```

Open pulpino/sw/ref/crt0.riscv.S and substitute the "eret" instruction (line 238) with the "mret" instruction.

In order to run a simple "helloworld" application in ModelSim, execute the following commands:
```
cd your_path/pulpino/sw
mkdir build
cd build
cp path/MS_Thesis/pulpino/sw/build/cmake_configure.riscv.gcc.sh .
source cmake_configure.riscv.gcc.sh
make vcompile
make helloworld.vsimc
```

In order to add a new application, follow this guide:
* open the pulpino/sw/apps/CmakeLists.txt file, go to line 164 and add
```
add_subdirectory(new_app)
```
* ```mkdir your_path/pulpino/sw/apps/new_app```
* ``` cd your_path/pulpino/sw/apps/new_app ```
* create a CMakeLists.txt file with content
```
add_application(new_app new_app.c)
```
* create a new_app.c application file
* go to your_path/pulpino/build
* execute
```
source cmake_configure.riscv.gcc.sh
```
* launch
```
make new_app.vsimc
```

Three applications can be used in order to evaluate the correctness of our security scheme:
* your_path/MS_Thesis/pulpino_apps_dift/QPOP_bftpd/QPOP_bftpd.c
* your_path/MS_Thesis/pulpino_apps_dift/wilander_testbed/mytest.c
* your_path/MS_Thesis/pulpino_apps_dift/wu-ftpd/wu-ftpd.c

In order to synthesize the design onto an FPGA board:
* replace the pulpino/fpga/pulpino/tcl/run.tcl and the  pulpino/fpga/pulpino/tcl/src_files.tcl with the ones stored in MS\_Thesis/pulpino/fpga/pulpino/tcl:
```
cp your_path/MS_Thesis/pulpino/fpga/pulpino/tcl/* your_path/pulpino/fpga/pulpino/tcl
```
* follow the guide written in https://github.com/pulp-platform/pulpino/tree/master/fpga
