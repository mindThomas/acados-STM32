# STM32-CMake-template


### Cloning the repository
If you have not already cloned this repository you do so by using the following command to include the tested acados version:
```
git clone --recursive https://github.com/mindThomas/acados-STM32.git
```

If you have already cloned it you need to run:
```
git submodule update --init --recursive
```

### Cloning the acados submodules
Enter the `acados` folder and run:
```
git submodule update --recursive --init
```

### Included HAL libraries
The HAL libraries are already included as shallow-cloned repositories which were added using (no need for running these commands - these are only for future reference):
```
git submodule add --depth 1 <repo-url> <path>
git config -f .gitmodules submodule.<path>.shallow true
```

### External HAL libraries
Ideally the HAL libraries should be downloaded and located elsewhere and pointed to with environment variables in your `.bashrc`.


## CMake Based
This project requires [CMake](https://cmake.org/download/) and the [arm-none-eabi-gcc toolchain](https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/gnu-rm/downloads) to be installed seperately.
This project was recently tested and used with the [GNU Arm Embedded Toolchain Version 9-2020-q2-update](https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/gnu-rm/downloads/9-2020-q2-update).
OpenOCD is used for flashing and debugging. The project has been tested with [xpack-openocd-0.11.0](https://xpack.github.io/blog/2021/03/15/openocd-v0-11-0-1-released/) on Ubuntu 18.04.

Add/set the path to your ARM toolchain folder (which contains the executable `arm-none-eabi-gcc` and more) in your `.bashrc`:
```
export ARM_TOOLCHAIN_DIR="/path/to/gcc-arm-none-eabi-xxx/bin
```

Good tutorials include:
- https://dev.to/younup/cmake-on-stm32-the-beginning-3766
- https://dev.to/younup/cmake-on-stm32-episode-2-build-with-clion-2lae

Please note that [CLion](https://www.jetbrains.com/clion/) can be used to load STM32CubeMX projects and convert them into CMake projects automatically: https://www.jetbrains.com/help/clion/embedded-development.html

Alternatively VS Code can be used: https://medium.com/@lixis630/getting-started-to-code-embedded-c-on-stm32-e90e7910b2c

## CMake Based (improved version)
See https://github.com/ObKo/stm32-cmake