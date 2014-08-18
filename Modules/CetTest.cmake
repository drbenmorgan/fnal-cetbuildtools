########################################################################
# cet_test: specify tests in a concise and transparent way (see also
#           cet_test_env() and cet_test_assertion(), below).
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
# INSTALL_BIN
#   Install this test's script / exec in the product's binary directory
#   (ignored for HANDBUILT).
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
# REF
#   The standard output of the test will be captured and compared
#    against the specified reference file. It is an error to specify
#    this argument and either the PASS_REGULAR_EXPRESSION or
#    FAIL_REGULAR_EXPRESSION test properties to the TEST_PROPERTIES
#    argument. As for the above-mentioned properties, when speciifed
#    this is the sole arbiter of test success -- the exit code of the
#    test executable is ignored. Note that the specified file is read at
#    CMake processing time, so CMake must be re-run (preferably via
#    buildtool) in order to update the test when the file is changed.
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
#    command, "set_tests_properties."
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
#
# CET_DEFINED_TEST_GROUPS
#  Any test group names CMake sees will be added to this list.
#
########################################################################
# cet_test_env: set environment for all tests here specified.
#
# Usage: cet_test_env([<options] [<env>])
#
####################################
# Options:
#
# CLEAR
#   Clear the global test environment (ie anything previously set with
#    cet_test_env()) before setting <env>.
#
####################################
# Notes:
#
# * <env> may be omitted. If so and the CLEAR option is not specified,
#   then cet_test_env() is a NOP.
#
# * If cet_test_env() is called in a directory to set the environment
#   for tests then that will be propagated to tests defined in
#   subdirectories unless include(CetTest) or cet_test_env(CLEAR ...) is
#   invoked in that directory.
#
########################################################################
# cet_test_assertion: require assertion failure on given condition
#
# Usage: cet_test_assertion(CONDITION TARGET...)
#
####################################
# Notes:
#
# * CONDITION should be a CMake regex which should have any escaped
#   items doubly-escaped due to being passed as a string argument
#   (e.g. "\\\\(" for a literal open-parenthesis, "\\\\." for a literal
#   period).
#
# * TARGET...: the name(s) of the test target(s) as specified to
#   cet_test() or add_test() -- require at least one.
#
########################################################################
cmake_policy(VERSION 3.0.1) # We've made this work for 3.0.1.

# Need argument parser.
include(CMakeParseArguments)
# May need Boost Unit Test Framework library.
include(FindUpsBoost)
# Need cet_script for PREBUILT scripts
include(CetMake)
# May need to escape a string to avoid misinterpretation as regex
include(CetRegexEscape)

# If Boost has been specified but the library hasn't, load the library.
IF((NOT Boost_UNIT_TEST_FRAMEWORK_LIBRARY) AND BOOST_VERS)
  find_ups_boost(${BOOST_VERS} unit_test_framework)
ENDIF() 

SET(CET_TEST_GROUPS "NONE"
  CACHE STRING "List of optional test groups to be configured."
  )


STRING(TOUPPER "${CET_TEST_GROUPS}" CET_TEST_GROUPS_UC)

SET(CET_TEST_ENV ""
  CACHE INTERNAL "Environment to add to every test"
  FORCE
  )

FUNCTION(_update_defined_test_groups)
  IF(ARGC)
    SET(TMP_LIST ${CET_DEFINED_TEST_GROUPS})
    LIST(APPEND TMP_LIST ${ARGN})
    LIST(REMOVE_DUPLICATES TMP_LIST)
    SET(CET_DEFINED_TEST_GROUPS ${TMP_LIST}
      CACHE STRING "List of defined test groups."
      FORCE
      )
  ENDIF()
ENDFUNCTION()

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
# Main macro definitions.
MACRO(cet_test_env)
  CMAKE_PARSE_ARGUMENTS(CET_TEST
    "CLEAR"
    ""
    ""
    ${ARGN}
    )
  IF(CET_TEST_CLEAR)
    SET(CET_TEST_ENV "")
  ENDIF()
  LIST(APPEND CET_TEST_ENV ${CET_TEST_UNPARSED_ARGUMENTS})
ENDMACRO()

