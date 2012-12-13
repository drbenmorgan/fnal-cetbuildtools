# cet_make
#
# Identify the files in the current source directory and deal with them appropriately
# Users may opt to just include cet_make() in their CMakeLists.txt
# This implementation is intended to be called NO MORE THAN ONCE per subdirectory.
#
# NOTE: cet_make_exec and cet_make_test_exec are no longer part of cet_make 
# or art_make and must be called explicitly.
#
# cet_make( LIBRARY_NAME <library name> 
#           [LIBRARIES <library link list>]
#           [SUBDIRS <source subdirectory>] (e.g., detail)
#           [EXCLUDE <ignore these files>] )
#
# NOTE: if your code includes art plugins, you MUST use art_make instead of cet_make.
# cet_make will ignore all plugin code
#
# cet_make_library( [LIBRARY_NAME <library name>]  
#                   [SOURCE <source code list>] 
#                   [LIBRARIES <library list>] 
#                   [WITH_STATIC_LIBRARY] )
#
# cet_make_exec( NAME <executable name>  
#                [SOURCE <source code list>] 
#                [LIBRARIES <library link list>]
#                [USE_BOOST_UNIT]
#                [NO_INSTALL] )
# -- build a regular executable

include(CetParseArgs)
include(InstallSource)

macro( _cet_find_lib_directory )
  # find $CETBUILDTOOLS_DIR/bin/report_libdir
  set( CETBUILDTOOLS_DIR $ENV{CETBUILDTOOLS_DIR} )
  if( ${product} MATCHES "cetbuildtools" )
      # building cetbuildtools - use our copy
      #message(STATUS "looking in ${PROJECT_SOURCE_DIR}/bin")
      FIND_PROGRAM( REPORT_LIB_DIR report_libdir
                    ${PROJECT_SOURCE_DIR}/bin  )
  elseif( NOT CETBUILDTOOLS_DIR )
      FIND_PROGRAM( REPORT_LIB_DIR report_libdir )
  else()
      FIND_PROGRAM( REPORT_LIB_DIR report_libdir
                    ${CETBUILDTOOLS_DIR}/bin  )
  endif ()
  #message(STATUS "REPORT_LIB_DIR: ${REPORT_LIB_DIR}")
  if( NOT REPORT_LIB_DIR )
      message(FATAL_ERROR "Can't find report_libdir")
  endif()
  #message( STATUS "cet_make: cet_ups_dir is ${cet_ups_dir}")
  execute_process(COMMAND ${REPORT_LIB_DIR} 
                          ${cet_ups_dir} 
                  OUTPUT_VARIABLE REPORT_LIB_DIR_MSG
		  OUTPUT_STRIP_TRAILING_WHITESPACE
		  )
  #message( STATUS "${REPORT_LIB_DIR} returned ${REPORT_LIB_DIR_MSG}")
  if( ${REPORT_LIB_DIR_MSG} MATCHES "DEFAULT" )
     set( cet_make_lib_dir "${flavorqual_dir}/lib" )
  elseif( ${REPORT_LIB_DIR_MSG} MATCHES "NONE" )
      message(FATAL_ERROR "Please specify a lib directory in product_deps")
  elseif( ${REPORT_LIB_DIR_MSG} MATCHES "ERROR" )
      message(FATAL_ERROR "Invalid lib directory in product_deps")
  else()
     set( cet_make_lib_dir "${REPORT_LIB_DIR_MSG}" )
  endif()
endmacro( _cet_find_lib_directory )

