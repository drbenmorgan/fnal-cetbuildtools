########################################################################
# cet_test: specify tests in a concise and transparent way (see also
#           cet_test_env() and cet_test_assertion(), below).
#
# Usage: cet_test(target [<options>] [<args>])
#
####################################
# Target category options (specify at most one):
#
# HANDBUILT
#
#   Do not build the target -- it will be provided.
#
# PREBUILT
#
#   Do not build the target -- copy in from the source dir (ideal for
#   e.g. scripts).
#
# USE_CATCH_MAIN
#
#   This test will use the Catch test framework
#   (https://github.com/philsquared/Catch). The specified target will be
#   built from a precompiled main program to run tests described in the
#   files specified by SOURCES.
#
#   N.B.: if you wish to use the ParseAndAddCatchTests() facility
#   contributed to the Catch system, you should specify NO_AUTO to avoid
#   generating a, "standard" test. Note also that you may have your own
#   test executables using Catch without using USE_CATCH_MAIN. However,
#   be aware that the compilation of a Catch main is quite expensive,
#   and any tests that *do* use this option will all share the same
#   compiled main.
#
#   Note also that client packages are responsible for making sure Catch
#   is available, such as with:
#
#     catch		<version>		-nq-	only_for_build
#
#   in product_deps.
#
####################################
# Other options:
#
# CONFIGURATIONS <config>+
#
#   Configurations (Debug, etc, etc) under which the test shall be
#   executed.
#
# DATAFILES <datafile>+
#
#   Input and/or references files to be copied to the test area in the
#   build tree for use by the test. If there is no path, or a relative
#   path, the file is assumed to be in or under
#   ${CMAKE_CURRENT_SOURCE_DIR}.
#
# DEPENDENCIES <dep>+
#
#   List of top-level dependencies to consider for a PREBUILT
#   target. Top-level implies a target (not file) created with
#   ADD_EXECUTABLE, ADD_LIBRARY or ADD_CUSTOM_TARGET.
#
# INSTALL_BIN
#
#   Install this test's script / exec in the product's binary directory
#   (ignored for HANDBUILT).
#
# INSTALL_EXAMPLE
#
#   Install this test and all its data files into the examples area of
#   the product.
#
# INSTALL_SOURCE
#
#   Install this test's source in the source area of the product.
#
# LIBRARIES <lib>+
#
#   Extra libraries with which to link this target.
#
# NO_AUTO
#
#   Do not add the target to the auto test list. N.B. all options
#   related to the declaration of tests and setting of properties
#   thereof will be ignored.
#
# OPTIONAL_GROUPS <group>+
#
#   Assign this test to one or more named optional groups. If the CMake
#   list variable CET_TEST_GROUPS is set (e.g. with -D on the CMake
#   command line) and there is overlap between the two lists, execute
#   the test. The CET_TEST_GROUPS cache variable may additionally
#   contain the optional values ALL or NONE.
#
# PARG_<label> <opt>[=] <args>+
#
#   Specify a permuted argument (multiple permitted with different
#   <label>). This allows the creation of multiple tests with arguments
#   from a set of permutations.
#
#   Labels must be unique, valid CMake identifiers. Duplicated labels
#   will cause an error.
#
#   If multiple PARG_XXX arguments are specified, then they are combined
#   linearly, with shorter permutation lists being repeated cyclically.
#
#   If the '=' is specified, then the argument lists for successive test
#   iterations will get <opt>=v1, <opt>=v2, etc., otherwise it will be
#   <opt> v1, <opt> v2, ...
#
#   Target names will have _<num> appended, where num is zero-padded to
#   give the same number of digits for each target within the set.
#
#   Permuted arguments will be placed before any specifed TEST_ARGS in
#   the order the PARG_<label> arguments were specified to cet_test().
#
#   There is no support for non-option argument toggling as yet, but
#   addition of such support should be straightforward should the use
#   case arise.
#
# REF <ref-file>
#
#  The standard output of the test will be captured and compared against
#   the specified reference file. It is an error to specify this
#   argument and either the PASS_REGULAR_EXPRESSION or
#   FAIL_REGULAR_EXPRESSION test properties to the TEST_PROPERTIES
#   argument: success is the logical AND of the exit code from execution
#   of the test as originally specified, and the success of the
#   filtering and subsequent comparison of the output (and optionally,
#   the error stream). Optionally, a second element may be specified
#   representing a reference for the error stream; otherwise, standard
#   error will be ignored.
#
#   If REF is specified, then OUTPUT_FILTERS may also be specified
#   (OUTPUT_FILTER and optionally OUTPUT_FILTER_ARGS will be accepted in
#   the alternative for historical reasons). OUTPUT_FILTER must be a
#   program which expects input on STDIN and puts the filtered output on
#   STDOUT. OUTPUT_FILTERS should be a list of filters expecting input
#   on STDIN and putting output on STDOUT. If DEFAULT is specified as a
#   filter, it will be replaced at that point in the list of filters by
#   appropriate defaults. Examples:
#
#     OUTPUT_FILTERS "filterA -x -y \"arg with spaces\"" filterB
#
#     OUTPUT_FILTERS filterA DEFAULT filterB
#
# REQUIRED_FILES <file>+
#
#   These files are required to be present before the test will be
#   executed. If any are missing, ctest will record NOT RUN for this
#   test.
#
# SCOPED
#
#   Test (but not script or compiled executable) target names will be
#   scoped by product name (<prod>:...).
#
# SOURCES <source>+
#
#   Sources to use to build the target (default is ${target}.cc).
#
# TEST_ARGS <arg>+
#
#   Any arguments to the test to be run.
#
# TEST_EXEC <exec>
#
#   The exec to run (if not the target). The HANDBUILT option must be
#   specified in conjunction with this option.
#
# TEST_PROPERTIES <PROP val>+
#
#   Properties to be added to the test. See documentation of the cmake
#   command, "set_tests_properties."
#
# USE_BOOST_UNIT
#
#   This test uses the Boost Unit Test Framework.
#
####################################
# Cached variables.
#
# CET_CATCH_CMAKE_PATH
#   Path by which to find the ParseAndAddCatchTests.cmake file
#   from the catch system, required if TEST_PER_CATCH_CASE is specified.
#
# CET_TEST_GROUPS
#   Test group names specified using the OPTIONAL_GROUPS list option are
#   compared against this list to determine whether to configure the
#   test. Default value is the special value "NONE," meaning no optional
#   tests are to be configured. Optionally CET_TEST_GROUPS may contain
#   the special value "ALL." Specify multiple values separated by ";"
#   (escape or protect with quotes) or "," See explanation of the
#   OPTIONAL_GROUPS variable above for more details.
#
# CET_DEFINED_TEST_GROUPS
#   Any test group names CMake sees will be added to this list.
#
####################################
# Notes:
#
# * cet_make_exec() and art_make_exec() are more flexible than building
#   the test exec with cet_test(), and are to be preferred (use the
#   NO_INSTALL option to same as appropriate). Use
#   cet_test(... HANDBUILT TEST_EXEC ...) to use test execs built this
#   way.
#
# * The CMake properties PASS_REGULAR_EXPRESSION and
#   FAIL_REGULAR_EXPRESSION are incompatible with the REF option, but we
#   cannot check for them if you use CMake's add_tests_properties()
#   rather than cet_test(CET_TEST_PROPERTIES ...).
#
# * If you intend to set the property SKIP_RETURN_CODE, you should use
#   CET_TEST_PROPERTIES to set it rather than add_tests_properties(), as
#   cet_test() needs to take account of your preference.
#
########################################################################

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
# Need argument parser.
include(CMakeParseArguments)
# Copy function.
include(CetCopy)
# May need Boost Unit Test Framework library.
include(FindUpsBoost)
# Need cet_script for PREBUILT scripts
include(CetMake)
# May need to escape a string to avoid misinterpretation as regex
include(CetRegexEscape)
# Compatibility with older packages.
include(CheckUpsVersion)

