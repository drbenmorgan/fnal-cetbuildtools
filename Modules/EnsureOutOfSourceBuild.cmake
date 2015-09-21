# Throw a fatal error if cmake is invoked from within the source code directory tree
# cet_ensure_out_of_source_build()
#
function(cet_ensure_out_of_source_build)
  get_filename_component(ACTUAL_CMAKE_BINARY_DIR "${CMAKE_BINARY_DIR}" REALPATH)
  string(REPLACE "${CMAKE_SOURCE_DIR}" "isasubdir" IS_INSOURCE "${ACTUAL_CMAKE_BINARY_DIR}")

  if (IS_INSOURCE)
  message(FATAL_ERROR "
ERROR: In source builds of this project are not allowed.
A separate build directory is required.
Please create one and run cmake from the build directory.
Also note that cmake has just added files to your source code directory.
We suggest getting a new copy of the source code.
Otherwise, delete `CMakeCache.txt' and the directory `CMakeFiles'.
  ")
  endif()
endfunction()

