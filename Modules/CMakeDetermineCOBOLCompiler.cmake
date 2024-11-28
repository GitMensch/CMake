# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.


# determine the compiler to use for COBOL programs
# NOTE, a generator may set CMAKE_COBOL_COMPILER before
# loading this file to force a compiler.
# use environment variable COBC first if defined by user, next use
# the cmake variable CMAKE_GENERATOR_COBC which can be defined by a generator
# as a default compiler

include(${CMAKE_ROOT}/Modules/CMakeDetermineCompiler.cmake)
include(Platform/${CMAKE_SYSTEM_NAME}-Determine-COBOL OPTIONAL)
include(Platform/${CMAKE_SYSTEM_NAME}-COBOL OPTIONAL)

  if(NOT CMAKE_COBOL_COMPILER)
    # prefer the environment variable COBC
    if(NOT $ENV{COBC} STREQUAL "")
      get_filename_component(CMAKE_COBOL_COMPILER_INIT $ENV{COBC} PROGRAM PROGRAM_ARGS CMAKE_COBOL_FLAGS_ENV_INIT)
      if(CMAKE_COBOL_FLAGS_ENV_INIT)
        set(CMAKE_COBOL_COMPILER_ARG1 "${CMAKE_COBOL_FLAGS_ENV_INIT}" CACHE STRING "Arguments to COBOL compiler")
      endif()
      if(EXISTS ${CMAKE_COBOL_COMPILER_INIT})
      else()
        message(FATAL_ERROR "Could not find compiler set in environment variable COBC:\n$ENV{COBC}.")
      endif()
    endif()

    # next try prefer the compiler specified by the generator
    if(CMAKE_GENERATOR_COBC)
      if(NOT CMAKE_COBOL_COMPILER_INIT)
        set(CMAKE_COBOL_COMPILER_INIT ${CMAKE_GENERATOR_COBC})
      endif()
    endif()

    # finally list compilers to try
    if(NOT CMAKE_COBOL_COMPILER_INIT)
      # Known compilers:
      #  gcobol: GCC frontent for COBOL (integration for gcc-15 in progress)
      #  cob2: IBM COBOL for Linux on x86 compiler
      #  cobc: GnuCOBOL (formerly OpenCOBOL) compiler
      #
      #  GNU is last to be searched,
      #  so if you paid for a compiler it is picked by default.
      set(CMAKE_COBOL_COMPILER_LIST
        cob2
        cobc
        gcobol
        )

      # Vendor-specific compiler names.
      set(_COBOL_COMPILER_NAMES_GNU       gcobol)
      set(_COBOL_COMPILER_NAMES_GnuCOBOL  cobc)
      set(_COBOL_COMPILER_NAMES_IBM       cob2)
    endif()

    _cmake_find_compiler(COBOL)

  else()
    _cmake_find_compiler_path(COBOL)
  endif()
  mark_as_advanced(CMAKE_COBOL_COMPILER)

  # Each entry in this list is a set of extra flags to try
  # adding to the compile line to see if it helps produce
  # a valid identification executable.
  set(CMAKE_COBOL_COMPILER_ID_TEST_FLAGS_FIRST
    # Get verbose output to help distinguish compilers.
    "-v"

    # Try compiling to an object file only, with verbose output.
    "-v -c"
    )
  set(CMAKE_COBOL_COMPILER_ID_TEST_FLAGS
    # Try compiling to an object file only.
    "-c"
    )

if(CMAKE_COBOL_COMPILER_TARGET)
  set(CMAKE_COBOL_COMPILER_ID_TEST_FLAGS_FIRST "-v -c --target=${CMAKE_COBOL_COMPILER_TARGET}")
endif()

# Build a small source file to identify the compiler.
if(NOT CMAKE_COBOL_COMPILER_ID_RUN)
  set(CMAKE_COBOL_COMPILER_ID_RUN 1)

  # Table of per-vendor compiler output regular expressions.
  list(APPEND CMAKE_COBOL_COMPILER_ID_MATCH_VENDORS GnuCOBOL)
  set(CMAKE_COBOL_COMPILER_ID_MATCH_VENDOR_REGEX_GnuCOBOL "GnuCOBOL")