macro( _cet_find_bin_directory )
  # find $CETBUILDTOOLS_DIR/bin/report_bindir
  set( CETBUILDTOOLS_DIR $ENV{CETBUILDTOOLS_DIR} )
  if( ${product} MATCHES "cetbuildtools" )
      # building cetbuildtools - use our copy
      #message(STATUS "looking in ${PROJECT_SOURCE_DIR}/bin")
      FIND_PROGRAM( REPORT_BIN_DIR report_bindir
                    ${PROJECT_SOURCE_DIR}/bin  )
  elseif( NOT CETBUILDTOOLS_DIR )
      FIND_PROGRAM( REPORT_BIN_DIR report_bindir )
  else()
      FIND_PROGRAM( REPORT_BIN_DIR report_bindir
                    ${CETBUILDTOOLS_DIR}/bin  )
  endif ()
  #message(STATUS "REPORT_BIN_DIR: ${REPORT_BIN_DIR}")
  if( NOT REPORT_BIN_DIR )
      message(FATAL_ERROR "Can't find report_bindir")
  endif()
  #message( STATUS "cet_make: cet_ups_dir is ${cet_ups_dir}")
  execute_process(COMMAND ${REPORT_BIN_DIR} 
                          ${cet_ups_dir} 
                  OUTPUT_VARIABLE REPORT_BIN_DIR_MSG
		  OUTPUT_STRIP_TRAILING_WHITESPACE
		  )
  #message( STATUS "${REPORT_BIN_DIR} returned ${REPORT_BIN_DIR_MSG}")
  if( ${REPORT_BIN_DIR_MSG} MATCHES "DEFAULT" )
     set( cet_make_bin_dir "${flavorqual_dir}/bin" )
  elseif( ${REPORT_BIN_DIR_MSG} MATCHES "NONE" )
      message(FATAL_ERROR "Please specify a bin directory in product_deps")
  elseif( ${REPORT_BIN_DIR_MSG} MATCHES "ERROR" )
      message(FATAL_ERROR "Invalid bin directory in product_deps")
  else()
     set( cet_make_bin_dir "${REPORT_BIN_DIR_MSG}" )
  endif()
endmacro( _cet_find_bin_directory )

macro( cet_make_exec )
  set(cet_exec_file_list "")
  set(cet_make_exec_usage "USAGE: cet_make_exec( NAME <executable name> [SOURCE <exec source>] [LIBRARIES <library list>] )")
  #message(STATUS "cet_make_exec debug: called with ${ARGN} from ${CMAKE_CURRENT_SOURCE_DIR}")
  cet_parse_args( CME "NAME;LIBRARIES;SOURCE" "USE_BOOST_UNIT;NO_INSTALL" ${ARGN})
  # there are no default arguments
  if( CME_DEFAULT_ARGS )
     message("CET_MAKE_EXEC: Incorrect arguments. ${ARGV}")
     message(SEND_ERROR  ${cet_make_exec_usage})
  endif()
  #message(STATUS "debug: cet_make_exec called with ${CME_NAME} ${CME_LIBRARIES}")
  FILE( GLOB exec_src ${CME_NAME}.c ${CME_NAME}.cc ${CME_NAME}.cpp ${CME_NAME}.C ${CME_NAME}.cxx )
  if( CME_SOURCE )
    set( exec_source_list "${exec_src} ${CME_SOURCE}" )
  else()
    set( exec_source_list ${exec_src} )
  endif()
  add_executable( ${CME_NAME} ${exec_source_list} )
  IF(CME_USE_BOOST_UNIT)
    # Make sure we have the correct library available.
    IF (NOT Boost_UNIT_TEST_FRAMEWORK_LIBRARY)
      MESSAGE(SEND_ERROR "cet_make_exec: target ${CME_NAME} has USE_BOOST_UNIT "
        "option set but Boost Unit Test Framework Library cannot be found: is "
        "boost set up?")
    ENDIF()
    # Compile options (-Dxxx) for simple-format unit tests.
    SET_TARGET_PROPERTIES(${CME_NAME} PROPERTIES
      COMPILE_DEFINITIONS BOOST_TEST_MAIN
      COMPILE_DEFINITIONS BOOST_TEST_DYN_LINK
      )
    TARGET_LINK_LIBRARIES(${CME_NAME} ${Boost_UNIT_TEST_FRAMEWORK_LIBRARY})
  ENDIF()
  if(CME_LIBRARIES)
     target_link_libraries( ${CME_NAME} ${CME_LIBRARIES} )
  endif()
  if(CME_NO_INSTALL)
    #message(STATUS "${CME_NAME} will not be installed")
  else()
    _cet_find_bin_directory()
    #message( STATUS "cet_make_exec: executables will be installed in ${cet_make_bin_dir}")
    install( TARGETS ${CME_NAME} DESTINATION ${cet_make_bin_dir} )
  endif()
