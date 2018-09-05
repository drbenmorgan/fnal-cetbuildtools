########################################################################
# install_wp([SUBDIRNAME dir] LIST files...)
#   Install FW data in ${${CMAKE_PROJECT_NAME}_fw_dir}/${SUBDIRNAME}
#
####################################
# Recommended use:
#
# install_wp( LIST file_list 
#             [SUBDIRNAME subdirectory_under_fwdir] )
# THERE ARE NO DEFAULTS FOR install_wp
#
########################################################################

include(CMakeParseArguments)
include(CetCurrentSubdir)
include (CetCopy)
include (CetExclude)

macro( _cet_copy_wp )
  cmake_parse_arguments( CPWP "" "SUBDIRNAME;WORKING_DIRECTORY" "LIST" ${ARGN})
  set( mrb_build_dir $ENV{MRB_BUILDDIR} )
  get_filename_component( wirepathname ${wp_install_dir} NAME )
  #message(STATUS "_cet_copy_wp: copying to mrb ${mrb_build_dir}/${product}/${wirepathname} or cet ${CETPKG_BUILD}/${wirepathname}")
  if( mrb_build_dir )
    set( wpbuildpath ${mrb_build_dir}/${product}/${wirepathname} )
  else()
    set( wpbuildpath ${CETPKG_BUILD}/${wirepathname} )
  endif()
  if( CPWP_SUBDIRNAME )
    set( wpbuildpath ${wpbuildpath}/${CPWP_SUBDIRNAME} )
  endif( CPWP_SUBDIRNAME )
  if (CPWP_WORKING_DIRECTORY)
    cet_copy(${CPWP_LIST} DESTINATION "${wpbuildpath}" WORKING_DIRECTORY "${CPFW_WORKING_DIRECTORY}")
  else()
    cet_copy(${CPWP_LIST} DESTINATION "${wpbuildpath}")
  endif()
  #message(STATUS "_cet_copy_wp: copying to ${wpbuildpath}")
endmacro( _cet_copy_wp )

macro( install_wp   )
  cmake_parse_arguments( IFW "" "SUBDIRNAME" "LIST" ${ARGN})
  set( wp_install_dir ${${product}_fw_dir} )
  _cet_debug_message( "install_wp: fw scripts will be installed in ${wp_install_dir}" )

  if( IFW_LIST )
    _cet_copy_wp( ${ARGN} WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}" )
    if ( IFW_SUBDIRNAME )
      INSTALL ( FILES  ${IFW_LIST}
                DESTINATION ${wp_install_dir}/${IFW_SUBDIRNAME} )
    else()
      INSTALL ( FILES  ${IFW_LIST}
                DESTINATION ${wp_install_dir} )
    endif()
  else()
      message( FATAL_ERROR "ERROR: install_wp has no defaults, you must use LIST")
  endif()
endmacro( install_wp )
