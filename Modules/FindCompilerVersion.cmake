# determine the compiler and version
# this code is more or less lifted from FindBoost

#-------------------------------------------------------------------------------

#
# Runs compiler with "-dumpversion" and parses major/minor
# version with a regex.
#
FUNCTION(_My_COMPILER_DUMPVERSION _OUTPUT_VERSION)

  EXEC_PROGRAM(${CMAKE_CXX_COMPILER}
    ARGS ${CMAKE_CXX_COMPILER_ARG1} -dumpversion
    OUTPUT_VARIABLE _my_COMPILER_VERSION
  )
  STRING(REGEX REPLACE "([0-9])\\.([0-9])(\\.[0-9])?" "\\1\\2"
    _my_COMPILER_VERSION ${_my_COMPILER_VERSION})

  SET(${_OUTPUT_VERSION} ${_my_COMPILER_VERSION} PARENT_SCOPE)
ENDFUNCTION()

#
# End functions/macros
#  
#-------------------------------------------------------------------------------


macro( find_compiler )
  if (My_COMPILER)
      SET (Using_COMPILER ${My_COMPILER})
      message(STATUS "[ ${CMAKE_CURRENT_LIST_FILE}:${CMAKE_CURRENT_LIST_LINE} ] "
                     "using user-specified My_COMPILER = ${Using_COMPILER}")
  else(My_COMPILER)
    # Attempt to guess the compiler suffix
    # NOTE: this is not perfect yet, if you experience any issues
    # please report them and use the My_COMPILER variable
    # to work around the problems.
    if (MSVC90)
      SET (Using_COMPILER "-vc90")
    elseif (MSVC80)
      SET (Using_COMPILER "-vc80")
    elseif (MSVC71)
      SET (Using_COMPILER "-vc71")
    elseif (MSVC70) # Good luck!
      SET (Using_COMPILER "-vc7") # yes, this is correct
    elseif (MSVC60) # Good luck!
      SET (Using_COMPILER "-vc6") # yes, this is correct
    elseif (BORLAND)
      SET (Using_COMPILER "-bcb")
    elseif("${CMAKE_CXX_COMPILER}" MATCHES "icl" 
        OR "${CMAKE_CXX_COMPILER}" MATCHES "icpc") 
      if(WIN32)
        set (Using_COMPILER "-iw")
      else()
        set (Using_COMPILER "-il")
      endif()
    elseif (MINGW)
        _My_COMPILER_DUMPVERSION(Using_COMPILER_VERSION)
        SET (Using_COMPILER "-mgw${Using_COMPILER_VERSION}")
    elseif (UNIX)
      if (CMAKE_COMPILER_IS_GNUCXX)
          _My_COMPILER_DUMPVERSION(Using_COMPILER_VERSION)
          # Determine which version of GCC we have.
          SET (Using_COMPILER "-gcc${Using_COMPILER_VERSION}")
      endif (CMAKE_COMPILER_IS_GNUCXX)
    endif()
      message(STATUS "Using compiler ${Using_COMPILER}")
  endif(My_COMPILER)
endmacro( find_compiler )
