########################################################################
# install_source()
#   Install source code for debugging purposes.
#   Default extensions:
#      .cc .c .cpp .C .cxx
#      .h .hh .H .hpp .icc
#      .xml
#     .sh .py .pl .rb
#
# install_headers()
#   Install headers for inclusion by other packages.
#   Default extensions:
#      .h .hh .H .hpp .icc
#
# install_scripts()
#   Install scripts in the package binary directory.
#   Default extensions:
#     .sh .py .pl .rb
#
# install_fhicl()
#   Install fhicl scripts in a top level fcl subdirectory
#   Default extensions:
#     .fcl
#
# The SUBDIRS option allows you to search subdirectories (e.g. a detail subdirectory)
#
# The EXTRAS option is intended to allow you to pick up extra files not otherwise found.
# They should be specified by relative path (eg f1, subdir1/f2, etc.).
#
# The EXCLUDES option will exclude the specified files from the installation list.
#
# The LIST option allows you to install from a list. When LIST is used,
# we do not search for other files to install. Note that the LIST and
# SUBDIRS options are mutually exclusive.
#
####################################
# Recommended use:
#
# install_source( [SUBDIRS subdirectory_list] 
#                 [EXTRAS extra_files] 
#                 [EXCLUDES exclusions] )
# install_source( LIST file_list )
#
# install_headers( [SUBDIRS subdirectory_list] 
#                  [EXTRAS extra_files]
#                  [EXCLUDES exclusions] )
# install_headers( LIST file_list )
#
# install_fhicl( [SUBDIRS subdirectory_list]
#                [EXTRAS extra_files]
#                [EXCLUDES exclusions] )
# install_fhicl( LIST file_list )
#
# install_scripts( [SUBDIRS subdirectory_list]
#                  [EXTRAS extra_files]
#                  [EXCLUDES exclusions] )
# install_scripts( LIST file_list )
#
# set_install_root() defines PACKAGE_TOP_DIR
#
########################################################################

include(CetParseArgs)

