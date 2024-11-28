# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.


if(CMAKE_COBOL_COMPILER_FORCED)
  # The compiler configuration was forced by the user.
  # Assume the user has configured all compiler information.
  set(CMAKE_COBOL_COMPILER_WORKS TRUE)
  return()
endif()

include(CMakeTestCompilerCommon)

# Remove any cached result from an older CMake version.
# We now store this in CMakeCOBOLCompiler.cmake.
unset(CMAKE_COBOL_COMPILER_WORKS CACHE)

# Try to identify the ABI and configure it into CMakeCOBOLCompiler.cmake
include(${CMAKE_ROOT}/Modules/CMakeDetermineCompilerABI.cmake)
#CMAKE_DETERMINE_COMPILER_ABI(COBOL ${CMAKE_ROOT}/Modules/CMakeCOBOLCompilerABI.cob)
#if(CMAKE_COBOL_ABI_COMPILED)
#  # The compiler worked so skip dedicated test below.
#  set(CMAKE_COBOL_COMPILER_WORKS TRUE)
#  #set(CMAKE_COBOL_COMPILER_SUPPORTS_F90 1)
#  message(STATUS "Check for working COBOL compiler: ${CMAKE_COBOL_COMPILER} - skipped")
#else()
#  cmake_determine_compiler_abi(COBOL ${CMAKE_ROOT}/Modules/CMakeCOBOLCompilerABI.COB)
#  if(CMAKE_COBOL_ABI_COMPILED)
#    set(CMAKE_COBOL_COMPILER_WORKS TRUE)
#    message(STATUS "Check for working COBOL 85 compiler: ${CMAKE_COBOL_COMPILER} - skipped")
#  endif()
#endif()

# This file is used by EnableLanguage in cmGlobalGenerator to
# determine that the selected COBOL compiler can actually compile
# and link the most basic of programs.   If not, a fatal error
# is set and cmake stops processing commands and will not generate
# any makefiles or projects.
if(NOT CMAKE_COBOL_COMPILER_WORKS)
  PrintTestCompilerStatus("COBOL")
  set(__TestCompiler_testCOBOLCompilerSource "
       PROGRAM-ID. TESTCOB.
       PROCEDURE DIVISION.
       MAIN.
           DISPLAY 'Hello'.
           GOBACK.
  ")
  # Clear result from normal variable.
  unset(CMAKE_COBOL_COMPILER_WORKS)
  # Puts test result in cache variable.
  try_compile(CMAKE_COBOL_COMPILER_WORKS
    SOURCE_FROM_VAR TESTCOB.COB __TestCompiler_testCOBOLCompilerSource
    OUTPUT_VARIABLE OUTPUT)
  unset(__TestCompiler_testCOBOLCompilerSource)
  # Move result from cache to normal variable.
  set(CMAKE_COBOL_COMPILER_WORKS ${CMAKE_COBOL_COMPILER_WORKS})
  unset(CMAKE_COBOL_COMPILER_WORKS CACHE)
  if(NOT CMAKE_COBOL_COMPILER_WORKS)
    PrintTestCompilerResult(CHECK_FAIL "broken")
    string(REPLACE "\n" "\n  " _output "${OUTPUT}")
    message(FATAL_ERROR "The COBOL compiler\n  \"${CMAKE_COBOL_COMPILER}\"\n"
      "is not able to compile a simple test program.\nIt fails "
      "with the following output:\n  ${_output}\n\n"
      "CMake will not be able to correctly generate this project.")
  endif()
  PrintTestCompilerResult(CHECK_PASS "works")
endif()

#CHECKME: possibly test for free-form reference format and for COBOL 2002+
## Test for COBOL 90 support by using an f90-specific construct.
#if(NOT DEFINED CMAKE_COBOL_COMPILER_SUPPORTS_F90)
#  message(CHECK_START "Checking whether ${CMAKE_COBOL_COMPILER} supports COBOL 90")
#  set(__TestCompiler_testCOBOLCompilerSource "
#    PROGRAM TESTFortran90
#    integer stop ; stop = 1 ; do while ( stop .eq. 0 ) ; end do
#    END PROGRAM TESTFortran90
#")
#  try_compile(CMAKE_COBOL_COMPILER_SUPPORTS_F90
#    SOURCE_FROM_VAR testFortranCompilerF90.f90 __TestCompiler_testFortranCompilerF90Source
#    OUTPUT_VARIABLE OUTPUT)
#  unset(__TestCompiler_testFortranCompilerF90Source)
#  if(CMAKE_COBOL_COMPILER_SUPPORTS_F90)
#    message(CHECK_PASS "yes")
#    set(CMAKE_COBOL_COMPILER_SUPPORTS_F90 1)
#  else()
#    message(CHECK_FAIL "no")
#    set(CMAKE_COBOL_COMPILER_SUPPORTS_F90 0)
#  endif()
#  unset(CMAKE_COBOL_COMPILER_SUPPORTS_F90 CACHE)
#endif()

# Re-configure to save learned information.
configure_file(
  ${CMAKE_ROOT}/Modules/CMakeCOBOLCompiler.cmake.in
  ${CMAKE_PLATFORM_INFO_DIR}/CMakeCOBOLCompiler.cmake
  @ONLY
  )
include(${CMAKE_PLATFORM_INFO_DIR}/CMakeCOBOLCompiler.cmake)

if(CMAKE_COBOL_SIZEOF_DATA_PTR)
  foreach(f ${CMAKE_COBOL_ABI_FILES})
    include(${f})
  endforeach()
  unset(CMAKE_COBOL_ABI_FILES)
endif()
