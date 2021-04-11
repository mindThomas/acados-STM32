#ifndef LA_HIGH_PERFORMANCE
#define LA_HIGH_PERFORMANCE
#endif

#ifndef MF_PANELMAJ
#define MF_PANELMAJ
#endif

#ifndef EXT_DEP
#define ON 1
#define OFF 0
#if ON==ON
#define EXT_DEP
#endif
#undef ON
#undef OFF
#endif

#ifndef BLAS_API
#define ON 1
#define OFF 0
#if OFF==ON
#define BLAS_API
#endif
#undef ON
#undef OFF
#endif

#ifndef FORTRAN_BLAS_API
#define ON 1
#define OFF 0
#if OFF==ON
#define FORTRAN_BLAS_API
#endif
#undef ON
#undef OFF
#endif
