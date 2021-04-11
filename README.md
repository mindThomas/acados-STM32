# acados-STM32
[acados](https://github.com/acados/acados) Non-linear MPC example (inverted pendulum control) using HPIPM on STM32H7 device (Cortex-M7 @ 480 MHz)

The repository contains two versions of the project:
1. The **STM32CubeIDE** version contains the IOC project (for STM32CubeMX) and the generated Eclipse project files to be loaded with STM32CubeIDE. In this project all the included project files are manually specified in the Project Configuration dialog of the Eclipse-based IDE.
2. The **CMakeBased** version contains the 

None of the projects includes the acados source files within their folder. Instead the projects relies on acados being pulled into this root folder. This can be done automatically by pulling the submodules of this repository (if you have already cloned it, otherwise read below):
```
git submodule update --init --recursive
```

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

## CMake Based
