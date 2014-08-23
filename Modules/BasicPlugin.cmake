# macros for building plugin libraries
#
# The plugin type is expected to be service, source, or module,
# but we do not enforce this.
#
# USAGE:
# basic_plugin( <name> <plugin type>
#                [library list]
#                [USE_BOOST_UNIT]
#                [ALLOW_UNDERSCORES]
#                [BASENAME_ONLY]
#                [NO_INSTALL]
#   )
#
# The plugin library's name is constructed from the specified name, its
# specified plugin type (eg service, module, source), and (unless
# BASENAME_ONLY is specified) the package subdirectory path (replacing
# "/" with "_").
#
# Options:
#
# USE_BOOST_UNIT
#
#    Allow the use of Boost Unit Test facilities.
#
# ALLOW_UNDERSCORES
#
#    Allow underscores in subdirectory names. Discouraged, as it creates
#    a possible ambiguity in the encoded plugin library name
#    (art_test/XX is indistinguishable from art/test/XX).
#
# BASENAME_ONLY
#
#    Omit the subdirectory path from the library name. Discouraged, as
#    it creates an ambiguity between modules with the same source
#    filename in different packages or different subdirectories within
#    the same package. The latter case is not possible however, because
#    CMake will throw an error because the two CMake targets will have
#    the same name and that is not permitted.
#
# NO_INSTALL
#
#    If specified, the plugin library will not be part of the installed
#    product (use for test modules, etc.).
#
########################################################################
include(CMakeParseArguments)

macro (_bp_debug_message)
  string(TOUPPER ${CMAKE_BUILD_TYPE} BTYPE_UC)
  if (BTYPE_UC STREQUAL "DEBUG")
    message(STATUS "BASIC_PLUGIN: " ${ARGN})
  endif()
endmacro()

# Basic plugin libraries.
function(basic_plugin name type)
  cmake_parse_arguments(BP
    "USE_BOOST_UNIT;ALLOW_UNDERSCORES;BASENAME_ONLY;NO_INSTALL;NOINSTALL"
    ""
    ""
    ${ARGN})
  if (BP_NOINSTALL)
    message(SEND_ERROR "basic_plugin now requires NO_INSTALL instead of NOINSTALL")
  endif()
  if (BP_BASENAME_ONLY)
    set(plugin_name "${name}_${type}")
  else()
    #message( STATUS "basic_plugin: PACKAGE_TOP_DIRECTORY is ${PACKAGE_TOP_DIRECTORY}")
    # base name on current subdirectory
    if( PACKAGE_TOP_DIRECTORY )
      STRING( REGEX REPLACE "^${PACKAGE_TOP_DIRECTORY}/(.*)" "\\1" CURRENT_SUBDIR "${CMAKE_CURRENT_SOURCE_DIR}" )
    else()
      STRING( REGEX REPLACE "^${CMAKE_SOURCE_DIR}/(.*)" "\\1" CURRENT_SUBDIR "${CMAKE_CURRENT_SOURCE_DIR}" )
    endif()
    if(NOT BP_ALLOW_UNDERSCORES )
      string(REGEX MATCH [_] has_underscore "${CURRENT_SUBDIR}")
      if( has_underscore )
        message(SEND_ERROR  "found underscore in plugin subdirectory: ${CURRENT_SUBDIR}" )
      endif( has_underscore )
      string(REGEX MATCH [_] has_underscore "${name}")
      if( has_underscore )
        message(SEND_ERROR  "found underscore in plugin name: ${name}" )
      endif( has_underscore )
    endif()
    STRING( REGEX REPLACE "/" "_" plugname "${CURRENT_SUBDIR}" )
    set(plugin_name "${plugname}_${name}_${type}")
  endif()
  set(codename "${name}_${type}.cc")
  #message(STATUS "BASIC_PLUGIN: generating ${plugin_name}")
  add_library(${plugin_name} SHARED ${codename} )
  # check the library list and substitute if appropriate
  ##set(basic_plugin_liblist "${BP_UNPARSED_ARGUMENTS}")
  set(basic_plugin_liblist "")
  foreach (lib ${BP_UNPARSED_ARGUMENTS})
    string(REGEX MATCH [/] has_path "${lib}")
    if( has_path )
      list(APPEND basic_plugin_liblist ${lib})   
    else()
      string(TOUPPER  ${lib} ${lib}_UC )
      #_bp_debug_message( "basic_plugin: check ${lib}" )
      if( ${${lib}_UC} )
        _bp_debug_message( "changing ${lib} to ${${${lib}_UC}}")
	list(APPEND basic_plugin_liblist ${${${lib}_UC}})   
      else()
	list(APPEND basic_plugin_liblist ${lib})   
      endif()
    endif( has_path ) 
  endforeach()
  if(BP_USE_BOOST_UNIT)
    set_target_properties(${plugin_name}
      PROPERTIES
      COMPILE_DEFINITIONS BOOST_TEST_DYN_LINK
      COMPILE_FLAGS -Wno-overloaded-virtual
      )
    list(INSERT basic_plugin_liblist 0 ${Boost_UNIT_TEST_FRAMEWORK_LIBRARY})
  endif()
  if(COMMAND find_tbb_offloads)
    find_tbb_offloads(FOUND_VAR have_tbb_offload ${codename})
    if(have_tbb_offload)
      set_target_properties(${plugin_name} PROPERTIES LINK_FLAGS ${TBB_OFFLOAD_FLAG})
    endif()
  endif()
  list(LENGTH basic_plugin_liblist liblist_length)
  if( liblist_length GREATER 0 )
    target_link_libraries( ${plugin_name} ${basic_plugin_liblist} )
  endif( liblist_length GREATER 0 )
  if( NOT BP_NO_INSTALL )
    install( TARGETS ${plugin_name}  DESTINATION ${flavorqual_dir}/lib )
    cet_add_to_library_list( ${plugin_name} )
  endif()
endfunction(basic_plugin name type)