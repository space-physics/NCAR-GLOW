if(CMAKE_BUILD_TYPE STREQUAL Debug)
  add_compile_options(-g -O0)
else()
  add_compile_options(-g -O3)
endif()

if(CMAKE_Fortran_COMPILER_ID STREQUAL GCC)

  list(APPEND old -w)

  if(CMAKE_Fortran_COMPILER_VERSION VERSION_GREATER_EQUAL 8)
    list(APPEND old -std=legacy)
    list(APPEND new -std=f2018)
  endif()
endif()