cmake_policy(PUSH)
cmake_policy(VERSION 3.3) # For if(IN_LIST)

find_file(CET_CATCH_MAIN_SOURCE cet_catch_main.cpp PATH_SUFFIXES src)

if (DEFINED ENV{ART_VERSION})
  check_ups_version(art $ENV{ART_VERSION} v2_01_00RC1 PRODUCT_OLDER_VAR CT_NEED_ART_COMPAT)
elseif (DEFINED ENV{CETPKG_SOURCE})
  if ((EXISTS $ENV{CETPKG_SOURCE}/art/tools/migration AND NOT EXISTS $ENV{CETPKG_SOURCE}/art/tools/filter-timeTracker-output) OR
      (EXISTS $ENV{CETPKG_SOURCE}/tools/migration AND NOT EXISTS $ENV{CETPKG_SOURCE}/tools/filter-timeTracker-output))
    set(CT_NEED_ART_COMPAT TRUE)
  endif()
endif()
if (CT_NEED_ART_COMPAT)
  message(STATUS "Using or building art OLDER than v2_01_00RC1: using -DART_COMPAT=1 for REF tests.")
  set(DEFINE_ART_COMPAT -DART_COMPAT=1)
endif()

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

# - Programs and Modules
# Default comparator
set(CET_RUNANDCOMPARE "${CMAKE_CURRENT_LIST_DIR}/RunAndCompare.cmake")
# Test run wrapper
set(CET_CET_EXEC_TEST "${cetbuildtools_BINDIR}/cet_exec_test")

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

