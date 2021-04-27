# acados-STM32
[acados](https://github.com/acados/acados) Non-linear MPC example (inverted pendulum control) using HPIPM on STM32H7 device (Cortex-M7 @ 400 MHz)

The repository contains two versions of the project:
1. The **STM32CubeIDE** version contains an IOC project (for STM32CubeMX) and the generated Eclipse project files to be loaded with STM32CubeIDE. In this project all the included project files are manually specified in the Project Configuration dialog of the Eclipse-based IDE.
2. The **CMakeBased** version contains a CMake project for the STM32 device which configures both the toolchain and includes acados and its dependencies through its CMake configuration system. Please read below how to configure the ARM toolchain necessary to compile the CMake project.

None of the projects includes the acados source files within their folder. Instead the projects relies on acados being pulled into this root folder. This can be done automatically by pulling the submodules of this repository (if you have already cloned it, otherwise read below):
```
git submodule update --init --recursive
```

Note that the example project tested here uses `HPIPM` and `QPOASES` or any of the other supported solver are neither included in the compilation unit nor have they been tested.

### Cloning the repository
If you have not already cloned this repository you do so by using the following command to include the tested acados version:
```
git clone --recursive https://github.com/mindThomas/acados-STM32.git
```

### Cloning the acados submodules
Enter the `acados` folder and run:
```
git submodule update --recursive --init
```

## STM32CubeIDE
Install [STM32CubeIDE](https://www.st.com/en/development-tools/stm32cubeide.html) v1.4.0 or later and load the project by selecting `File -> Import` and then load the project as `Existing Projects into Workspace`.

In the Eclipse-based project loaded in STM32CubeIDE all files to compile from the different libraries (`acados`, `blasfeo` and `hpipm`) has been manually selected according to the example project.

## CMake Based
This project requires [CMake](https://cmake.org/download/) and the [arm-none-eabi-gcc toolchain](https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/gnu-rm/downloads) 3.15 or later to be installed seperately.
This project has been tested with the [GNU Arm Embedded Toolchain Version 9-2020-q2-update](https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/gnu-rm/downloads/9-2020-q2-update).
OpenOCD is used for flashing and debugging. The project has been tested with [xpack-openocd-0.11.0](https://xpack.github.io/blog/2021/03/15/openocd-v0-11-0-1-released/) on Ubuntu 18.04.

In the CMake based project all settings and which files to build are loaded automatically through the CMake build system based on the target configuration.

Add/set the path to your ARM toolchain folder (which contains the executable `arm-none-eabi-gcc` and more) in your `.bashrc`:
```
export ARM_TOOLCHAIN_DIR="/path/to/gcc-arm-none-eabi-xxx/bin"
```

Within a terminal navigate to the `CMakeBased` folder and create a build folder and run the CMake operation twice (this is required the first time for the libraries to pick up the `GENERIC` target setting).
```
mkdir build
cd build
cmake ..
cmake ..
make -j
```

You can now flash the code into a connected board by executing:
`make flash`

Alternatively you can open the project in CLion or other compatible IDE which can load CMake projects.
To debug with CLion you just have to add an `OpenOCD Download & Run` configuration under `Run/Debug Configurations` where you set the following:

- Target: `ACADOS-STM32.elf`
- Executable: `ACADOS-STM32.elf`
- GDB: either the `Bundled GDB` or the `arm-none-eabi-gdb` executable
- Board config file: [CMakeBased/cfg/openocd.cfg](CMakeBased/cfg/openocd.cfg)
- GDB port: 3333 (default)
- Telnet port: 4444 (default)
- Download: Updated Only (default)
- Reset: Init (default)