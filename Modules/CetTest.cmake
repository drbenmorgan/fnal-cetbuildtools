########################################################################
# Provide a cet_test macro to specify tests in a concise and
# transparent way.
########################################################################
#
# Usage: cet_test(target [<options>] [<args>] [<data-files>])
#
####################################
# Options:
#
# HANDBUILT
#   Do not build the target -- it will be provided. This option is
#    mutually exclusive with the PREBUILT option.
#
# PREBUILT
#   Do not build the target -- pick it up from the source dir (eg scripts).
#    This option is mutually exclusive with the HANDBUILT option.
#
# NO_AUTO
#   Do not add the target to the auto test list.
#
# USE_BOOST_UNIT
#   This test uses the Boost Unit Test Framework.
#
# INSTALL_EXAMPLE
#   Install this test and all its data files into the examples area of the
#    product.
#
# INSTALL_SOURCE
#   Install this test's source in the source area of the product.
####################################
# Args
#
# DATAFILES
#   Input and/or references files to be copied to the test area in the
#    build tree for use by the test. The DATAFILES keyword is optional provided
#    the placement of the files in the argument list is unambiguous.
#
# DEPENDENCIES
#   List of dependencies to consider for a PREBUILT target.
#
# LIBRARIES
#   Extra libraries with which to link this target.
#
# SOURCES
#   Sources to use to build the target (default is ${target}.cc).
#
# TEST_ARGS
#   Any arguments to the test to be run.
#
# TEST_EXEC
#   The exec to run (if not the target). The HANDBUILT option must
#    be specified in conjunction with this option.
#
# TEST_PROPERTIES
#   Properties to be added to the test. See documentation of the cmake
#   command, "set_tests_properties."
#
########################################################################

# Need argument parser.
include(CetParseArgs)
# May need Boost Unit Test Framework library.
include(FindUpsBoost)

# Simple CAR implementation.
MACRO(cet_car var)
  SET(${var} ${ARGV1})
ENDMACRO()

# Simple CDR implementation.
MACRO(cet_cdr var junk)
  SET(${var} ${ARGN})
ENDMACRO()

# If Boost has been specified but the library hasn't, load the library.
IF((NOT Boost_UNIT_TEST_FRAMEWORK_LIBRARY) AND BOOST_VERS)
  find_ups_boost(${BOOST_VERS} unit_test_framework)
ENDIF() 

