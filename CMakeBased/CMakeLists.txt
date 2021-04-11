# Copyright (C) 2021- Thomas Jespersen, TKJ Electronics. All rights reserved.
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the MIT License
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the MIT License for further details.
#
# Contact information
# ------------------------------------------
# Thomas Jespersen, TKJ Electronics
# Web      :  http://www.tkjelectronics.dk
# e-mail   :  thomasj@tkjelectronics.dk
# ------------------------------------------

set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_VERSION 1)
cmake_minimum_required(VERSION 3.15.3)

# Set Toolchain: https://cmake.org/cmake/help/latest/manual/cmake-toolchains.7.html#cross-compiling
# Specify cross compilers and tools
set(CMAKE_TOOLCHAIN_FILE "../cmake/arm-none-eabi-gcc.cmake")
# set(CMAKE_C_COMPILER $ENV{ARM_TOOLCHAIN_DIR}/arm-none-eabi-gcc)
# set(CMAKE_CXX_COMPILER $ENV{ARM_TOOLCHAIN_DIR}/arm-none-eabi-g++)
# set(CMAKE_ASM_COMPILER  $ENV{ARM_TOOLCHAIN_DIR}/arm-none-eabi-gcc)
# set(CMAKE_AR $ENV{ARM_TOOLCHAIN_DIR}/arm-none-eabi-ar)
# set(CMAKE_OBJCOPY $ENV{ARM_TOOLCHAIN_DIR}/arm-none-eabi-objcopy)
# set(CMAKE_OBJDUMP $ENV{ARM_TOOLCHAIN_DIR}/arm-none-eabi-objdump)
# set(SIZE $ENV{ARM_TOOLCHAIN_DIR}/arm-none-eabi-size)
# set(CMAKE_SIZE_UTIL $ENV{ARM_TOOLCHAIN_DIR}/arm-none-eabi-size)
# set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

# project settings
project(ACADOS-STM32)
#project(ACADOS-STM32 C CXX ASM)

set(CPU cortex-m7)
set(LINKER_SCRIPT ${CMAKE_SOURCE_DIR}/linker/STM32H743ZITx_FLASH.ld)

enable_language(CXX C ASM)

#add_definitions(-std=gnu11)
set(CMAKE_C_STANDARD 11) # 11 instead of 99 since it is needed by heap functions in sysmem.c
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS ON) # ON instead of OFF since we need '-std=gnu11' (see https://community.st.com/s/question/0D50X0000A4oPvx/error-building-file-cubemxsyscallsc-invoking-mcu-gcc-compiler)

## Add support for C++11, C++14 or C++17
#add_definitions(-std=c++11)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF) # use -std=c++14 instead of -std=gnu++14

# uncomment to mitigate c++17 absolute addresses warnings
#set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-register")

# build type
if(CMAKE_BUILD_TYPE STREQUAL "")
  unset(CMAKE_BUILD_TYPE CACHE) # no ambiguity
endif()
set(CMAKE_BUILD_TYPE "Debug" CACHE STRING "RelWithDebInfo, Release or Debug")

# Add compile flags according to build mode
if ("${CMAKE_BUILD_TYPE}" STREQUAL "Release")
    message(STATUS "Maximum optimization for speed")
    add_compile_options(-Ofast)
elseif ("${CMAKE_BUILD_TYPE}" STREQUAL "RelWithDebInfo")
    message(STATUS "Maximum optimization for speed, debug info included")
    add_compile_options(-Ofast -g)
elseif ("${CMAKE_BUILD_TYPE}" STREQUAL "MinSizeRel")
    message(STATUS "Maximum optimization for size")
    add_compile_options(-Os)
else ()
    message(STATUS "Minimal optimization, debug info included")
    add_compile_options(-Og -g)
endif ()

# Add include directories
include_directories(include)
include_directories(src/c_generated_code)
include_directories(src/c_generated_code/pendulum_ode_model)
include_directories(include/blasfeo/include)
include_directories(hal/stm32h7xx_hal_driver/Inc)
include_directories(hal/stm32h7xx_hal_driver/Inc/Legacy)
include_directories(hal/cmsis_device_h7/Include)
include_directories(hal/cmsis_core/Include)

