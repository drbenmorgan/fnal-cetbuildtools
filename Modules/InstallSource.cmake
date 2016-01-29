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
#     .sh .py .pl .rb [.cfg when AS_TEST is specified]
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
# The AS_TEST option for install_scripts will install scripts in a test subdirectory.
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
#                  [EXCLUDES exclusions]
#                  [USE_PRODUCT_NAME] )
# install_headers( LIST file_list
#                  [USE_PRODUCT_NAME] )
#   If USE_PRODUCT_NAME is specified, the product name will be prepended
#   to the install path
#
# install_fhicl( [SUBDIRS subdirectory_list]
#                [EXTRAS extra_files]
#                [EXCLUDES exclusions] )
# install_fhicl( LIST file_list )
#
# install_fw( LIST file_list
#             [SUBDIRNAME subdirectory_under_fwdir] )
# THERE ARE NO DEFAULTS FOR install_fw
#
# install_gdml( [SUBDIRS subdirectory_list]
#                [EXTRAS extra_files]
#                [EXCLUDES exclusions] )
# install_gdml( LIST file_list )
#
# install_scripts( [SUBDIRS subdirectory_list]
#                  [EXTRAS extra_files]
#                  [EXCLUDES exclusions]
#                  [AS_TEST] )
# install_scripts( LIST file_list [AS_TEST] )
#
# set_install_root() defines PACKAGE_TOP_DIR
#
########################################################################

include(CMakeParseArguments)
include(CetCurrentSubdir)
include (CetCopy)

# - ??
macro(_cet_check_inc_directory)
  if(${${product}_inc_dir} MATCHES "NONE")
    message(FATAL_ERROR "Please specify an include directory in product_deps")
  elseif(${${product}_inc_dir} MATCHES "ERROR")
    message(FATAL_ERROR "Invalid include directory in product_deps")
  endif()
endmacro()

