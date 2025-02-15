cmake_minimum_required(VERSION 3.10)
cmake_policy(SET CMP0031 OLD) # testing the old behavior
project(LoadCommand)

# set a definition
set (TEST_COMMAND_TEST1 1)

include (${CMAKE_ROOT}/Modules/CheckTypeSize.cmake)
CHECK_TYPE_SIZE(char  SIZEOF_CHAR)
CHECK_TYPE_SIZE(short  SIZEOF_SHORT)

configure_file(${LoadCommand_SOURCE_DIR}/LoadedCommand.h.in
               ${LoadCommand_BINARY_DIR}/LoadedCommand.h)

include_directories(${LoadCommand_BINARY_DIR})

# try to compile the command
# make sure it is not already loaded
if(COMMAND CMAKE_TEST_COMMAND)
else()
  try_compile(COMPILE_OK
    ${LoadCommand_BINARY_DIR}/CMakeCommands
    ${LoadCommand_SOURCE_DIR}/CMakeCommands
    CMAKE_LOADED_COMMANDS CMAKE_FLAGS -DMUDSLIDE_TYPE:STRING=MUCHO
    OUTPUT_VARIABLE OUTPUT )
endif()

message("Output from try compile: ${OUTPUT}")

# if the compile was OK, try loading the command
if (COMPILE_OK)
  load_command(CMAKE_TEST_COMMAND
    ${LoadCommand_BINARY_DIR}/CMakeCommands
    ${LoadCommand_BINARY_DIR}/CMakeCommands/Debug
    ${LoadCommand_BINARY_DIR}/CMakeCommands/Development
    )
  # if the command loaded, execute the command
  if (COMMAND CMAKE_TEST_COMMAND)
    CMAKE_TEST_COMMAND(
      "${LoadCommand_SOURCE_DIR}/LoadedCommand.cxx.in"
      "${LoadCommand_BINARY_DIR}/LoadedCommand2.cxx.in"
      "${LoadCommand_BINARY_DIR}/LoadedCommand3.cxx"
      )
  endif ()
else ()
  message("failed to compile CMAKE_LOADED_COMMANDS")
endif ()

# TEST_DEF is set by the loaded command cmTestCommand.c
if (TEST_DEF AND SOME_CACHE_VARIABLE AND TEST_EXEC)
  add_definitions(-DCMAKE_IS_FUN)
endif ()