file(GLOB_RECURSE SOURCES "startup/*.*" 
                          "src/*.*" 
                          "src/c_generated_code/*.*" 
                          "src/c_generated_code/pendulum_ode_model/*.*" 
                          "hal/stm32h7xx_hal_driver/Src/*.*"                          
    )

# Remove '*template.c' files
list(FILTER SOURCES EXCLUDE REGEX "template.c$")

#Uncomment for hardware floating point
add_compile_definitions(ARM_MATH_CM7)#;ARM_MATH_MATRIX_CHECK;ARM_MATH_ROUNDING)
add_compile_options(-mfloat-abi=hard -mfpu=fpv5-d16) # STM32F4 = fpv4-sp-d16
add_link_options(-mfloat-abi=hard -mfpu=fpv5-d16)

#Uncomment for software floating point
#add_compile_options(-mfloat-abi=soft)

add_compile_definitions(__FPU_PRESENT=1)
add_compile_definitions(USE_C99_MATH)

add_compile_options(-mcpu=${CPU} -mthumb -mthumb-interwork)
add_compile_options(-ffunction-sections -fdata-sections -fno-common -fmessage-length=0)
# target_compile_options(${EXECUTABLE} PRIVATE
#         -mcpu=cortex-m4
#         -mthumb
#         -mfpu=fpv4-sp-d16
#         -mfloat-abi=hard
#
#         -fdata-sections
#         -ffunction-sections
#
#         -Wall -Wextra -Wpedantic # Be verbose when compiling
#
#         $<$<CONFIG:Debug>:-Og>
#         )

# $<$<CONFIG:Debug>:-Og>  is a generator-expression.
# If CONFIG is Debug, then add option -Og, otherwise add nothing.


add_definitions(-DUSE_HAL_DRIVER 
                -DSTM32H743xx                
                #-DDEBUG
               )
# target_compile_definitions(${EXECUTABLE} PRIVATE
#         -DUSE_HAL_DRIVER
#         -DSTM32F413xx
#         )

add_link_options(-Wl,--gc-sections,--print-memory-usage)
add_link_options(-Wl,-Map=${PROJECT_BINARY_DIR}/${PROJECT_NAME}.map)
add_link_options(-mcpu=${CPU} -mthumb -mthumb-interwork)
add_link_options(-T ${LINKER_SCRIPT})
add_link_options(-specs=nano.specs)
add_link_options(-Wl,--start-group -lc -lm -Wl,--end-group)
# target_link_options(${EXECUTABLE} PRIVATE
#         -T${CMAKE_SOURCE_DIR}/BSP/STM32F413ZHTx_FLASH.ld
#         -mcpu=cortex-m4
#         -mthumb
#         -mfpu=fpv4-sp-d16
#         -mfloat-abi=hard
#         -specs=nano.specs
#         -lc
#         -lm
#         -lnosys
#         -Wl,-Map=${PROJECT_NAME}.map,--cref
#         -Wl,--gc-sections
#         )

# Set Compiler-stage specific flags
#set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${COMMON_COMPILE_FLAGS} ${WARNING_FLAGS} ${DEFINITIONS}")
#set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${COMMON_COMPILE_FLAGS} ${WARNING_FLAGS} ${DEFINITIONS}")
#set(CMAKE_ASM_FLAGS "${CMAKE_ASM_FLAGS} ${COMMON_COMPILE_FLAGS}")
#set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -T ${LINKER_SCRIPT}")

# Add ACADOS library
include(cmake/acados.cmake)

# Compile firmware
add_executable(${PROJECT_NAME}.elf ${SOURCES} ${LINKER_SCRIPT})
target_link_libraries(${PROJECT_NAME}.elf acados blasfeo hpipm)

set(HEX_FILE ${PROJECT_BINARY_DIR}/${PROJECT_NAME}.hex)
set(BIN_FILE ${PROJECT_BINARY_DIR}/${PROJECT_NAME}.bin)

# Remember to remove the map file when calling 'make clean'
set_property(
        TARGET ${PROJECT_NAME}.elf
        APPEND
        PROPERTY ADDITIONAL_CLEAN_FILES ${PROJECT_BINARY_DIR}/${PROJECT_NAME}.map # add the map file to be removed when running 'make clean'
)

