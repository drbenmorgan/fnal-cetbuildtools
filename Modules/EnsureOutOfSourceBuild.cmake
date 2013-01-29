# Throw a fatal error if cmake is invoked from within the source code directory tree
# cet_ensure_out_of_source_build()
#

macro (cet_ensure_out_of_source_build)

message(STATUS "cet_ensure_out_of_source_build: CMAKE_SOURCE_DIR is ${CMAKE_SOURCE_DIR}")
message(STATUS "cet_ensure_out_of_source_build: CMAKE_BINARY_DIR is ${CMAKE_BINARY_DIR}")

  string(COMPARE EQUAL "${CMAKE_SOURCE_DIR}" "${CMAKE_BINARY_DIR}" in_source)
  string( REGEX MATCH "${CMAKE_SOURCE_DIR}/" maybe_in_source_subdir "${CMAKE_BINARY_DIR}")

  message(STATUS "cet_ensure_out_of_source_build: ${in_source} and ${maybe_in_source_subdir}")
  if (in_source )
  message(STATUS "in source")
  endif ()
  if( maybe_in_source_subdir )
    execute_process( COMMAND /bin/pwd
		     OUTPUT_VARIABLE thisdir
		     OUTPUT_STRIP_TRAILING_WHITESPACE )
    message(STATUS "/bin/pwd returns ${thisdir}")
    string( REGEX MATCH "${CMAKE_SOURCE_DIR}/" in_source_subdir "${thisdir}")
    message(STATUS "regex match returns --${in_source_subdir}--")
  endif ()
  
  message(STATUS "cet_ensure_out_of_source_build: in_source_subdir is ${in_source_subdir}")
  if (in_source )
    message(STATUS "in source")
  endif ()
  if (in_source_subdir)
     message(STATUS "in source subdirectory")
  endif ()

  if (in_source OR in_source_subdir)
  message(FATAL_ERROR "
ERROR: In source builds of this project are not allowed.
A separate build directory is required.
Please create one and run cmake from the build directory.
Also note that cmake has just added files to your source code directory.
We suggest getting a new copy of the source code.
Otherwise, delete `CMakeCache.txt' and the directory `CMakeFiles'.
  ")
  endif ()

endmacro (cet_ensure_out_of_source_build)

