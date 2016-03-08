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

include(CetCurrentSubdir)
include (CetExclude)

# - ??
macro(_cet_perl_plugin_version)
  configure_file($ENV{CETLIB_DIR}/perllib/PluginVersionInfo.pm.in
    ${CMAKE_CURRENT_BINARY_DIR}/${product}/PluginVersionInfo.pm
    @ONLY
    )

  set(CONFIG_PM_VERSION "PluginVersionInfo.pm" CACHE INTERNAL "just for PluginVersionInfo.pm")
  install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${product}/PluginVersionInfo.pm
    DESTINATION ${perllib_install_dir}/${product}/
    )
endmacro()

# - ??
macro(_cet_copy_perllib)
  cmake_parse_arguments( CPPRL "" "SUBDIR;WORKING_DIRECTORY" "LIST" ${ARGN})

  set(mrb_build_dir $ENV{MRB_BUILDDIR})
  if(mrb_build_dir)
    set(perllibbuiildpath ${mrb_build_dir}/${product}/${prlpathname})
  else()
    set(perllibbuiildpath ${CETPKG_BUILD}/${prlpathname})
  endif()

  if(CPPRL_SUBDIR)
    set(perllibbuiildpath "${perllibbuiildpath}/${CPPRL_SUBDIR}")
  endif()

  if(CPPRL_WORKING_DIRECTORY)
    cet_copy(${CPPRL_LIST} DESTINATION "${perllibbuiildpath}" WORKING_DIRECTORY "${CPPRL_WORKING_DIRECTORY}")
  else()
    cet_copy(${CPPRL_LIST} DESTINATION "${perllibbuiildpath}")
  endif()
endmacro()

# - ??
macro(_cet_add_to_pm_list libname)
  # add to perl library list for package configure file
  set(CONFIG_PM_LIST ${CONFIG_PM_LIST} ${libname} CACHE INTERNAL "perl libraries installed by this package")
endmacro()

# - ??
macro(_cet_add_to_perl_plugin_list libname)
  # add to perl library list for package configure file
  set(CONFIG_PERL_PLUGIN_LIST ${CONFIG_PERL_PLUGIN_LIST} ${libname} CACHE INTERNAL "perl plugin libraries installed by this package")
endmacro()

# - ??
macro(_cet_perllib_config_setup)
  if(${CURRENT_SUBDIR_NAME} MATCHES "CetSkelPlugins")
    foreach(pmfile ${ARGN})
      get_filename_component(pmfilename "${pmfile}" NAME)
      _cet_add_to_perl_plugin_list(${CURRENT_SUBDIR}/${pmfilename})
    endforeach()
  else()
    foreach(pmfile ${ARGN})
      get_filename_component(pmfilename "${pmfile}" NAME)
      _cet_add_to_pm_list(${CURRENT_SUBDIR}/${pmfilename})
    endforeach()
  endif()
endmacro()

# - ??
macro(_cet_install_perllib_without_list)
  file(GLOB prl_files [^.]*.pm)
  file(GLOB prl_files2 [^.]*.pm README)
  if(IPRL_EXCLUDES)
    list(REMOVE_ITEM prl_files ${IPRL_EXCLUDES})
  endif()
endmacro( _cet_perllib_config_setup )

macro( _cet_install_perllib_without_list   )
  #message( STATUS "_cet_install_perllib_without_list: perl lib scripts will be installed in ${perllib_install_dir}" )
  FILE(GLOB prl_files [^.]*.pm )
  FILE(GLOB prl_files2 [^.]*.pm README )
  if( IPRL_EXCLUDES )
    _cet_exclude_from_list( prl_files EXCLUDES ${IPRL_EXCLUDES} LIST ${prl_files} )

  endif()

  # now check subdirectories
  if( IPRL_SUBDIRS )
    foreach( sub ${IPRL_SUBDIRS} )
      FILE(GLOB subdir_prl_files2
                ${sub}/[^.]*.pm
		${sub}/README
		)
      FILE(GLOB subdir_prl_files ${sub}/[^.]*.pm )
      #message( STATUS "found ${sub} files ${subdir_prl_files}")
      if( IPRL_EXCLUDES )
        _cet_exclude_from_list( subdir_prl_files EXCLUDES ${IPRL_EXCLUDES} LIST ${subdir_prl_files} )
        _cet_exclude_from_list( subdir_prl_files2 EXCLUDES ${IPRL_EXCLUDES} LIST ${subdir_prl_files2} )

      endif()
    endforeach()
  endif()
endmacro()

# - ??
macro(install_perllib)
  cmake_parse_arguments(IPRL "" "" "SUBDIRS;LIST;EXTRAS;EXCLUDES" ${ARGN})
  _cet_current_subdir(TEST_SUBDIR)
  string(REGEX REPLACE "^/${${product}_perllib_subdir}(.*)" "\\1" CURRENT_SUBDIR "${TEST_SUBDIR}")
  set(perllib_install_dir "${${product}_perllib}${CURRENT_SUBDIR}")
  set(prlpathname "${${product}_perllib_subdir}${CURRENT_SUBDIR}")

  get_filename_component(CURRENT_SUBDIR_NAME "${CMAKE_CURRENT_SOURCE_DIR}" NAME)

  if(${CURRENT_SUBDIR_NAME} MATCHES "CetSkelPlugins")
    _cet_perl_plugin_version()
  endif()

  if(IPRL_LIST)
    if(IPRL_SUBDIRS)
      message(FATAL_ERROR "ERROR: call install_perllib with EITHER LIST or SUBDIRS but not both")
    endif()
    _cet_copy_perllib(LIST ${IPRL_LIST} WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}")
    _cet_perllib_config_setup(${IPRL_LIST})
    install(FILES ${IPRL_LIST} DESTINATION ${perllib_install_dir})
  else()
    if(IPRL_EXTRAS)
      _cet_copy_perllib(LIST ${IPRL_EXTRAS})
      _cet_perllib_config_setup(${IPRL_EXTRAS})
      install(FILES ${IPRL_EXTRAS} DESTINATION ${perllib_install_dir})
    endif()

    _cet_install_perllib_without_list()
  endif()
endmacro()

