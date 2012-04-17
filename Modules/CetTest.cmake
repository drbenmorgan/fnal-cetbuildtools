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
#
####################################
# Args
#
# CONFIGURATIONS
#
#   Configurations (Debug, etc, etc) under which the test shall be executed.
#
# DATAFILES
#   Input and/or references files to be copied to the test area in the
#    build tree for use by the test. The DATAFILES keyword is optional provided
#    the placement of the files in the argument list is unambiguous.
#
# DEPENDENCIES
#   List of top-level dependencies to consider for a PREBUILT
#    target. Top-level implies a target (not file) created with ADD_EXECUTABLE,
#    ADD_LIBRARY or ADD_CUSTOM_TARGET.
#
# LIBRARIES
#   Extra libraries with which to link this target.
#
# OPTIONAL_GROUPS
#   Assign this test to one or more named optional groups. If the CMake
#    list variable CET_TEST_GROUPS is set (e.g. with -D on the CMake
#    command line) and there is overlap between the two lists, execute
#    the test. The CET_TEST_GROUPS cache variable may additionally
#    contain the optional values ALL or NONE.
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
####################################
# Cache variables
#
# CET_TEST_GROUPS
#   Test group names specified using the OPTIONAL_GROUPS list option are
#    compared against this list to determine whether to configure the
#    test. Default value is the special value "NONE," meaning no
#    optional tests are to be configured. Optionally CET_TEST_GROUPS may
#    contain the special value "ALL." Specify multiple values separated
#    by ";" (escape or protect with quotes) or "," See explanation of
#    the OPTIONAL_GROUPS variable above for more details.
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

SET(CET_TEST_GROUPS "NONE"
  CACHE STRING "List of optional test groups to be configured."
  )

STRING(TOUPPER "${CET_TEST_GROUPS}" CET_TEST_GROUPS_UC)

FUNCTION(_check_want_test CET_OPTIONAL_GROUPS CET_WANT_TEST)
  IF(NOT CET_OPTIONAL_GROUPS)
    SET(${CET_WANT_TEST} YES PARENT_SCOPE)
    RETURN() # Short-circuit.
  ENDIF()
  SET (${CET_WANT_TEST} NO PARENT_SCOPE)
  LIST(FIND CET_TEST_GROUPS_UC ALL WANT_ALL)
  LIST(FIND CET_TEST_GROUPS_UC NONE WANT_NONE)
  IF(WANT_ALL GREATER -1)
    SET (${CET_WANT_TEST} YES PARENT_SCOPE)
    RETURN() # Short-circuit.
  ELSEIF(WANT_NONE GREATER -1)
    RETURN() # Short-circuit.
  ELSE()
    FOREACH(item IN LISTS CET_OPTIONAL_GROUPS)
      STRING(TOUPPER "${item}" item_uc)
      LIST(FIND CET_TEST_GROUPS_UC ${item_uc} FOUND_ITEM)
      IF(FOUND_ITEM GREATER -1)
        SET (${CET_WANT_TEST} YES PARENT_SCOPE)
        RETURN() # Short-circuit.
      ENDIF()
    ENDFOREACH()
  ENDIF()
ENDFUNCTION()

####################################
# Main macro definition.
MACRO(cet_test CET_TARGET)
  # Parse arguments
  IF(${CET_TARGET} MATCHES .*/.*)
    MESSAGE(FATAL_ERROR "${CET_TARGET} shuld not be a path. Use a simple "
      "target name with the HANDBUILT and TEST_EXEC options instead.")
  ENDIF()
  CET_PARSE_ARGS(CET
    "CONFIGURATIONS;DATAFILES;DEPENDENCIES;LIBRARIES;OPTIONAL_GROUPS;SOURCES;TEST_ARGS;TEST_EXEC;TEST_PROPERTIES"
    "HANDBUILT;PREBUILT;NO_AUTO;USE_BOOST_UNIT;INSTALL_EXAMPLE;INSTALL_SOURCE"
    ${ARGN}
    )
  IF(${CMAKE_VERSION} VERSION_GREATER "2.8")
    # Set up to handle a per-test work directory for parallel testing.
    SET(CET_TEST_WORKDIR "${CMAKE_CURRENT_BINARY_DIR}/${CET_TARGET}.d")
    STRING(REPLACE "/" "!" wdtarget ${CET_TEST_WORKDIR})
    ADD_CUSTOM_TARGET(${wdtarget} ALL
      COMMAND ${CMAKE_COMMAND} -E
      make_directory "${CET_TEST_WORKDIR}"
      )
  ELSE()
    SET(CET_TEST_WORKDIR "${CMAKE_CURRENT_BINARY_DIR}")
  ENDIF()
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
      copy "${CMAKE_CURRENT_SOURCE_DIR}/${CET_TARGET}"
      "${EXECUTABLE_OUTPUT_PATH}/"
      DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/${CET_TARGET}"
      )
    if(CET_DEPENDENCIES)
      ADD_DEPENDENCIES(${CET_TARGET} ${CET_DEPENDENCIES})
    ENDIF()
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
    IF(IS_ABSOLUTE ${datafile})
      STRING(REPLACE "/" "!" dtarget "${datafile}")
      SET(abs_datafile ${datafile})
    ELSE()
      STRING(REPLACE "/" "!" dtarget "${CET_TEST_WORKDIR}/${datafile}")
      SET(abs_datafile ${CMAKE_CURRENT_SOURCE_DIR}/${datafile})
    ENDIF()
    IF (TARGET ${dtarget})
      # NOP.
    ELSE()
      # Allow same data file to be used in multiple tests safely
      ADD_CUSTOM_TARGET(${dtarget} ALL
        COMMAND ${CMAKE_COMMAND} -E
        copy ${abs_datafile}
        ${CET_TEST_WORKDIR}/
        DEPENDS ${abs_datafile}
        )
      IF(wdtarget)
        ADD_DEPENDENCIES(${dtarget} ${wdtarget})
      ENDIF()
    ENDIF()
  ENDFOREACH()
  IF(CET_CONFIGURATIONS)
    SET(CONFIGURATIONS_CMD CONFIGURATIONS)
  ENDIF()
  _check_want_test("${CET_OPTIONAL_GROUPS}" WANT_TEST)
  IF(NOT CET_NO_AUTO AND WANT_TEST)
    # Add the test.
    ADD_TEST(NAME ${CET_TARGET}
      ${CONFIGURATIONS_CMD} ${CET_CONFIGURATIONS}
      COMMAND ${CET_TEST_EXEC} ${CET_TEST_ARGS})
    IF(${CMAKE_VERSION} VERSION_GREATER "2.8")
      SET_TESTS_PROPERTIES(${CET_TARGET} PROPERTIES WORKING_DIRECTORY ${CET_TEST_WORKDIR})
    ENDIF()
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