function(_cet_process_pargs NTEST_VAR)
  set(NTESTS 1)
  foreach (label ${ARGN})
    list(LENGTH CETP_PARG_${label} ${label}_length)
    math(EXPR ${label}_length "${${label}_length} - 1")
    if (NOT ${label}_length)
      message(FATAL_ERROR "For test ${TEST_TARGET_NAME}: Permuted options are not yet supported.")
    endif()
    if (${label}_length GREATER NTESTS)
      set(NTESTS ${${label}_length})
    endif()
    list(GET CETP_PARG_${label} 0 ${label}_arg)
    set(${label}_arg ${${label}_arg} PARENT_SCOPE)
    list(REMOVE_AT CETP_PARG_${label} 0)
    set(CETP_PARG_${label} ${CETP_PARG_${label}} PARENT_SCOPE)
    set(${label}_length ${${label}_length} PARENT_SCOPE)
  endforeach()
  foreach (label ${ARGN})
    if (${label}_length LESS NTESTS)
      # Need to pad
      math(EXPR nextra "${NTESTS} - ${${label}_length}")
      set(nind 0)
      while (nextra)
        math(EXPR lind "${nind} % ${${label}_length}")
        list(GET CETP_PARG_${label} ${lind} item)
        list(APPEND CETP_PARG_${label} ${item})
        math(EXPR nextra "${nextra} - 1")
        math(EXPR nind "${nind} + 1")
      endwhile()
      set(CETP_PARG_${label} ${CETP_PARG_${label}} PARENT_SCOPE)
    endif()
  endforeach()
  set(${NTEST_VAR} ${NTESTS} PARENT_SCOPE)
endfunction()

function(_cet_print_pargs)
  string(TOUPPER "${CMAKE_BUILD_TYPE}" BTYPE_UC)
  if (NOT BTYPE_UC STREQUAL "DEBUG")
    return()
  endif()
  list(LENGTH ARGN nlabels)
  if (NOT nlabels)
    return()
  endif()
  message(STATUS "Test ${TEST_TARGET_NAME}: found ${nlabels} labels for permuted test arguments")
  foreach (label ${ARGN})
    message(STATUS "  Label: ${label}, arg: ${${label}_arg}, # vals: ${${label}_length}, vals: ${CETP_PARG_${label}}")
  endforeach()
  message(STATUS "  Calculated ${NTESTS} tests")
endfunction()

function(_cet_test_pargs VAR)
  foreach (label ${parg_labels})
    list(GET CETP_PARG_${label} ${tid} arg)
    if (${label}_arg MATCHES "=\$")
      list(APPEND test_args "${${label}_arg}${arg}")
    else()
      list(APPEND test_args ${${label}_arg} ${arg})
    endif()
  endforeach()
  set(${VAR} ${test_args} ${ARGN} PARENT_SCOPE)
endfunction()

function(_cet_add_test_detail TNAME)
  _cet_test_pargs(test_args ${ARGN})
  add_test(NAME "${TNAME}"
    ${CONFIGURATIONS_CMD} ${CET_CONFIGURATIONS}
    COMMAND
    ${CET_CET_EXEC_TEST} --wd ${CET_TEST_WORKDIR}
    --required-files "${CET_REQUIRED_FILES}"
    --datafiles "${CET_DATAFILES}"
    --skip-return-code ${skip_return_code}
    ${CET_TEST_EXEC} ${test_args})
endfunction()

