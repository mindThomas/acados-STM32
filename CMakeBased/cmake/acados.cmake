set(BUILD_SHARED_LIBS OFF)
set(MF PANELMAJ)
set(HPIPM_TARGET GENERIC)
set(BLASFEO_TARGET GENERIC)
set(EXT_DEP ON)
set(TARGET GENERIC) # Setting this target is apparently not picked up by Blasfeo when you run CMake the first time
set(LA HIGH_PERFORMANCE)
set(BLASFEO_EXAMPLES OFF)

add_definitions(-D__STM32__) # replace by add_compile_definitions ??
add_definitions(-DMEASURE_TIMINGS)
add_compile_definitions(K_MAX_STACK=300)

include_directories(../acados)
include_directories(../acados/external)
include_directories(../acados/interfaces)

add_subdirectory(../acados  "lib/acados")
target_compile_options(acados PRIVATE -O3)
target_compile_options(blasfeo PRIVATE -O3)
target_compile_options(hpipm PRIVATE -O3)