#
#  # Table of per-vendor compiler id flags with expected output.
#  list(APPEND CMAKE_COBOL_COMPILER_ID_VENDORS Compaq)
#  set(CMAKE_COBOL_COMPILER_ID_VENDOR_FLAGS_Compaq "-what")
#  set(CMAKE_COBOL_COMPILER_ID_VENDOR_REGEX_Compaq "Compaq Visual COBOL")
#  list(APPEND CMAKE_COBOL_COMPILER_ID_VENDORS NAG) # Numerical Algorithms Group
#  set(CMAKE_COBOL_COMPILER_ID_VENDOR_FLAGS_NAG "-V")
#  set(CMAKE_COBOL_COMPILER_ID_VENDOR_REGEX_NAG "NAG COBOL Compiler")
#
#
#  set(_version_info "")
#  foreach(m IN ITEMS MAJOR MINOR PATCH TWEAK)
#    set(_COMP "_${m}")
#    string(APPEND _version_info "
##if defined(COMPILER_VERSION${_COMP})")
#    foreach(d RANGE 1 8)
#      string(APPEND _version_info "
## undef DEC
## undef HEX
## define DEC(n) DEC_${d}(n)
## define HEX(n) HEX_${d}(n)
## if COMPILER_VERSION${_COMP} == 0
#        PRINT *, 'INFO:compiler_version${_COMP}_digit_${d}[0]'
## elif COMPILER_VERSION${_COMP} == 1
#        PRINT *, 'INFO:compiler_version${_COMP}_digit_${d}[1]'
## elif COMPILER_VERSION${_COMP} == 2
#        PRINT *, 'INFO:compiler_version${_COMP}_digit_${d}[2]'
## elif COMPILER_VERSION${_COMP} == 3
#        PRINT *, 'INFO:compiler_version${_COMP}_digit_${d}[3]'
## elif COMPILER_VERSION${_COMP} == 4
#        PRINT *, 'INFO:compiler_version${_COMP}_digit_${d}[4]'
## elif COMPILER_VERSION${_COMP} == 5
#        PRINT *, 'INFO:compiler_version${_COMP}_digit_${d}[5]'
## elif COMPILER_VERSION${_COMP} == 6
#        PRINT *, 'INFO:compiler_version${_COMP}_digit_${d}[6]'
## elif COMPILER_VERSION${_COMP} == 7
#        PRINT *, 'INFO:compiler_version${_COMP}_digit_${d}[7]'
## elif COMPILER_VERSION${_COMP} == 8
#        PRINT *, 'INFO:compiler_version${_COMP}_digit_${d}[8]'
## elif COMPILER_VERSION${_COMP} == 9
#        PRINT *, 'INFO:compiler_version${_COMP}_digit_${d}[9]'
## endif
#")
#    endforeach()
#    string(APPEND _version_info "
##endif")
#  endforeach()
#  set(CMAKE_COBOL_COMPILER_ID_VERSION_INFO "${_version_info}")
#  unset(_version_info)
#  unset(_COMP)

  # Try to identify the compiler.
  set(CMAKE_COBOL_COMPILER_ID)
  include(${CMAKE_ROOT}/Modules/CMakeDetermineCompilerId.cmake)
  #CHECKME: we likely want to use COBC --version instead
  # CMAKE_DETERMINE_COMPILER_ID(COBOL COBCFLAGS CMakeCOBOLCompilerId.cob)

  _cmake_find_compiler_sysroot(COBOL)

  #CHECKME - needed?
  # Fall back to old is-GNU test.
  # if(NOT CMAKE_COBOL_COMPILER_ID)
  #   execute_process(COMMAND ${CMAKE_COBOL_COMPILER} ${CMAKE_COBOL_COMPILER_ID_FLAGS_LIST} -E "${CMAKE_ROOT}/Modules/CMakeTestGNU.c"
  #     OUTPUT_VARIABLE CMAKE_COMPILER_OUTPUT RESULT_VARIABLE CMAKE_COMPILER_RETURN)
  #   if(NOT CMAKE_COMPILER_RETURN)
  #     if(CMAKE_COMPILER_OUTPUT MATCHES "THIS_IS_GNU")
  #       set(CMAKE_COBOL_COMPILER_ID "GNU")
  #       message(CONFIGURE_LOG
  #         "Determining if the COBOL compiler is GNU succeeded with "
  #         "the following output:\n${CMAKE_COMPILER_OUTPUT}\n\n")
  #     else()
  #       message(CONFIGURE_LOG
  #         "Determining if the COBOL compiler is GNU failed with "
  #         "the following output:\n${CMAKE_COMPILER_OUTPUT}\n\n")
  #     endif()
  #     if(NOT CMAKE_COBOL_PLATFORM_ID)
  #       if(CMAKE_COMPILER_OUTPUT MATCHES "THIS_IS_MINGW")
  #         set(CMAKE_COBOL_PLATFORM_ID "MinGW")
  #       endif()
  #       if(CMAKE_COMPILER_OUTPUT MATCHES "THIS_IS_CYGWIN")
  #         set(CMAKE_COBOL_PLATFORM_ID "Cygwin")
  #       endif()
  #     endif()
  #   endif()
  # endif()