# # Print executable size
add_custom_command(TARGET ${PROJECT_NAME}.elf
        POST_BUILD
        COMMAND echo "\n"
        COMMAND ${CMAKE_SIZE_UTIL} "$<TARGET_FILE:${PROJECT_NAME}.elf>")

# # Convert into HEX after finishing building
# add_custom_command(TARGET ${PROJECT_NAME}.elf 
#         POST_BUILD
#         COMMAND ${CMAKE_OBJCOPY} -O ihex $<TARGET_FILE:${PROJECT_NAME}.elf> ${HEX_FILE}
#         COMMAND ${CMAKE_OBJCOPY} -O binary $<TARGET_FILE:${PROJECT_NAME}.elf> ${BIN_FILE}
#         COMMENT "Building ${HEX_FILE}
# Building ${BIN_FILE}")

# Convert into HEX with 'make hex'
add_custom_target(hex
    COMMAND ${CMAKE_OBJCOPY} -O ihex $<TARGET_FILE:${PROJECT_NAME}.elf> ${HEX_FILE}
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    DEPENDS $<TARGET_FILE:${PROJECT_NAME}.elf>
)
set_property(
        TARGET ${PROJECT_NAME}.elf
        APPEND
        PROPERTY ADDITIONAL_CLEAN_FILES ${HEX_FILE} # add the hex file to be removed when running 'make clean'
)

# Convert into BIN with 'make bin'
add_custom_target(bin
    COMMAND ${CMAKE_OBJCOPY} -O ihex $<TARGET_FILE:${PROJECT_NAME}.elf> ${BIN_FILE}
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    DEPENDS $<TARGET_FILE:${PROJECT_NAME}.elf>
)
set_property(
        TARGET ${PROJECT_NAME}.elf
        APPEND
        PROPERTY ADDITIONAL_CLEAN_FILES ${BIN_FILE} # add the bin file to be removed when running 'make clean'
)

# Targets for debugging/flashing
add_custom_target(openocd
    COMMAND openocd -f ${PROJECT_SOURCE_DIR}/cfg/openocd.cfg -c "gdb_memory_map disable"
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    DEPENDS $<TARGET_FILE:${PROJECT_NAME}.elf>
)

# Flash the previously built firmware to the target (openocd needs to run in background)
add_custom_target(flash_with_gdb
    #COMMAND ${CMAKE_GDB} --batch -x ${PROJECT_SOURCE_DIR}/cfg/gdb.cfg -ex 'monitor program ${HEX_FILE} verify reset'
    COMMAND ${CMAKE_GDB} --batch -x ${PROJECT_SOURCE_DIR}/cfg/gdb.cfg 
                                 -ex 'monitor reset halt'
                                 #-ex 'monitor stm32h7x mass_erase 0'
                                 -ex 'monitor flash write_image $<TARGET_FILE:${PROJECT_NAME}.elf>'
                                 -ex 'monitor reset run'
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    DEPENDS $<TARGET_FILE:${PROJECT_NAME}.elf>
)

add_custom_target(flash
    #COMMAND ${CMAKE_GDB} --batch -x ${PROJECT_SOURCE_DIR}/cfg/gdb.cfg -ex 'monitor program ${HEX_FILE} verify reset'
    COMMAND openocd -f ${PROJECT_SOURCE_DIR}/cfg/openocd.cfg -c "gdb_memory_map disable"
                                 -c "init" 
                                 -c "targets"
                                 -c "reset halt"
                                 #-c "load_image $<TARGET_FILE:${PROJECT_NAME}.elf>"
                                 -c "flash write_image erase $<TARGET_FILE:${PROJECT_NAME}.elf>"
                                 #-c "flash write_image erase ${BIN_FILE} 0x08000000"
                                 -c "reset halt"
                                 -c "verify_image $<TARGET_FILE:${PROJECT_NAME}.elf>"
                                 -c "reset run"
                                 -c "exit" # exit, resume or shutdown
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    DEPENDS $<TARGET_FILE:${PROJECT_NAME}.elf>
)

# Start debugging with GDB (openocd needs to run in background)
add_custom_target(gdb
    COMMAND ${CMAKE_GDB} -x ${PROJECT_SOURCE_DIR}/cfg/gdb.cfg $<TARGET_FILE:${PROJECT_NAME}.elf>
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    DEPENDS $<TARGET_FILE:${PROJECT_NAME}.elf>
)