####################################
# Main macro definition.
MACRO(cet_test CET_TARGET)
  # Parse arguments
  CET_PARSE_ARGS(CET
    "DATAFILES;DEPENDENCIES;LIBRARIES;SOURCES;TEST_ARGS;TEST_EXEC;TEST_PROPERTIES"
    "HANDBUILT;PREBUILT;NO_AUTO;USE_BOOST_UNIT;INSTALL_EXAMPLE;INSTALL_SOURCE"
    ${ARGN}
    )
  IF(CET_TEST_EXEC)
    IF(NOT CET_HANDBUILT)
      MESSAGE(FATAL_ERROR "cet_test: target ${CET_TARGET} cannot specify "
        "TEST_EXEC without HANDBUILT")
    ENDIF()
    # Check we only specified one.
    LIST(LENGTH CET_TEST_EXEC test_exec_length)
    IF(test_exec_length GREATER 1)
      MESSAGE(FATAL_ERROR "cet_test: expected only one value for TEST_EXEC "
        "argument for target ${CET_TARGET}.")
    ENDIF()
  ELSE()
    SET(CET_TEST_EXEC ${EXECUTABLE_OUTPUT_PATH}/${CET_TARGET})
  ENDIF()
  # Assume any remaining arguments are date files.
  IF(CET_DEFAULT_ARGS)
    SET(CET_DATAFILES ${CET_DATAFILES} ${CET_DEFAULT_ARGS})
  ENDIF()
  IF(CET_HANDBUILT AND CET_PREBUILT)
    # CET_HANDBUILT and CET_PREBUILT are mutually exclusive.
    MESSAGE(SEND_ERROR "cet_test: target ${CET_TARGET} cannot have both CET_HANDBUILT "
      "and CET_PREBUILT options set.")
  ELSEIF(CET_PREBUILT) # eg scripts.
    ADD_CUSTOM_TARGET(${CET_TARGET} ALL
      COMMAND ${CMAKE_COMMAND} -E
      copy ${CMAKE_CURRENT_SOURCE_DIR}/${CET_TARGET}
      ${EXECUTABLE_OUTPUT_PATH}/
      DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/${CET_TARGET}
      )
    FOREACH(dep ${CET_DEPENDENCIES})
      ADD_DEPENDENCIES(${CET_TARGET} ${dep})
    ENDFOREACH()
  ELSEIF(NOT CET_HANDBUILT) # Normal build.
    # Build the executable.
    IF(NOT CET_SOURCES) # Useful default.
      SET(CET_SOURCES ${CET_TARGET}.cc)
    ENDIF()
    ADD_EXECUTABLE(${CET_TARGET} ${CET_SOURCES})
    IF(CET_USE_BOOST_UNIT)
      # Make sure we have the correct library available.
      IF (NOT Boost_UNIT_TEST_FRAMEWORK_LIBRARY)
        MESSAGE(SEND_ERROR "cet_test: target ${CET_TARGET} has USE_BOOST_UNIT "
          "option set but Boost Unit Test Framework Library cannot be found: is "
          "boost set up?")
      ENDIF()
      # Compile options (-Dxxx) for simple-format unit tests.
      SET_TARGET_PROPERTIES(${CET_TARGET} PROPERTIES
        COMPILE_DEFINITIONS BOOST_TEST_MAIN
        COMPILE_DEFINITIONS BOOST_TEST_DYN_LINK
        )
      TARGET_LINK_LIBRARIES(${CET_TARGET} ${Boost_UNIT_TEST_FRAMEWORK_LIBRARY})
    ENDIF()
    TARGET_LINK_LIBRARIES(${CET_TARGET} ${CET_LIBRARIES})
  ENDIF()
  FOREACH(datafile ${CET_DATAFILES})
    # Name the target so that tests in different directories can use the same
    # data file.
    STRING(SUBSTRING ${datafile} 0 1 abs)
    IF(abs STREQUAL "/") # Absolute
      STRING(REPLACE "/" "@" dtarget "${datafile}")
      SET(abs_datafile ${datafile})
    ELSE()
      STRING(REPLACE "/" "@" dtarget "${CMAKE_CURRENT_BINARY_DIR}/${datafile}")
      SET(abs_datafile ${CMAKE_CURRENT_SOURCE_DIR}/${datafile})
    ENDIF()
    IF (TARGET ${dtarget})
      # NOP.
    ELSE()
      # Allow same data file to be used in multiple tests safely
      ADD_CUSTOM_TARGET(${dtarget} ALL
        COMMAND ${CMAKE_COMMAND} -E
        copy ${abs_datafile}
        ${CMAKE_CURRENT_BINARY_DIR}/
        DEPENDS ${abs_datafile}
        )
    ENDIF()
  ENDFOREACH()
  IF(NOT CET_NO_AUTO)
    # Add the test.
    ADD_TEST(${CET_TARGET} ${CET_TEST_EXEC} ${CET_TEST_ARGS})
    IF(CET_TEST_PROPERTIES)
      SET_TESTS_PROPERTIES(${CET_TARGET} PROPERTIES ${CET_TEST_PROPERTIES})
    ENDIF()
  ENDIF()
  IF(CET_INSTALL_EXAMPLE)
    # Install to examples directory of product.
    INSTALL(FILES ${CET_SOURCES} ${CET_DATAFILES}
      DESTINATION ${product}/${version}/example
      )
  ENDIF()
  IF(CET_INSTALL_SOURCE)
    # Install to sources/test (will need to be amended for eg ART's
    # multiple test directories.
    INSTALL(FILES ${CET_SOURCES}
      DESTINATION ${product}/${version}/source/test
      )
  ENDIF()
ENDMACRO(cet_test)
########################################################################