endif()

if (NOT _CMAKE_TOOLCHAIN_LOCATION)
  get_filename_component(_CMAKE_TOOLCHAIN_LOCATION "${CMAKE_COBOL_COMPILER}" PATH)
endif ()

# if we have a COBOL cross compiler, they have usually some prefix, like
# e.g. powerpc-linux-gcobol, arm-elf-gcobol or i586-mingw32msvc-gcobol , optionally
# with a 3-component version number at the end (e.g. arm-eabi-gcc-4.5.2).
# The other tools of the toolchain usually have the same prefix
# NAME_WE cannot be used since then this test will fail for names like
# "arm-unknown-nto-qnx6.3.0-gcc.exe", where BASENAME would be
# "arm-unknown-nto-qnx6" instead of the correct "arm-unknown-nto-qnx6.3.0-"
if (NOT _CMAKE_TOOLCHAIN_PREFIX)

  if(CMAKE_COBOL_COMPILER_ID MATCHES "GNU")
    get_filename_component(COMPILER_BASENAME "${CMAKE_COBOL_COMPILER}" NAME)
    if (COMPILER_BASENAME MATCHES "^(.+-)g?cobol(-[0-9]+\\.[0-9]+\\.[0-9]+)?(\\.exe)?$")
      set(_CMAKE_TOOLCHAIN_PREFIX ${CMAKE_MATCH_1})
    endif ()
  endif()

endif ()

set(_CMAKE_PROCESSING_LANGUAGE "COBOL")
include(CMakeFindBinUtils)
include(Compiler/${CMAKE_COBOL_COMPILER_ID}-FindBinUtils OPTIONAL)
unset(_CMAKE_PROCESSING_LANGUAGE)

if(CMAKE_COBOL_COMPILER_SYSROOT)
  string(CONCAT _SET_CMAKE_COBOL_COMPILER_SYSROOT
    "set(CMAKE_COBOL_COMPILER_SYSROOT \"${CMAKE_COBOL_COMPILER_SYSROOT}\")\n"
    "set(CMAKE_COMPILER_SYSROOT \"${CMAKE_COBOL_COMPILER_SYSROOT}\")")
else()
  set(_SET_CMAKE_COBOL_COMPILER_SYSROOT "")
endif()

if(CMAKE_COBOL_COMPILER_ARCHITECTURE_ID)
  set(_SET_CMAKE_COBOL_COMPILER_ARCHITECTURE_ID
    "set(CMAKE_COBOL_COMPILER_ARCHITECTURE_ID ${CMAKE_COBOL_COMPILER_ARCHITECTURE_ID})")
else()
  set(_SET_CMAKE_COBOL_COMPILER_ARCHITECTURE_ID "")
endif()

# configure variables set in this file for fast reload later on
configure_file(${CMAKE_ROOT}/Modules/CMakeCOBOLCompiler.cmake.in
  ${CMAKE_PLATFORM_INFO_DIR}/CMakeCOBOLCompiler.cmake
  @ONLY
  )
set(CMAKE_COBOL_COMPILER_ENV_VAR "FC")