FUNCTION(cet_test CET_TARGET)
  # Parse arguments
  IF(${CET_TARGET} MATCHES .*/.*)
    MESSAGE(FATAL_ERROR "${CET_TARGET} shuld not be a path. Use a simple "
      "target name with the HANDBUILT and TEST_EXEC options instead.")
  ENDIF()
  CMAKE_PARSE_ARGUMENTS (CET
    "HANDBUILT;PREBUILT;NO_AUTO;USE_BOOST_UNIT;INSTALL_BIN;INSTALL_EXAMPLE;INSTALL_SOURCE"
    "REF;TEST_EXEC"
    "CONFIGURATIONS;DATAFILES;DEPENDENCIES;LIBRARIES;OPTIONAL_GROUPS;SOURCES;TEST_ARGS;TEST_PROPERTIES"
    ${ARGN}
    )
  IF(${CMAKE_VERSION} VERSION_GREATER "2.8")
    # Set up to handle a per-test work directory for parallel testing.
    SET(CET_TEST_WORKDIR "${CMAKE_CURRENT_BINARY_DIR}/${CET_TARGET}.d")
    STRING(REPLACE "/" "+" wdtarget ${CET_TEST_WORKDIR})
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
  ELSE()
    SET(CET_TEST_EXEC ${EXECUTABLE_OUTPUT_PATH}/${CET_TARGET})
  ENDIF()
  # Assume any remaining arguments are data files.
  IF(CET_UNPARSED_ARGUMENTS)
    SET(CET_DATAFILES ${CET_DATAFILES} ${CET_UNPARSED_ARGUMENTS})
  ENDIF()
  IF(CET_HANDBUILT AND CET_PREBUILT)
    # CET_HANDBUILT and CET_PREBUILT are mutually exclusive.
    MESSAGE(FATAL_ERROR "cet_test: target ${CET_TARGET} cannot have both CET_HANDBUILT "
      "and CET_PREBUILT options set.")
  ELSEIF(CET_PREBUILT) # eg scripts.
    IF (NOT CET_INSTALL_BIN)
      SET(CET_NO_INSTALL "NO_INSTALL")
    ENDIF()
    cet_script(${CET_TARGET} ${CET_NO_INSTALL} DEPENDENCIES ${CET_DEPENDENCIES})
  ELSEIF(NOT CET_HANDBUILT) # Normal build.
    # Build the executable.
    IF(NOT CET_SOURCES) # Useful default.
      SET(CET_SOURCES ${CET_TARGET}.cc)
    ENDIF()
    ADD_EXECUTABLE(${CET_TARGET} ${CET_SOURCES})
    IF(CET_USE_BOOST_UNIT)
      # Make sure we have the correct library available.
      IF (NOT Boost_UNIT_TEST_FRAMEWORK_LIBRARY)
        MESSAGE(FATAL_ERROR "cet_test: target ${CET_TARGET} has USE_BOOST_UNIT "
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
    IF(COMMAND find_tbb_offloads)
      find_tbb_offloads(FOUND_VAR have_tbb_offload ${CET_SOURCES})
      IF(have_tbb_offload)
        SET_TARGET_PROPERTIES(${CET_TARGET} PROPERTIES LINK_FLAGS ${TBB_OFFLOAD_FLAG})
      ENDIF()
    ENDIF()
    TARGET_LINK_LIBRARIES(${CET_TARGET} ${CET_LIBRARIES})
  ENDIF()
  FOREACH(datafile ${CET_DATAFILES})
    # Name the target so that tests in different directories can use the same
    # data file.
    GET_FILENAME_COMPONENT(dfile_basename ${datafile} NAME)
    STRING(REPLACE "/" "+" dtarget "${CET_TEST_WORKDIR}/${dfile_basename}")
    IF(IS_ABSOLUTE ${datafile})
      SET(abs_datafile ${datafile})
    ELSE()
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
  _update_defined_test_groups(${CET_OPTIONAL_GROUPS})
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
    IF(CET_TEST_ENV)
      # Set global environment.
      GET_TEST_PROPERTY(${CET_TARGET} ENVIRONMENT CET_TEST_ENV_TMP)
      IF(CET_TEST_ENV_TMP)
        SET_TESTS_PROPERTIES(${CET_TARGET} PROPERTIES ENVIRONMENT "${CET_TEST_ENV};${CET_TEST_ENV_TMP}")
      ELSE()
        SET_TESTS_PROPERTIES(${CET_TARGET} PROPERTIES ENVIRONMENT "${CET_TEST_ENV}")
      ENDIF()
    ENDIF()
    IF(DEFINED CET_REF)
      GET_TEST_PROPERTY(${CET_TARGET} PASS_REGULAR_EXPRESSION has_pass_exp)
      GET_TEST_PROPERTY(${CET_TARGET} FAIL_REGULAR_EXPRESSION has_fail_exp)
      IF(has_pass_exp OR has_fail_exp)
        MESSAGE(FATAL_ERROR "Cannot specify REF option for test ${CET_TARGET}, which already has\n"
          "(PASS|FAIL)_REGULAR_EXPRESSION property set.")
      ENDIF()
      IF(CET_REF)
        IF(EXISTS "${CET_REF}")
          FILE(READ "${CET_REF}" CET_REF_TEXT)
        ELSE()
          MESSAGE(FATAL_ERROR "Specified REFerence file ${CET_REF} does not exist for test ${CET_TARGET}.")
        ENDIF()
      ENDIF()
      cet_regex_escape("${CET_REF_TEXT}" CET_REF_TEXT)
      SET(CET_REF_TEXT "^${CET_REF_TEXT}$")
      SET_TESTS_PROPERTIES(${CET_TARGET} PROPERTIES PASS_REGULAR_EXPRESSION "${CET_REF_TEXT}")
    ENDIF()
  ENDIF()
  IF(CET_INSTALL_BIN)
    IF(CET_HANDBUILT)
      MESSAGE(WARNING "INSTALL_BIN option ignored for HANDBUILT tests.")
    ELSEIF(NOT CET_PREBUILT)
      INSTALL(TARGETS ${CET_TARGET} DESTINATION ${flavorqual_dir}/bin)
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
ENDFUNCTION(cet_test)

FUNCTION(cet_test_assertion CONDITION FIRST_TARGET)
  IF (${CMAKE_SYSTEM_NAME} MATCHES "Darwin" )
    SET_TESTS_PROPERTIES(${FIRST_TARGET} ${ARGN} PROPERTIES
      PASS_REGULAR_EXPRESSION
      "Assertion failed: \\(${CONDITION}\\), "
      )
  ELSE()
    SET_TESTS_PROPERTIES(${FIRST_TARGET} ${ARGN} PROPERTIES
      PASS_REGULAR_EXPRESSION
      "Assertion `${CONDITION}' failed\\."
      )
  ENDIF()
ENDFUNCTION()
########################################################################