macro( set_install_root )
  set( PACKAGE_TOP_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
  message( STATUS "set_install_root: PACKAGE_TOP_DIRECTORY is ${PACKAGE_TOP_DIRECTORY}")
endmacro( set_install_root )

macro( _cet_check_inc_directory )
  if( ${${product}_inc_dir} MATCHES "NONE" )
     message(FATAL_ERROR "Please specify an include directory in product_deps")
  elseif( ${${product}_inc_dir} MATCHES "ERROR" )
     message(FATAL_ERROR "Invalid include directory in product_deps")
  endif()
endmacro( _cet_check_inc_directory )

macro( _cet_check_build_directory )
  FILE(GLOB build_directory_files
	    ${CMAKE_CURRENT_BINARY_DIR}/[^.]*.cc
	    ${CMAKE_CURRENT_BINARY_DIR}/[^.]*.c
	    ${CMAKE_CURRENT_BINARY_DIR}/[^.]*.cpp
	    ${CMAKE_CURRENT_BINARY_DIR}/[^.]*.C
	    ${CMAKE_CURRENT_BINARY_DIR}/[^.]*.cxx
	    ${CMAKE_CURRENT_BINARY_DIR}/[^.]*.h
	    ${CMAKE_CURRENT_BINARY_DIR}/[^.]*.hh
	    ${CMAKE_CURRENT_BINARY_DIR}/[^.]*.H
	    ${CMAKE_CURRENT_BINARY_DIR}/[^.]*.hpp
	    ${CMAKE_CURRENT_BINARY_DIR}/[^.]*.icc
	    ${CMAKE_CURRENT_BINARY_DIR}/[^.]*.xml
	    ${CMAKE_CURRENT_BINARY_DIR}/[^.]*.sh
	    ${CMAKE_CURRENT_BINARY_DIR}/[^.]*.py
	    ${CMAKE_CURRENT_BINARY_DIR}/[^.]*.pl
	    ${CMAKE_CURRENT_BINARY_DIR}/[^.]*.rb
	    )
  FILE(GLOB build_directory_headers
	    ${CMAKE_CURRENT_BINARY_DIR}/[^.]*.h
	    ${CMAKE_CURRENT_BINARY_DIR}/[^.]*.hh
	    ${CMAKE_CURRENT_BINARY_DIR}/[^.]*.H
	    ${CMAKE_CURRENT_BINARY_DIR}/[^.]*.hpp
	    ${CMAKE_CURRENT_BINARY_DIR}/[^.]*.icc
	    )
  if( build_directory_files )
    #message( STATUS "installing ${build_directory_files} in ${source_install_dir}")
    INSTALL( FILES ${build_directory_files}
             DESTINATION ${source_install_dir} )
  endif( build_directory_files )
  if( build_directory_headers )
    #message( STATUS "installing ${build_directory_headers} in ${source_install_dir}")
    INSTALL( FILES ${build_directory_headers}
             DESTINATION ${header_install_dir} )
  endif( build_directory_headers )
endmacro( _cet_check_build_directory )

macro( _cet_install_generated_dictionary_code )
  # check for dictionary code
  if( cet_generated_code )
     foreach( dict ${cet_generated_code} )
	STRING( REGEX REPLACE "^${CMAKE_CURRENT_BINARY_DIR}/(.*)$"  "\\1" dictname "${dict}")
	# OK, this is hokey, but it works
	set( dummy dummy_${dictname} )
	add_custom_command(
           OUTPUT ${dummy}
           COMMAND ${CMAKE_COMMAND} -E copy ${dict} ${dummy}
           DEPENDS ${dict}
        )
        INSTALL( FILES ${dict}
                 DESTINATION ${source_install_dir} )
     endforeach(dict)
  endif( cet_generated_code )
endmacro( _cet_install_generated_dictionary_code )

macro( _cet_install_without_list   )
  #message( STATUS "source code will be installed in ${source_install_dir}" )
  FILE(GLOB src_files
	    [^.]*.cc [^.]*.c [^.]*.cpp [^.]*.C [^.]*.cxx
	    [^.]*.h [^.]*.hh [^.]*.H [^.]*.hpp [^.]*.icc
	    [^.]*.xml [^.]*.sh [^.]*.py [^.]*.pl [^.]*.rb
	    )
  if( ISRC_EXCLUDES )
    LIST( REMOVE_ITEM src_files ${ISRC_EXCLUDES} )
  endif()
  if( src_files )
    INSTALL( FILES ${src_files}
             DESTINATION ${source_install_dir} )
  endif( src_files )
  # check for generated files
  _cet_check_build_directory()
  _cet_install_generated_dictionary_code()
  # now check subdirectories
  if( ISRC_SUBDIRS )
     foreach( sub ${ISRC_SUBDIRS} )
	FILE(GLOB subdir_src_files
        	 ${sub}/[^.]*.cc ${sub}/[^.]*.c ${sub}/[^.]*.cpp ${sub}/[^.]*.C ${sub}/[^.]*.cxx
        	 ${sub}/[^.]*.h ${sub}/[^.]*.hh ${sub}/[^.]*.H ${sub}/[^.]*.hpp ${sub}/[^.]*.icc
        	 ${sub}/[^.]*.xml ${sub}/[^.]*.sh ${sub}/[^.]*.py ${sub}/[^.]*.pl ${sub}/[^.]*.rb )
	if( ISRC_EXCLUDES )
          LIST( REMOVE_ITEM subdir_src_files ${ISRC_EXCLUDES} )
	endif()
	if( subdir_src_files )
          INSTALL( FILES ${subdir_src_files}
                   DESTINATION ${source_install_dir}/${sub} )
	endif( subdir_src_files )
     endforeach(sub)
     #message( STATUS "also installing in subdirectories: ${ISRC_SUBDIRS}")
  endif( ISRC_SUBDIRS )
endmacro( _cet_install_without_list )

macro( _cet_install_from_list  source_files  )
  #message( STATUS "_cet_install_from_list debug: source code list will be installed in ${source_install_dir}" )
  #message( STATUS "_cet_install_from_list debug: install list is ${source_files}")
  INSTALL( FILES ${source_files}
           DESTINATION ${source_install_dir} )
endmacro( _cet_install_from_list )

macro( _cet_install_header_without_list   )
  #message( STATUS "headers will be installed in ${header_install_dir}" )
  FILE(GLOB headers [^.]*.h [^.]*.hh [^.]*.H [^.]*.hpp [^.]*.icc )
  FILE(GLOB dict_headers classes.h )
  if( dict_headers )
    #message(STATUS "install_headers debug: removing ${dict_headers} from header list")
    LIST(REMOVE_ITEM headers ${dict_headers} )
  endif( dict_headers)
  if(IHDR_EXCLUDES)
    LIST( REMOVE_ITEM headers ${IHDR_EXCLUDES} )
  endif()
  if( headers )
    #message( STATUS "installing headers ${headers} in ${header_install_dir}")
    INSTALL( FILES ${headers}
             DESTINATION ${header_install_dir} )
  endif( headers )
  # now check subdirectories
  if( IHDR_SUBDIRS )
    foreach( sub ${IHDR_SUBDIRS} )
      FILE(GLOB subdir_headers
                ${sub}/[^.]*.h ${sub}/[^.]*.hh ${sub}/[^.]*.H ${sub}/[^.]*.hpp ${sub}/[^.]*.icc  )
      if(IHDR_EXCLUDES)
        LIST( REMOVE_ITEM subdir_headers ${IHDR_EXCLUDES} )
      endif()
      if( subdir_headers )
        INSTALL( FILES ${subdir_headers}
                 DESTINATION ${header_install_dir}/${sub} )
      endif( subdir_headers )
    endforeach(sub)
    #message( STATUS "also installing in subdirectories: ${IHDR_SUBDIRS}")
  endif( IHDR_SUBDIRS )
endmacro( _cet_install_header_without_list )

macro( _cet_install_header_from_list header_list  )
  ##message( STATUS "_cet_install_header_from_list debug: source code list will be installed in ${header_install_dir}" )
  ##message( STATUS "_cet_install_header_from_list debug: install list is ${header_list}")
  INSTALL( FILES ${header_list}
           DESTINATION ${header_install_dir} )
endmacro( _cet_install_header_from_list )

macro( _cet_install_script_without_list   )
  #message( STATUS "scripts will be installed in ${script_install_dir}" )
  FILE(GLOB scripts [^.]*.sh [^.]*.py [^.]*.pl [^.]*.rb )
  if( IS_EXCLUDES )
    LIST( REMOVE_ITEM scripts ${IS_EXCLUDES} )
  endif()
  if( scripts )
    #message( STATUS "installing scripts ${scripts} in ${script_install_dir}")
    INSTALL ( PROGRAMS ${scripts}
              DESTINATION ${script_install_dir} )
  endif( scripts )
  # now check subdirectories
  if( IS_SUBDIRS )
    foreach( sub ${IS_SUBDIRS} )
      FILE(GLOB subdir_scripts
                ${sub}/[^.]*.sh ${sub}/[^.]*.py ${sub}/[^.]*.pl ${sub}/[^.]*.rb )
      if( IS_EXCLUDES )
        LIST( REMOVE_ITEM subdir_scripts ${IS_EXCLUDES} )
      endif()
      if( subdir_scripts )
        INSTALL ( PROGRAMS ${subdir_scripts}
                  DESTINATION ${script_install_dir} )
      endif( subdir_scripts )
    endforeach(sub)
  endif( IS_SUBDIRS )
endmacro( _cet_install_script_without_list )

macro( _cet_copy_fcl )
  set( mrb_build_dir $ENV{MRB_BUILDDIR} )
  get_filename_component( fclpathname ${fhicl_install_dir} NAME )
  #message(STATUS "_cet_copy_fcl: copying to mrb ${mrb_build_dir}/${product}/${fclpathname} or cet ${CETPKG_BUILD}/${fclpathname}")
  if( mrb_build_dir )
    set( fclbuildpath ${mrb_build_dir}/${product}/${fclpathname} )
  else()
    set( fclbuildpath ${CETPKG_BUILD}/${fclpathname} )
  endif()
  #message(STATUS "_cet_copy_fcl: copying to ${fclbuildpath}")
  foreach( fclfile ${ARGN} )
    get_filename_component( fclname ${fclfile} NAME )
    configure_file( ${fclname} ${fclbuildpath}/${fclname} COPYONLY )
  endforeach(fclfile)
endmacro( _cet_copy_fcl )

macro( _cet_install_fhicl_without_list   )
  #message( STATUS "fhicl scripts will be installed in ${fhicl_install_dir}" )
  FILE(GLOB fcl_files [^.]*.fcl )
  if( IFCL_EXCLUDES )
    LIST( REMOVE_ITEM fcl_files ${IFCL_EXCLUDES} )
  endif()
  if( fcl_files )
    #message( STATUS "installing fhicl files ${fcl_files} in ${fhicl_install_dir}")
    _cet_copy_fcl( ${fcl_files} )
    INSTALL ( FILES ${fcl_files}
              DESTINATION ${fhicl_install_dir} )
  endif( fcl_files )
  # now check subdirectories
  if( IFCL_SUBDIRS )
    foreach( sub ${IFCL_SUBDIRS} )
      FILE(GLOB subdir_fcl_files
                ${sub}/[^.]*.fcl )
      if( IFCL_EXCLUDES )
        LIST( REMOVE_ITEM subdir_fcl_files ${IFCL_EXCLUDES} )
      endif()
      if( subdir_fcl_files )
        _cet_copy_fcl( ${subdir_fcl_files} )
        INSTALL ( FILES ${subdir_fcl_files}
                  DESTINATION ${fhicl_install_dir} )
      endif( subdir_fcl_files )
    endforeach(sub)
  endif( IFCL_SUBDIRS )
endmacro( _cet_install_fhicl_without_list )

macro( install_source   )
  cet_parse_args( ISRC "SUBDIRS;LIST;EXTRAS;EXCLUDES" "" ${ARGN})
  #message( STATUS "install_source: PACKAGE_TOP_DIRECTORY is ${PACKAGE_TOP_DIRECTORY}")
  if( PACKAGE_TOP_DIRECTORY )
     STRING( REGEX REPLACE "^${PACKAGE_TOP_DIRECTORY}(.*)" "\\1" CURRENT_SUBDIR "${CMAKE_CURRENT_SOURCE_DIR}" )
  else()
     STRING( REGEX REPLACE "^${CMAKE_SOURCE_DIR}(.*)" "\\1" CURRENT_SUBDIR "${CMAKE_CURRENT_SOURCE_DIR}" )
  endif()
  set(source_install_dir ${product}/${version}/source/${CURRENT_SUBDIR} )
  #message( STATUS "install_source: source code will be installed in ${source_install_dir}" )
  if( ISRC_LIST )
    if( ISRC_SUBDIRS )
      message( FATAL_ERROR
               "ERROR: call install_source with EITHER LIST or SUBDIRS but not both")
    endif( ISRC_SUBDIRS )
    _cet_install_from_list("${ISRC_LIST}")
  else()
    if( ISRC_EXTRAS )
      _cet_install_from_list("${ISRC_EXTRAS}")
    endif( ISRC_EXTRAS )
    _cet_install_without_list()
  endif()
endmacro( install_source )

macro( install_headers   )
  cet_parse_args( IHDR "SUBDIRS;LIST;EXTRAS;EXCLUDES" "" ${ARGN})
  if( PACKAGE_TOP_DIRECTORY )
    STRING( REGEX REPLACE "^${PACKAGE_TOP_DIRECTORY}(.*)" "\\1" CURRENT_SUBDIR "${CMAKE_CURRENT_SOURCE_DIR}" )
  else()
    STRING( REGEX REPLACE "^${CMAKE_SOURCE_DIR}(.*)" "\\1" CURRENT_SUBDIR "${CMAKE_CURRENT_SOURCE_DIR}" )
  endif()
  _cet_check_inc_directory()
  set(header_install_dir ${${product}_inc_dir}${CURRENT_SUBDIR} )
  #message( STATUS "install_headers: headers will be installed in ${header_install_dir}" )
  if( IHDR_LIST )
    if( IHDR_SUBDIRS )
      message( FATAL_ERROR
               "ERROR: call install_headers with EITHER LIST or SUBDIRS but not both")
    endif( IHDR_SUBDIRS )
    _cet_install_header_from_list("${IHDR_LIST}")
  else()
    if( IHDR_EXTRAS )
      _cet_install_header_from_list("${IHDR_EXTRAS}")
    endif( IHDR_EXTRAS )
    _cet_install_header_without_list()
  endif()
endmacro( install_headers )

macro( install_scripts   )
  cet_parse_args( IS "SUBDIRS;LIST;EXTRAS;EXCLUDES" "" ${ARGN})
  set(script_install_dir ${${product}_bin_dir} )
  #message( STATUS "install_scripts: scripts will be installed in ${script_install_dir}" )
  if( IS_LIST )
    if( IS_SUBDIRS )
      message( FATAL_ERROR
               "ERROR: call install_scripts with EITHER LIST or SUBDIRS but not both")
    endif( IS_SUBDIRS )
    INSTALL ( PROGRAMS  ${IS_LIST}
              DESTINATION ${script_install_dir} )
  else()
    if( IS_EXTRAS )
      INSTALL ( PROGRAMS  ${IS_EXTRAS}
                DESTINATION ${script_install_dir} )
    endif( IS_EXTRAS )
    _cet_install_script_without_list()
  endif()
endmacro( install_scripts )

macro( install_fhicl   )
  cet_parse_args( IFCL "SUBDIRS;LIST;EXTRAS;EXCLUDES" "" ${ARGN})
  set(fhicl_install_dir ${${product}_fcl_dir} )
  #message( STATUS "install_fhicl: fhicl scripts will be installed in ${fhicl_install_dir}" )
  if( IFCL_LIST )
    if( IFCL_SUBDIRS )
      message( FATAL_ERROR
               "ERROR: call install_fhicl with EITHER LIST or SUBDIRS but not both")
    endif( IFCL_SUBDIRS )
    _cet_copy_fcl( ${IFCL_LIST} )
    INSTALL ( FILES  ${IFCL_LIST}
              DESTINATION ${fhicl_install_dir} )
  else()
    if( IFCL_EXTRAS )
      _cet_copy_fcl( ${IFCL_EXTRAS} )
      INSTALL ( FILES  ${IFCL_EXTRAS}
                DESTINATION ${fhicl_install_dir} )
    endif( IFCL_EXTRAS )
    _cet_install_fhicl_without_list()
  endif()
endmacro( install_fhicl )