endmacro( cet_make_exec )

macro( cet_make )
  set(cet_file_list "")
  set(cet_make_usage "USAGE: cet_make( LIBRARY_NAME <library name> [LIBRARIES <library list>] [SUBDIRS <source subdirectory>] [EXCLUDE <ignore these files>] )")
  #message(STATUS "cet_make debug: called with ${ARGN} from ${CMAKE_CURRENT_SOURCE_DIR}")
  cet_parse_args( CM "LIBRARY_NAME;LIBRARIES;SUBDIRS;EXCLUDE" "WITH_STATIC_LIBRARY" ${ARGN})
  # there are no default arguments
  if( CM_DEFAULT_ARGS )
     message("CET_MAKE: Incorrect arguments. ${ARGV}")
     message(SEND_ERROR  ${cet_make_usage})
  endif()
  # check for extra link libraries
  if(CM_LIBRARIES)
     set(cet_liblist ${CM_LIBRARIES})
  endif()
  # now look for other source files in this directory
  #message(STATUS "cet_make debug: listed files ${cet_file_list}")
  FILE( GLOB src_files *.c *.cc *.cpp *.C *.cxx )
  FILE( GLOB ignore_plugins  *_source.cc *_service.cc  *_module.cc )
  # also check subdirectories
  if( CM_SUBDIRS )
     foreach( sub ${CM_SUBDIRS} )
	FILE( GLOB subdir_src_files ${sub}/*.c ${sub}/*.cc ${sub}/*.cpp ${sub}/*.C ${sub}/*.cxx )
	FILE( GLOB subdir_ignore_plugins  ${sub}/*_source.cc ${sub}/*_service.cc  ${sub}/*_module.cc )
        if( subdir_src_files )
	  list(APPEND  src_files ${subdir_src_files})
        endif( subdir_src_files )
        if( subdir_ignore_plugins )
	  list(APPEND  ignore_plugins ${subdir_ignore_plugins})
        endif( subdir_ignore_plugins )
     endforeach(sub)
  endif( CM_SUBDIRS )
  if( ignore_plugins )
    LIST( REMOVE_ITEM src_files ${ignore_plugins} )
  endif()
  #message(STATUS "cet_make debug: exclude files ${CM_EXCLUDE}")
  if(CM_EXCLUDE)
     foreach( exclude_file ${CM_EXCLUDE} )
         LIST( REMOVE_ITEM src_files ${CMAKE_CURRENT_SOURCE_DIR}/${exclude_file} )
     endforeach( exclude_file )
  endif()
  #message(STATUS "cet_make debug: other files ${src_files}")
  set(have_library FALSE)
  foreach( file ${src_files} )
      #message(STATUS "cet_make debug: checking ${file}")
      set(have_file FALSE)
      foreach( known_file ${cet_file_list} )
         if( "${file}" MATCHES "${known_file}" )
	    set(have_file TRUE)
	 endif()
      endforeach( known_file )
      if( NOT have_file )
         #message(STATUS "cet_make debug: found new file ${file}")
         set(cet_file_list ${cet_file_list} ${file} )
         set(cet_make_library_src ${cet_make_library_src} ${file} )
         set(have_library TRUE)
      endif()
  endforeach(file)
  #message(STATUS "cet_make debug: known files ${cet_file_list}")

  # calculate base name
  STRING( REGEX REPLACE "^${CMAKE_SOURCE_DIR}/(.*)" "\\1" CURRENT_SUBDIR "${CMAKE_CURRENT_SOURCE_DIR}" )
  STRING( REGEX REPLACE "/" "_" cet_make_name "${CURRENT_SUBDIR}" )
  #set(cet_make_name "${cetname2}_${name}_${type}")

  if( have_library )
    #message( STATUS "cet_make debug: building library for ${CMAKE_CURRENT_SOURCE_DIR}")
    if(CM_LIBRARY_NAME)
      set(cet_make_library_name ${CM_LIBRARY_NAME})
    else()
      set(cet_make_library_name ${cet_make_name})
    endif()
    if(CM_LIBRARIES) 
       link_libraries( ${cet_liblist} )
    endif(CM_LIBRARIES) 
    #message( STATUS "cet_make debug: calling add_library with ${cet_make_library_name}  ${cet_make_library_src}") 
    add_library( ${cet_make_library_name} SHARED ${cet_make_library_src} )
    _cet_find_lib_directory()
    message( STATUS "cet_make: libraries will be installed in ${cet_make_lib_dir}")
    install( TARGETS ${cet_make_library_name} DESTINATION ${cet_make_lib_dir} )
  else( )
    message( STATUS "cet_make: no library for ${CMAKE_CURRENT_SOURCE_DIR}")
  endif( )

  # is there a dictionary?
  FILE(GLOB dictionary_header classes.h )
  FILE(GLOB dictionary_xml classes_def.xml )
  if( dictionary_header AND dictionary_xml )
     message( STATUS "cet_make: found dictionary in ${CMAKE_CURRENT_SOURCE_DIR}")
     set(cet_file_list ${cet_file_list} ${dictionary_xml} ${dictionary_header} )
     if(CM_LIBRARIES) 
        build_dictionary( DICTIONARY_LIBRARIES ${cet_liblist} )
     else()
        build_dictionary(  )
     endif()
  endif()

endmacro( cet_make )

macro( cet_make_library )
  set(cet_file_list "")
  set(cet_make_library_usage "USAGE: cet_make_library( LIBRARY_NAME <library name> SOURCE <source code list> [LIBRARIES <library link list>] )")
  #message(STATUS "cet_make_library debug: called with ${ARGN} from ${CMAKE_CURRENT_SOURCE_DIR}")
  cet_parse_args( CML "LIBRARY_NAME;LIBRARIES;SOURCE" "WITH_STATIC_LIBRARY" ${ARGN})
  # there are no default arguments
  if( CML_DEFAULT_ARGS )
     message("CET_MAKE_LIBRARY: Incorrect arguments. ${ARGV}")
     message(SEND_ERROR  ${cet_make_library_usage})
  endif()
  # check for a source code list
  if(CML_SOURCE)
     set(cet_src_list ${CML_SOURCE})
  else()
     message("CET_MAKE_LIBRARY: Incorrect arguments. ${ARGV}")
     message(SEND_ERROR  ${cet_make_library_usage})
  endif()
  add_library( ${CML_LIBRARY_NAME} SHARED ${cet_src_list} )
  if(CML_LIBRARIES)
     target_link_libraries( ${CML_LIBRARY_NAME} ${CML_LIBRARIES} )
  endif()
  _cet_find_lib_directory()
  message( STATUS "cet_make_library: libraries will be installed in ${cet_make_lib_dir}")
  install( TARGETS  ${CML_LIBRARY_NAME} 
	   RUNTIME DESTINATION ${flavorqual_dir}/bin
	   LIBRARY DESTINATION ${cet_make_lib_dir}
	   ARCHIVE DESTINATION ${cet_make_lib_dir}
           )
  if( CML_WITH_STATIC_LIBRARY )
    add_library( ${CML_LIBRARY_NAME}S STATIC ${cet_src_list} )
    if(CML_LIBRARIES)
       target_link_libraries( ${CML_LIBRARY_NAME}S ${CML_LIBRARIES} )
    endif()
    set_target_properties( ${CML_LIBRARY_NAME}S PROPERTIES OUTPUT_NAME ${CML_LIBRARY_NAME} )
    set_target_properties( ${CML_LIBRARY_NAME}  PROPERTIES OUTPUT_NAME ${CML_LIBRARY_NAME} )
    set_target_properties( ${CML_LIBRARY_NAME}S PROPERTIES CLEAN_DIRECT_OUTPUT 1 )
    set_target_properties( ${CML_LIBRARY_NAME}  PROPERTIES CLEAN_DIRECT_OUTPUT 1 )
    install( TARGETS  ${CML_LIBRARY_NAME}S 
	     RUNTIME DESTINATION ${flavorqual_dir}/bin
	     LIBRARY DESTINATION ${cet_make_lib_dir}
	     ARCHIVE DESTINATION ${cet_make_lib_dir}
             )
  endif( CML_WITH_STATIC_LIBRARY )
endmacro( cet_make_library )