function(_cet_add_test)
  if (${NTESTS} EQUAL 1)
    _cet_add_test_detail(${TEST_TARGET_NAME} ${ARGN})
    list(APPEND ALL_TEST_TARGETS ${TEST_TARGET_NAME})
  else()
    math(EXPR tidmax "${NTESTS} - 1")
    string(LENGTH "${tidmax}" nd)
    foreach (tid RANGE ${tidmax})
      execute_process(COMMAND printf "${TEST_TARGET_NAME}_%0${nd}d" ${tid}
        OUTPUT_VARIABLE tname
        OUTPUT_STRIP_TRAILING_WHITESPACE
        )
      _cet_add_test_detail(${tname} ${ARGN})
      list(APPEND ALL_TEST_TARGETS ${tname})
    endforeach()
  endif()
  set(ALL_TEST_TARGETS ${ALL_TEST_TARGETS} PARENT_SCOPE)
endfunction()

function(_cet_add_ref_test_detail TNAME)
  _cet_test_pargs(tmp_args ${ARGN})
  separate_arguments(test_args UNIX_COMMAND "${tmp_args}")
  add_test(NAME "${TNAME}"
    ${CONFIGURATIONS_CMD} ${CET_CONFIGURATIONS}
    COMMAND ${CET_CET_EXEC_TEST} --wd ${CET_TEST_WORKDIR}
    --required-files "${CET_REQUIRED_FILES}"
    --datafiles "${CET_DATAFILES}"
    --skip-return-code ${skip_return_code}
    ${CMAKE_COMMAND}
    -DTEST_EXEC=${CET_TEST_EXEC}
    -DTEST_ARGS=${test_args}
    -DTEST_REF=${OUTPUT_REF}
    ${DEFINE_ERROR_REF}
    ${DEFINE_TEST_ERR}
    -DTEST_OUT=${CET_TARGET}.out
    ${DEFINE_OUTPUT_FILTER} ${DEFINE_OUTPUT_FILTER_ARGS} ${DEFINE_OUTPUT_FILTERS}
    ${DEFINE_ART_COMPAT}
    -P ${CET_RUNANDCOMPARE}
    )
endfunction()

function(_cet_add_ref_test)
  if (${NTESTS} EQUAL 1)
    _cet_add_ref_test_detail(${TEST_TARGET_NAME} ${ARGN})
    list(APPEND ALL_TEST_TARGETS ${TEST_TARGET_NAME})
  else()
    math(EXPR tidmax "${NTESTS} - 1")
    string(LENGTH "${tidmax}" nd)
    foreach (tid RANGE ${tidmax})
      execute_process(COMMAND printf "${TEST_TARGET_NAME}_%0${nd}d" ${tid}
        OUTPUT_VARIABLE tname
        OUTPUT_STRIP_TRAILING_WHITESPACE
        )
      _cet_add_ref_test_detail(${tname} ${ARGN})
      list(APPEND ALL_TEST_TARGETS ${tname})
    endforeach()
  endif()
  set(ALL_TEST_TARGETS ${ALL_TEST_TARGETS} PARENT_SCOPE)