# - Find generated sources
macro(_cet_check_build_directory)
  file(GLOB build_directory_files
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
  file(GLOB build_directory_headers
	  ${CMAKE_CURRENT_BINARY_DIR}/[^.]*.h
    ${CMAKE_CURRENT_BINARY_DIR}/[^.]*.hh
    ${CMAKE_CURRENT_BINARY_DIR}/[^.]*.H
    ${CMAKE_CURRENT_BINARY_DIR}/[^.]*.hpp
    ${CMAKE_CURRENT_BINARY_DIR}/[^.]*.icc
    )

  if(build_directory_files)
    install(FILES ${build_directory_files} DESTINATION ${source_install_dir})
  endif()

  if(build_directory_headers)
    install(FILES ${build_directory_headers} DESTINATION ${header_install_dir})
  endif()
endmacro()

# - Find dictionary sources
macro(_cet_install_generated_dictionary_code)
  if(cet_generated_code)
    foreach(dict ${cet_generated_code})
      install(FILES ${dict} DESTINATION ${source_install_dir})
    endforeach()
  endif()
  set(cet_generated_code) # Clear to avoid causing problems in subdirectories.
endmacro()

# - ??
macro(_cet_install_without_list)
  file(GLOB src_files
    [^.]*.cc
    [^.]*.c
    [^.]*.cpp
    [^.]*.C
    [^.]*.cxx
	  [^.]*.h
    [^.]*.hh
    [^.]*.H
    [^.]*.hpp
    [^.]*.icc
	  [^.]*.xml
    [^.]*.sh
    [^.]*.py
    [^.]*.pl
    [^.]*.rb
	  )

  if(ISRC_EXCLUDES)
    list(REMOVE_ITEM src_files ${ISRC_EXCLUDES})
  endif()

  if(src_files)
    install(FILES ${src_files} DESTINATION ${source_install_dir})
  endif()

  # check for generated files
  _cet_check_build_directory()
  _cet_install_generated_dictionary_code()

  # now check subdirectories
  if(ISRC_SUBDIRS)
     foreach(sub ${ISRC_SUBDIRS})
       file(GLOB subdir_src_files
         ${sub}/[^.]*.cc
         ${sub}/[^.]*.c
         ${sub}/[^.]*.cpp
         ${sub}/[^.]*.C
         ${sub}/[^.]*.cxx
         ${sub}/[^.]*.h
         ${sub}/[^.]*.hh
         ${sub}/[^.]*.H
         ${sub}/[^.]*.hpp
         ${sub}/[^.]*.icc
         ${sub}/[^.]*.xml
         ${sub}/[^.]*.sh
         ${sub}/[^.]*.py
         ${sub}/[^.]*.pl
         ${sub}/[^.]*.rb
         )

       if(ISRC_EXCLUDES)
         list(REMOVE_ITEM subdir_src_files ${ISRC_EXCLUDES})
	     endif()

       if(subdir_src_files)
         install(FILES ${subdir_src_files} DESTINATION ${source_install_dir}/${sub})
	     endif()
     endforeach()
     #message( STATUS "also installing in subdirectories: ${ISRC_SUBDIRS}")
  endif()
endmacro()

# - ??
macro(_cet_install_from_list source_files)
  install(FILES ${source_files} DESTINATION ${source_install_dir})
endmacro()

# - ??
macro(_cet_install_header_without_list)
  file(GLOB headers [^.]*.h [^.]*.hh [^.]*.H [^.]*.hpp [^.]*.icc)
  file(GLOB dict_headers classes.h)

  if(dict_headers)
    list(REMOVE_ITEM headers ${dict_headers})
  endif()

  if(IHDR_EXCLUDES)
    list(REMOVE_ITEM headers ${IHDR_EXCLUDES})
  endif()

  if(headers)
    install(FILES ${headers} DESTINATION ${header_install_dir})
  endif()

  # now check subdirectories
  if(IHDR_SUBDIRS)
    foreach(sub ${IHDR_SUBDIRS})
      file(GLOB subdir_headers
        ${sub}/[^.]*.h
        ${sub}/[^.]*.hh
        ${sub}/[^.]*.H
        ${sub}/[^.]*.hpp
        ${sub}/[^.]*.icc
        )

      if(IHDR_EXCLUDES)
        list(REMOVE_ITEM subdir_headers ${IHDR_EXCLUDES})
      endif()

      if(subdir_headers)
        install(FILES ${subdir_headers} DESTINATION ${header_install_dir}/${sub})
      endif()
    endforeach()
  endif()
endmacro()

# - ??
macro(_cet_install_header_from_list header_list)
  install(FILES ${header_list} DESTINATION ${header_install_dir})
endmacro()

macro(_cet_install_script_without_list)
  message(STATUS "_cet_install_script_without_list: scripts will be installed in ${script_install_dir}")

  if(IS_AS_TEST)
    file(GLOB scripts [^.]*.sh [^.]*.py [^.]*.pl [^.]*.rb [^.]*.cfg)
  else()
    file(GLOB scripts [^.]*.sh [^.]*.py [^.]*.pl [^.]*.rb)
  endif()

  if(IS_EXCLUDES)
    list(REMOVE_ITEM scripts ${IS_EXCLUDES})
  endif()

  if(scripts)
    install(PROGRAMS ${scripts} DESTINATION ${script_install_dir})
  endif()

  # now check subdirectories
  if(IS_SUBDIRS)
    foreach(sub ${IS_SUBDIRS})
      if(IS_AS_TEST)
        file(GLOB subdir_scripts
          ${sub}/[^.]*.sh
          ${sub}/[^.]*.py
          ${sub}/[^.]*.pl
          ${sub}/[^.]*.rb
          ${sub}/[^.]*.cfg
          )
      else()
        file(GLOB subdir_scripts
          ${sub}/[^.]*.sh
          ${sub}/[^.]*.py
          ${sub}/[^.]*.pl
          ${sub}/[^.]*.rb
          )
      endif()

      if(IS_EXCLUDES)
        list(REMOVE_ITEM subdir_scripts ${IS_EXCLUDES})
      endif()

      if(subdir_scripts)
        install(PROGRAMS ${subdir_scripts} DESTINATION ${script_install_dir})
      endif()
    endforeach()
  endif(IS_SUBDIRS)
endmacro()

# - Copy fcl files (but don't install?)
macro(_cet_copy_fcl)
  set(mrb_build_dir $ENV{MRB_BUILDDIR})
  get_filename_component(fclpathname ${fhicl_install_dir} NAME)

  if(mrb_build_dir)
    set(fclbuildpath ${mrb_build_dir}/${product}/${fclpathname})
  else()
    set(fclbuildpath ${CETPKG_BUILD}/${fclpathname})
  endif()
  cet_copy(${ARGN} DESTINATION "${fclbuildpath}")
endmacro()

# - ??
macro(_cet_install_fhicl_without_list)
  file(GLOB fcl_files [^.]*.fcl)

  if(IFCL_EXCLUDES)
    list(REMOVE_ITEM fcl_files ${IFCL_EXCLUDES})
  endif()

  if(fcl_files)
    _cet_copy_fcl(${fcl_files})
    install(FILES ${fcl_files} DESTINATION ${fhicl_install_dir})
  endif()

  # now check subdirectories
  if(IFCL_SUBDIRS)
    foreach(sub ${IFCL_SUBDIRS})
      file(GLOB subdir_fcl_files ${sub}/[^.]*.fcl)
      if(IFCL_EXCLUDES)
        list(REMOVE_ITEM subdir_fcl_files ${IFCL_EXCLUDES})
      endif()
      if(subdir_fcl_files)
        _cet_copy_fcl(${subdir_fcl_files})
        install(FILES ${subdir_fcl_files} DESTINATION ${fhicl_install_dir})
      endif()
    endforeach()
  endif()
endmacro()

# - ?? The actual front end for source files ??
macro(install_source)
  cmake_parse_arguments(ISRC "" "" "SUBDIRS;LIST;EXTRAS;EXCLUDES" ${ARGN})
  _cet_current_subdir(CURRENT_SUBDIR)

  set(source_install_dir ${product}/${version}/source${CURRENT_SUBDIR})

  if(ISRC_LIST)
    if(ISRC_SUBDIRS)
      message(FATAL_ERROR "ERROR: call install_source with EITHER LIST or SUBDIRS but not both")
    endif()
    _cet_install_from_list("${ISRC_LIST}")
  else()
    if(ISRC_EXTRAS)
      _cet_install_from_list("${ISRC_EXTRAS}")
    endif()
    _cet_install_without_list()
  endif()
endmacro()

# - ?? The actual front end for header files ??
macro(install_headers)
  cmake_parse_arguments(IHDR "USE_PRODUCT_NAME" "" "SUBDIRS;LIST;EXTRAS;EXCLUDES" ${ARGN})
  _cet_current_subdir(CURRENT_SUBDIR)
  _cet_check_inc_directory()
  # Coupling to ART?
  if(IHDR_USE_PRODUCT_NAME OR ART_MAKE_PREPEND_PRODUCT_NAME)
    set(header_install_dir ${${product}_inc_dir}/${product}${CURRENT_SUBDIR})
  else()
    set(header_install_dir ${${product}_inc_dir}${CURRENT_SUBDIR})
  endif()

  if(IHDR_LIST)
    if(IHDR_SUBDIRS)
      message(FATAL_ERROR "ERROR: call install_headers with EITHER LIST or SUBDIRS but not both")
    endif()
    _cet_install_header_from_list("${IHDR_LIST}")
  else()
    if(IHDR_EXTRAS)
      _cet_install_header_from_list("${IHDR_EXTRAS}")
    endif()
    _cet_install_header_without_list()
  endif()
endmacro()

# - ?? Actual front end for scripts ??
macro(install_scripts)
  cmake_parse_arguments(IS "AS_TEST" "" "SUBDIRS;LIST;EXTRAS;EXCLUDES" ${ARGN})
  if(IS_AS_TEST)
    set(script_install_dir ${${product}_test_dir})
  else()
    set(script_install_dir ${${product}_bin_dir})
  endif()

  message( STATUS "install_scripts: scripts will be installed in ${script_install_dir}")

  if(IS_LIST)
    if(IS_SUBDIRS)
      message(FATAL_ERROR "ERROR: call install_scripts with EITHER LIST or SUBDIRS but not both")
    endif()

    install(PROGRAMS ${IS_LIST} DESTINATION ${script_install_dir})
  else()
    if(IS_EXTRAS)
      install(PROGRAMS ${IS_EXTRAS} DESTINATION ${script_install_dir})
    endif()
    _cet_install_script_without_list()
  endif()
endmacro()

# - ?? Actual frontend for fhicl files
macro(install_fhicl)
  cmake_parse_arguments(IFCL "" "" "SUBDIRS;LIST;EXTRAS;EXCLUDES" ${ARGN})
  set(fhicl_install_dir ${${product}_fcl_dir})

  if(IFCL_LIST)
    if(IFCL_SUBDIRS)
      message(FATAL_ERROR "ERROR: call install_fhicl with EITHER LIST or SUBDIRS but not both")
    endif()

    _cet_copy_fcl(${IFCL_LIST} WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}")
    install(FILES ${IFCL_LIST} DESTINATION ${fhicl_install_dir})
  else()
    if(IFCL_EXTRAS)
      _cet_copy_fcl(${IFCL_EXTRAS})
      install(FILES ${IFCL_EXTRAS} DESTINATION ${fhicl_install_dir})
    endif()
    _cet_install_fhicl_without_list()
  endif()
endmacro()

# - ?? Actual frontend for gdml ??
macro(_cet_copy_gdml)
  cmake_parse_arguments(CPGDML "" "SUBDIR;WORKING_DIRECTORY" "LIST" ${ARGN})
  set(mrb_build_dir $ENV{MRB_BUILDDIR})
  get_filename_component( gdmlpathname ${gdml_install_dir} NAME)

  if(mrb_build_dir)
    set(gdmlbuildpath ${mrb_build_dir}/${product}/${gdmlpathname})
  else()
    set(gdmlbuildpath ${CETPKG_BUILD}/${gdmlpathname})
  endif()

  if(CPGDML_SUBDIR)
    set(gdmlbuildpath "${gdmlbuildpath}/${CPGDML_SUBDIR}")
  endif(CPGDML_SUBDIR)

  if(CPGDML_WORKING_DIRECTORY)
    cet_copy(${CPGDML_LIST} DESTINATION "${gdmlbuildpath}" WORKING_DIRECTORY "${CPGDML_WORKING_DIRECTORY}")
  else()
    cet_copy(${CPGDML_LIST} DESTINATION "${gdmlbuildpath}")
  endif()
endmacro()

# - ??
macro(_cet_install_gdml_without_list)
  file(GLOB gdml_files [^.]*.gdml [^.]*.C [^.]*.xml [^.]*.xsd README)
  if(IGDML_EXCLUDES)
    list(REMOVE_ITEM gdml_files ${IGDML_EXCLUDES})
  endif()
  if(gdml_files)
    _cet_copy_gdml(LIST ${gdml_files})
    install(FILES ${gdml_files} DESTINATION ${gdml_install_dir})
  endif()

  # now check subdirectories
  if(IGDML_SUBDIRS)
    foreach(sub ${IGDML_SUBDIRS})
      file(GLOB subdir_gdml_files
        ${sub}/[^.]*.gdml
        ${sub}/[^.]*.C
        ${sub}/[^.]*.xml
        ${sub}/[^.]*.xsd
        ${sub}/README
        )

      if(IGDML_EXCLUDES)
        list(REMOVE_ITEM subdir_gdml_files ${IGDML_EXCLUDES})
      endif()
      if(subdir_gdml_files)
        _cet_copy_gdml( LIST ${subdir_gdml_files} SUBDIR ${sub} )
        install(FILES ${subdir_gdml_files} DESTINATION ${gdml_install_dir}/${sub})
      endif()
    endforeach()
  endif()
endmacro()

# - ?? Now the frontend for gdml files ?
macro(install_gdml)
  cmake_parse_arguments(IGDML "" "" "SUBDIRS;LIST;EXTRAS;EXCLUDES" ${ARGN})
  set(gdml_install_dir ${${product}_gdml_dir})
  message(STATUS "install_gdml: gdml scripts will be installed in ${gdml_install_dir}")

  if(IGDML_LIST)
    if(IGDML_SUBDIRS)
      message(FATAL_ERROR "ERROR: call install_gdml with EITHER LIST or SUBDIRS but not both")
    endif()

    _cet_copy_gdml(LIST ${IGDML_LIST} WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}")
    install(FILES ${IGDML_LIST} DESTINATION ${gdml_install_dir})
  else()
    if(IGDML_EXTRAS)
      _cet_copy_gdml(LIST ${IGDML_EXTRAS})
      install(FILES ${IGDML_EXTRAS} DESTINATION ${gdml_install_dir})
    endif()
    _cet_install_gdml_without_list()
  endif()
endmacro()

# - ??
macro( _cet_copy_fw )
  cmake_parse_arguments(CPFW "" "SUBDIRNAME;WORKING_DIRECTORY" "LIST" ${ARGN})
  set(mrb_build_dir $ENV{MRB_BUILDDIR})
  get_filename_component(fwpathname ${fw_install_dir} NAME)

  if(mrb_build_dir)
    set(fwbuildpath ${mrb_build_dir}/${product}/${fwpathname})
  else()
    set(fwbuildpath ${CETPKG_BUILD}/${fwpathname})
  endif()

  if(CPFW_SUBDIRNAME)
    set(fwbuildpath ${fwbuildpath}/${CPFW_SUBDIRNAME})
  endif()

  if(CPFW_WORKING_DIRECTORY)
    cet_copy(${CPFW_LIST} DESTINATION "${fwbuildpath}" WORKING_DIRECTORY "${CPFW_WORKING_DIRECTORY}")
  else()
    cet_copy(${CPFW_LIST} DESTINATION "${fwbuildpath}")
  endif()
endmacro()

# - >>
macro(install_fw)
  cmake_parse_arguments(IFW "" "SUBDIRNAME" "LIST" ${ARGN})
  set(fw_install_dir ${${product}_fw_dir})
  message(STATUS "install_fw: fw scripts will be installed in ${fw_install_dir}")

  if(IFW_LIST)
    _cet_copy_fw(${ARGN} WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}")
    if(IFW_SUBDIRNAME)
      install(FILES ${IFW_LIST} DESTINATION ${fw_install_dir}/${IFW_SUBDIRNAME})
    else()
     install(FILES ${IFW_LIST} DESTINATION ${fw_install_dir})
    endif()
  else()
    message(FATAL_ERROR "ERROR: install_fw has no defaults, you must use LIST")
  endif()
endmacro()

