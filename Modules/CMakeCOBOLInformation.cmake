# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.


include(CMakeLanguageInformation)

# This file sets the basic flags for the COBOL language in CMake.
# It also loads the available platform file for the system-compiler
# if it exists.

set(_INCLUDED_FILE 0)

# Load compiler-specific information.
if(CMAKE_COBOL_COMPILER_ID)
  include(Compiler/${CMAKE_COBOL_COMPILER_ID}-COBOL OPTIONAL)
endif()

set(CMAKE_BASE_NAME)
get_filename_component(CMAKE_BASE_NAME "${CMAKE_COBOL_COMPILER}" NAME_WE)

if(CMAKE_COBOL_COMPILER_ID)
  include(Platform/${CMAKE_EFFECTIVE_SYSTEM_NAME}-${CMAKE_COBOL_COMPILER_ID}-COBOL OPTIONAL RESULT_VARIABLE _INCLUDED_FILE)
endif()
if (NOT _INCLUDED_FILE)
  include(Platform/${CMAKE_EFFECTIVE_SYSTEM_NAME}-${CMAKE_BASE_NAME} OPTIONAL
          RESULT_VARIABLE _INCLUDED_FILE)
endif ()

# load any compiler-wrapper specific information
if (CMAKE_COBOL_COMPILER_WRAPPER)
  __cmake_include_compiler_wrapper(COBOL)
endif ()

# We specify the compiler information in the system file for some
# platforms, but this language may not have been enabled when the file
# was first included.  Include it again to get the language info.
# Remove this when all compiler info is removed from system files.
if (NOT _INCLUDED_FILE)
  include(Platform/${CMAKE_SYSTEM_NAME} OPTIONAL)
endif ()

if(CMAKE_COBOL_SIZEOF_DATA_PTR)
  foreach(f IN LISTS CMAKE_COBOL_ABI_FILES)
    include(${f})
  endforeach()
  unset(CMAKE_COBOL_ABI_FILES)
endif()

# This should be included before the _INIT variables are
# used to initialize the cache.  Since the rule variables
# have if blocks on them, users can still define them here.
# But, it should still be after the platform file so changes can
# be made to those values.

if(CMAKE_USER_MAKE_RULES_OVERRIDE)
  # Save the full path of the file so try_compile can use it.
  include(${CMAKE_USER_MAKE_RULES_OVERRIDE} RESULT_VARIABLE _override)
  set(CMAKE_USER_MAKE_RULES_OVERRIDE "${_override}")
endif()

if(CMAKE_USER_MAKE_RULES_OVERRIDE_COBOL)
  # Save the full path of the file so try_compile can use it.
  include(${CMAKE_USER_MAKE_RULES_OVERRIDE_COBOL} RESULT_VARIABLE _override)
  set(CMAKE_USER_MAKE_RULES_OVERRIDE_COBOL "${_override}")
endif()

set(CMAKE_VERBOSE_MAKEFILE FALSE CACHE BOOL "If this value is on, makefiles will be generated without the .SILENT directive, and all commands will be echoed to the console during the make.  This is useful for debugging only. With Visual Studio IDE projects all commands are done without /nologo.")

set(CMAKE_COBOL_FLAGS_INIT "$ENV{COBCFLAGS} ${CMAKE_COBOL_FLAGS_INIT}")

cmake_initialize_per_config_variable(CMAKE_COBOL_FLAGS "Flags used by the COBOL compiler")

if(NOT CMAKE_COBOL_COMPILER_LAUNCHER AND DEFINED ENV{CMAKE_COBOL_COMPILER_LAUNCHER})
  set(CMAKE_COBOL_COMPILER_LAUNCHER "$ENV{CMAKE_COBOL_COMPILER_LAUNCHER}"
    CACHE STRING "Compiler launcher for COBOL.")
endif()

include(CMakeCommonLanguageInclude)
_cmake_common_language_platform_flags(COBOL)

# now define the following rule variables
# CMAKE_COBOL_CREATE_SHARED_LIBRARY
# CMAKE_COBOL_CREATE_SHARED_MODULE
# CMAKE_COBOL_COMPILE_OBJECT
# CMAKE_COBOL_LINK_EXECUTABLE

# create a COBOL shared library
if(NOT CMAKE_COBOL_CREATE_SHARED_LIBRARY)
  set(CMAKE_COBOL_CREATE_SHARED_LIBRARY
      "<CMAKE_COBOL_COMPILER> <CMAKE_SHARED_LIBRARY_COBOL_FLAGS> <LANGUAGE_COMPILE_FLAGS> <LINK_FLAGS> <CMAKE_SHARED_LIBRARY_CREATE_COBOL_FLAGS> <SONAME_FLAG><TARGET_SONAME> -o <TARGET> <OBJECTS> <LINK_LIBRARIES>")
endif()

# create a COBOL shared module just copy the shared library rule
if(NOT CMAKE_COBOL_CREATE_SHARED_MODULE)
  set(CMAKE_COBOL_CREATE_SHARED_MODULE ${CMAKE_COBOL_CREATE_SHARED_LIBRARY})
endif()

# Create a static archive incrementally for large object file counts.
# If CMAKE_COBOL_CREATE_STATIC_LIBRARY is set it will override these.
if(NOT DEFINED CMAKE_COBOL_ARCHIVE_CREATE)
  set(CMAKE_COBOL_ARCHIVE_CREATE "<CMAKE_AR> qc <TARGET> <LINK_FLAGS> <OBJECTS>")
endif()
if(NOT DEFINED CMAKE_COBOL_ARCHIVE_APPEND)
  set(CMAKE_COBOL_ARCHIVE_APPEND "<CMAKE_AR> q <TARGET> <LINK_FLAGS> <OBJECTS>")
endif()
if(NOT DEFINED CMAKE_COBOL_ARCHIVE_FINISH)
  set(CMAKE_COBOL_ARCHIVE_FINISH "<CMAKE_RANLIB> <TARGET>")
endif()

# compile a COBOL file into an object file
# CHECKME: at least GnuCOBOL needs -x if the later target is an executable for the "main COBOL source"
#          (to generate the main function)
if(NOT CMAKE_COBOL_COMPILE_OBJECT)
  set(CMAKE_COBOL_COMPILE_OBJECT
    "<CMAKE_COBOL_COMPILER> <DEFINES> <INCLUDES> <FLAGS> -o <OBJECT> <SOURCE>")
endif()

# link a COBOL program
if(NOT CMAKE_COBOL_LINK_EXECUTABLE)
  set(CMAKE_COBOL_LINK_EXECUTABLE
    "<CMAKE_COBOL_COMPILER> <CMAKE_COBOL_LINK_FLAGS> <LINK_FLAGS> <FLAGS> <OBJECTS> -x -o <TARGET> <LINK_LIBRARIES>")
endif()

if(CMAKE_COBOL_STANDARD_LIBRARIES_INIT)
  set(CMAKE_COBOL_STANDARD_LIBRARIES "${CMAKE_COBOL_STANDARD_LIBRARIES_INIT}"
    CACHE STRING "Libraries linked by default with all COBOL applications.")
  mark_as_advanced(CMAKE_COBOL_STANDARD_LIBRARIES)
endif()

# CHECKME: if added later, create
#          Modules/Internal/CMakeCOBOLLinkerInformation.cmake
set(CMAKE_COBOL_USE_LINKER_INFORMATION FALSE)

# set this variable so we can avoid loading this more than once.
set(CMAKE_COBOL_INFORMATION_LOADED 1)