endfunction()

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
    "HANDBUILT;PREBUILT;USE_CATCH_MAIN;NO_AUTO;USE_BOOST_UNIT;INSTALL_BIN;INSTALL_EXAMPLE;INSTALL_SOURCE;SCOPED"
    "OUTPUT_FILTER;TEST_EXEC"
    "CONFIGURATIONS;DATAFILES;DEPENDENCIES;LIBRARIES;OPTIONAL_GROUPS;OUTPUT_FILTERS;OUTPUT_FILTER_ARGS;REQUIRED_FILES;SOURCES;TEST_ARGS;TEST_PROPERTIES;REF"
    ${ARGN}
    )
  IF (CET_OUTPUT_FILTERS AND CET_OUTPUT_FILTER_ARGS)
    MESSAGE(FATAL_ERROR "OUTPUT_FILTERS is incompatible with FILTER_ARGS:\nEither use the singular OUTPUT_FILTER or use double-quoted strings in OUTPUT_FILTERS\nE.g. OUTPUT_FILTERS \"filter1 -x -y\" \"filter2 -y -z\"")
  ENDIF()

  # If GLOBAL is not set, prepend ${product}: to the target name
  IF (CET_SCOPED)
    SET(TEST_TARGET_NAME "${product}:${CET_TARGET}")
  ELSE()
    SET(TEST_TARGET_NAME "${CET_TARGET}")
  ENDIF()

  # Find any arguments related to permuted test arguments.
  foreach (OPT ${CET_UNPARSED_ARGUMENTS})
    if (OPT MATCHES "^PARG_([A-Za-z_][A-Za-z0-9_]*)$")
      if (OPT IN_LIST parg_option_names)
        message(FATAL_ERROR "For test ${TEST_TARGET_NAME}, permuted argument label ${CMAKE_MATCH_1} specified multiple times.")
      endif()
      list(APPEND parg_option_names ${OPT})
      list(APPEND parg_labels ${CMAKE_MATCH_1})
    endif()
  endforeach()
  cmake_parse_arguments(CETP "" "PERMUTE" "PERMUTE_OPTS;${parg_option_names}" "${CET_UNPARSED_ARGUMENTS}")
  if (CETP_PERMUTE)
    message(FATAL_ERROR "PERMUTE is a keyword reserved for future functionality.")
  elseif(CETP_PERMUTE_OPTS)
    message(FATAL_ERROR "PERMUTE_OPTS is a keyword reserved for future functionality.")
  endif()
  list(LENGTH parg_labels NPARG_LABELS)
  _cet_process_pargs(NTESTS "${parg_labels}")
  _cet_print_pargs("${parg_labels}")

  # Set up to handle a per-test work directory for parallel testing.
  SET(CET_TEST_WORKDIR "${CMAKE_CURRENT_BINARY_DIR}/${CET_TARGET}.d")
  file(MAKE_DIRECTORY "${CET_TEST_WORKDIR}")
  IF(CET_TEST_EXEC)
    IF(NOT CET_HANDBUILT)
      MESSAGE(FATAL_ERROR "cet_test: target ${CET_TARGET} cannot specify "
        "TEST_EXEC without HANDBUILT")
    ENDIF()
  ELSE()
    SET(CET_TEST_EXEC ${EXECUTABLE_OUTPUT_PATH}/${CET_TARGET})
  ENDIF()
  IF(CETP_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "cet_test: Unparsed (non-option) arguments detected: \"${CETP_UNPARSED_ARGUMENTS}\"
Check for missing keyword(s) in the definition of test ${CET_TARGET} in your CMakeLists.txt.")
  ENDIF()
  if (DEFINED CET_DATAFILES)
    list(REMOVE_DUPLICATES CET_DATAFILES)
    set(datafiles_tmp)
    foreach (df ${CET_DATAFILES})
      get_filename_component(dfd ${df} DIRECTORY)
      if (dfd)
        list(APPEND datafiles_tmp ${df})
      else(dfd)
        list(APPEND datafiles_tmp ${CMAKE_CURRENT_SOURCE_DIR}/${df})
      endif(dfd)
    endforeach()
    set(CET_DATAFILES ${datafiles_tmp})
  endif(DEFINED CET_DATAFILES)
  IF((CET_HANDBUILT AND CET_PREBUILT) OR
      (CET_HANDBUILT AND CET_USE_CATCH_MAIN) OR
      (CET_PREBUILT AND CET_USE_CATCH_MAIN))
    # CET_HANDBUILT, CET_PREBUILT and CET_USE_CATCH_MAIN are mutually exclusive.
    MESSAGE(FATAL_ERROR "cet_test: target ${CET_TARGET} must have only one of the"
      " CET_HANDBUILT, CET_PREBUILT, or CET_USE_CATCH_MAIN options set.")
  ELSEIF(CET_PREBUILT) # eg scripts.
    IF (NOT CET_INSTALL_BIN)
      SET(CET_NO_INSTALL "NO_INSTALL")
    ENDIF()
    cet_script(${CET_TARGET} ${CET_NO_INSTALL} DEPENDENCIES ${CET_DEPENDENCIES})
  ELSEIF(NOT CET_HANDBUILT) # Normal build, possibly with CET_USE_CATCH_MAIN set.
    # Build the executable.
    IF(NOT CET_SOURCES) # Useful default.
      SET(CET_SOURCES ${CET_TARGET}.cc)
    ENDIF()
    IF(CET_USE_CATCH_MAIN)
      IF(NOT TARGET cet_catch_main) # Make sure we only build one!
        IF (NOT CET_CATCH_MAIN_SOURCE)
          MESSAGE(FATAL_ERROR "cet_test() INTERNAL ERROR: unable to find cet_catch_main.cpp required by USE_CATCH_MAIN")
        ENDIF()
        ADD_LIBRARY(cet_catch_main STATIC EXCLUDE_FROM_ALL ${CET_CATCH_MAIN_SOURCE})
        SET_PROPERTY(TARGET cet_catch_main PROPERTY ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})
        IF (DEFINED ENV{CATCH_INC})
          TARGET_INCLUDE_DIRECTORIES(cet_catch_main PUBLIC $ENV{CATCH_INC})
        ENDIF()
        # Strip (x10 shrinkage on Linux with GCC 6.3.0)!
        ADD_CUSTOM_COMMAND(TARGET cet_catch_main POST_BUILD
          COMMAND strip -S $<TARGET_FILE:cet_catch_main>
          COMMENT "Stripping Catch main library"
          )
      ENDIF()
    ENDIF()
    ADD_EXECUTABLE(${CET_TARGET} ${CET_SOURCES})
    IF (CET_USE_CATCH_MAIN AND DEFINED ENV{CATCH_INC})
      TARGET_INCLUDE_DIRECTORIES(${CET_TARGET} PUBLIC $ENV{CATCH_INC})
      TARGET_LINK_LIBRARIES(${CET_TARGET} cet_catch_main)
    ENDIF()
    IF(CET_USE_BOOST_UNIT)
      # Make sure we have the correct library available.
      IF (NOT Boost_UNIT_TEST_FRAMEWORK_LIBRARY)
        MESSAGE(FATAL_ERROR "cet_test: target ${CET_TARGET} has USE_BOOST_UNIT "
          "option set but Boost Unit Test Framework Library cannot be found: is "
          "boost set up?")
      ENDIF()
      # Compile options (-Dxxx) for simple-format unit tests.
      SET_TARGET_PROPERTIES(${CET_TARGET} PROPERTIES
        COMPILE_DEFINITIONS "BOOST_TEST_MAIN;BOOST_TEST_DYN_LINK"
        )
      TARGET_LINK_LIBRARIES(${CET_TARGET} ${Boost_UNIT_TEST_FRAMEWORK_LIBRARY})
    ENDIF()
    IF(COMMAND find_tbb_offloads)
      find_tbb_offloads(FOUND_VAR have_tbb_offload ${CET_SOURCES})
      IF(have_tbb_offload)
        SET_TARGET_PROPERTIES(${CET_TARGET} PROPERTIES LINK_FLAGS ${TBB_OFFLOAD_FLAG})
      ENDIF()
    ENDIF()
    if(CET_LIBRARIES)
      set(link_lib_list "")
      foreach (lib ${CET_LIBRARIES})
	      string(REGEX MATCH [/] has_path "${lib}")
	      if( has_path )
	        list(APPEND link_lib_list ${lib})
	      else()
	        string(TOUPPER  ${lib} ${lib}_UC )
	        #_cet_debug_message( "simple_plugin: check ${lib}" )
	        if( ${${lib}_UC} )
            _cet_debug_message( "changing ${lib} to ${${${lib}_UC}}")
            list(APPEND link_lib_list ${${${lib}_UC}})
	        else()
            list(APPEND link_lib_list ${lib})
	        endif()
	      endif( has_path )
      endforeach()
      TARGET_LINK_LIBRARIES(${CET_TARGET} ${link_lib_list})
    endif()
  ENDIF()
  cet_copy(${CET_DATAFILES} DESTINATION ${CET_TEST_WORKDIR} WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
  IF(CET_CONFIGURATIONS)
    SET(CONFIGURATIONS_CMD CONFIGURATIONS)
  ENDIF()
  _update_defined_test_groups(${CET_OPTIONAL_GROUPS})
  _check_want_test("${CET_OPTIONAL_GROUPS}" WANT_TEST)
  IF(NOT CET_NO_AUTO AND WANT_TEST)
    LIST(FIND CET_TEST_PROPERTIES SKIP_RETURN_CODE skip_return_code)
    IF (skip_return_code GREATER -1)
      MATH(EXPR skip_return_code "${skip_return_code} + 1")
      LIST(GET CET_TEST_PROPERTIES ${skip_return_code} skip_return_code)
    ELSE()
      SET(skip_return_code 247)
      LIST(APPEND CET_TEST_PROPERTIES SKIP_RETURN_CODE ${skip_return_code})
    ENDIF()
    IF(CET_REF)
      LIST(FIND CET_TEST_PROPERTIES PASS_REGULAR_EXPRESSION has_pass_exp)
      LIST(FIND CET_TEST_PROPERTIES FAIL_REGULAR_EXPRESSION has_fail_exp)
      IF(has_pass_exp GREATER -1 OR has_fail_exp GREATER -1)
        MESSAGE(FATAL_ERROR "Cannot specify REF option for test ${CET_TARGET} in conjunction with (PASS|FAIL)_REGULAR_EXPESSION.")
      ENDIF()
      LIST(LENGTH CET_REF CET_REF_LEN)
      IF(CET_REF_LEN EQUAL 1)
        SET(OUTPUT_REF ${CET_REF})
      ELSE()
        LIST(GET CET_REF 0 OUTPUT_REF)
        LIST(GET CET_REF 1 ERROR_REF)
        SET(DEFINE_ERROR_REF "-DTEST_REF_ERR=${ERROR_REF}")
        SET(DEFINE_TEST_ERR "-DTEST_ERR=${CET_TARGET}.err")
      ENDIF()
      IF(CET_OUTPUT_FILTER)
        SET(DEFINE_OUTPUT_FILTER "-DOUTPUT_FILTER=${CET_OUTPUT_FILTER}")
        IF(CET_OUTPUT_FILTER_ARGS)
          SEPARATE_ARGUMENTS(FILTER_ARGS UNIX_COMMAND "${CET_OUTPUT_FILTER_ARGS}")
          SET(DEFINE_OUTPUT_FILTER_ARGS "-DOUTPUT_FILTER_ARGS=${FILTER_ARGS}")
        ENDIF()
      ELSEIF(CET_OUTPUT_FILTERS)
        STRING(REPLACE ";" "::" DEFINE_OUTPUT_FILTERS "${CET_OUTPUT_FILTERS}")
        SET(DEFINE_OUTPUT_FILTERS "-DOUTPUT_FILTERS=${DEFINE_OUTPUT_FILTERS}")
      ENDIF()
      _cet_add_ref_test(${CET_TEST_ARGS})
    ELSE(CET_REF)
      _cet_add_test(${CET_TEST_ARGS})
    ENDIF(CET_REF)
    IF(${CMAKE_VERSION} VERSION_GREATER "2.8")
      SET_TESTS_PROPERTIES(${ALL_TEST_TARGETS} PROPERTIES WORKING_DIRECTORY ${CET_TEST_WORKDIR})
    ENDIF()
    IF(CET_TEST_PROPERTIES)
      SET_TESTS_PROPERTIES(${ALL_TEST_TARGETS} PROPERTIES ${CET_TEST_PROPERTIES})
    ENDIF()
    FOREACH (target ${ALL_TEST_TARGETS})
      IF(CET_TEST_ENV)
        # Set global environment.
        GET_TEST_PROPERTY(${target} ENVIRONMENT CET_TEST_ENV_TMP)
        IF(CET_TEST_ENV_TMP)
          SET_TESTS_PROPERTIES(${target} PROPERTIES ENVIRONMENT "${CET_TEST_ENV};${CET_TEST_ENV_TMP}")
        ELSE()
          SET_TESTS_PROPERTIES(${target} PROPERTIES ENVIRONMENT "${CET_TEST_ENV}")
        ENDIF()
      ENDIF()
      IF(CET_REF)
        GET_TEST_PROPERTY(${target} REQUIRED_FILES REQUIRED_FILES_TMP)
        IF(REQUIRED_FILES_TMP)
          SET_TESTS_PROPERTIES(${target} PROPERTIES REQUIRED_FILES "${REQUIRED_FILES_TMP};${CET_REF}")
        ELSE()
          SET_TESTS_PROPERTIES(${target} PROPERTIES REQUIRED_FILES "${CET_REF}")
        ENDIF()
      ENDIF()
    ENDFOREACH()
  ELSE(NOT CET_NO_AUTO AND WANT_TEST)
    IF(CET_OUTPUT_FILTER OR CET_OUTPUT_FILTER_ARGS)
      MESSAGE(FATAL_ERROR "OUTPUT_FILTER and OUTPUT_FILTER_ARGS are not accepted if REF is not specified.")
    ENDIF()
  ENDIF(NOT CET_NO_AUTO AND WANT_TEST)
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

cmake_policy(POP)
