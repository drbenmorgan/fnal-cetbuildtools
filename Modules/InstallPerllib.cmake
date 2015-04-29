########################################################################
# install_perllib()
#   Install perl libs for inclusion by other packages.
#   Default extensions: .pm
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
# The AS_TEST option for install_scripts will install scripts in a test subdirectory.
#
####################################
# Recommended use:
#
# install_perllib( [SUBDIRS subdirectory_list]
#                  [EXTRAS extra_files]
#                  [EXCLUDES exclusions] )
# install_perllib( LIST file_list )
#
#

macro( _cet_perl_plugin_version )

configure_file($ENV{CETLIB_DIR}/perllib/PluginVersionInfo.pm.in
  ${CMAKE_CURRENT_BINARY_DIR}/CetSkel/${product}/PluginVersionInfo.pm
  @ONLY)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/CetSkel/${product}/PluginVersionInfo.pm
  DESTINATION ${product}/${version}/perllib/CetSkel/${product}/)

endmacro( _cet_perl_plugin_version )

macro( _cet_copy_perllib )
  cmake_parse_arguments( CPPRL "" "SUBDIR;WORKING_DIRECTORY" "LIST" ${ARGN})
  set( mrb_build_dir $ENV{MRB_BUILDDIR} )
  get_filename_component( prlpathname ${perllib_install_dir} NAME )
  #message(STATUS "_cet_copy_perllib: copying to mrb ${mrb_build_dir}/${product}/${prlpathname} or cet ${CETPKG_BUILD}/${prlpathname}")
  if( mrb_build_dir )
    set( perllibbuiildpath ${mrb_build_dir}/${product}/${prlpathname} )
  else()
    set( perllibbuiildpath ${CETPKG_BUILD}/${prlpathname} )
  endif()
  if( CPPRL_SUBDIR )
    set( perllibbuiildpath "${perllibbuiildpath}/${CPPRL_SUBDIR}" )
  endif( CPPRL_SUBDIR )
  if (CPPRL_WORKING_DIRECTORY)
    cet_copy(${CPPRL_LIST} DESTINATION "${perllibbuiildpath}" WORKING_DIRECTORY "${CPPRL_WORKING_DIRECTORY}")
  else()
    cet_copy(${CPPRL_LIST} DESTINATION "${perllibbuiildpath}")
  endif()
  #message(STATUS "_cet_copy_perllib: copying to ${perllibbuiildpath}")
endmacro( _cet_copy_perllib )

macro( _cet_install_perllib_without_list   )
  #message( STATUS "_cet_install_perllib_without_list: perl lib scripts will be installed in ${perllib_install_dir}" )
  FILE(GLOB prl_files [^.]*.pm README )
  if( IPRL_EXCLUDES )
    LIST( REMOVE_ITEM prl_files ${IPRL_EXCLUDES} )
  endif()
  if( prl_files )
    #message( STATUS "_cet_install_perllib_without_list: installing perl lib files ${prl_files} in ${perllib_install_dir}")
    _cet_copy_perllib( LIST ${prl_files} )
    INSTALL ( FILES ${prl_files}
              DESTINATION ${perllib_install_dir} )
  endif( prl_files )
  # now check subdirectories
  if( IPRL_SUBDIRS )
    foreach( sub ${IPRL_SUBDIRS} )
      FILE(GLOB subdir_prl_files
                ${sub}/[^.]*.pm  
		${sub}/README
		)
      #message( STATUS "found ${sub} files ${subdir_prl_files}")
      if( IPRL_EXCLUDES )
        LIST( REMOVE_ITEM subdir_prl_files ${IPRL_EXCLUDES} )
      endif()
      if( subdir_prl_files )
        _cet_copy_perllib( LIST ${subdir_prl_files} SUBDIR ${sub} )
        INSTALL ( FILES ${subdir_prl_files}
                  DESTINATION ${perllib_install_dir}/${sub} )
      endif( subdir_prl_files )
    endforeach(sub)
  endif( IPRL_SUBDIRS )
endmacro( _cet_install_perllib_without_list )

macro( install_perllib   )
  cmake_parse_arguments( IPRL "" "" "SUBDIRS;LIST;EXTRAS;EXCLUDES" ${ARGN})
  if( PACKAGE_TOP_DIRECTORY )
     STRING( REGEX REPLACE "^${PACKAGE_TOP_DIRECTORY}(.*)" "\\1" TEST_SUBDIR "${CMAKE_CURRENT_SOURCE_DIR}" )
  else()
     STRING( REGEX REPLACE "^${CMAKE_SOURCE_DIR}(.*)" "\\1" TEST_SUBDIR "${CMAKE_CURRENT_SOURCE_DIR}" )
  endif()
  STRING( REGEX REPLACE "^/${${product}_perllib_subdir}(.*)" "\\1" CURRENT_SUBDIR "${TEST_SUBDIR}" )
  set(perllib_install_dir ${${product}_perllib}${CURRENT_SUBDIR})
  message( STATUS "install_perllib: perllib scripts will be installed in ${perllib_install_dir}" )
  #message( STATUS "install_perllib: IPRL_SUBDIRS is ${IPRL_SUBDIRS}")
  _cet_perl_plugin_version()

  if( IPRL_LIST )
    if( IPRL_SUBDIRS )
      message( FATAL_ERROR
               "ERROR: call install_perllib with EITHER LIST or SUBDIRS but not both")
    endif( IPRL_SUBDIRS )
    _cet_copy_perllib( LIST ${IPRL_LIST} WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}")
    INSTALL ( FILES  ${IPRL_LIST}
              DESTINATION ${perllib_install_dir} )
  else()
    if( IPRL_EXTRAS )
      _cet_copy_perllib( LIST ${IPRL_EXTRAS} )
      INSTALL ( FILES  ${IPRL_EXTRAS}
                DESTINATION ${perllib_install_dir} )
    endif( IPRL_EXTRAS )
    _cet_install_perllib_without_list()
  endif()
endmacro( install_perllib )
