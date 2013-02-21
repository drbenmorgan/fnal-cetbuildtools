# define the environment for a ups product
#
# find_ups_product( PRODUCTNAME version )
#  PRODUCTNAME - product name
#  version - minimum version required
#
# cet_cmake_config() will put ${PRODUCTNAME}-config.cmake in 
#  $ENV{${PRODUCTNAME_UC}_FQ_DIR}/lib/${PRODUCTNAME}/cmake or $ENV{${PRODUCTNAME_UC}_DIR}/cmake
# check these directories for ${PRODUCTNAME}-config.cmake 
# call find_package() if we find the config file
# if the config file is not found, call _check_version()


include(CheckUpsVersion)

macro( _use_find_package PNAME PNAME_UC PVER )

# we use find package to check the version

_get_dotver( ${PVER} )
#message(STATUS "_use_find_package: dotver is ${dotver}")

# define the cmake search path
set( ${PNAME_UC}_SEARCH_PATH $ENV{${PNAME_UC}_FQ_DIR} )
if( NOT ${PNAME_UC}_SEARCH_PATH )
  find_package( ${PNAME} ${dotver} PATHS $ENV{${PNAME_UC}_DIR} )
else()
  find_package( ${PNAME} ${dotver} PATHS $ENV{${PNAME_UC}_FQ_DIR} )
endif()
# make sure we found the product
if( NOT ${${PNAME}_FOUND} )
  message(FATAL_ERROR "ERROR: ${PNAME} was NOT found ")
endif()
# make sure the version numbers match
if(  ${${PNAME_UC}_VERSION} MATCHES ${${PNAME}_UPS_VERSION})
  #message(STATUS "${PNAME} versions match: ${${PNAME_UC}_VERSION} ${${PNAME}_UPS_VERSION} ")
else()
  message(STATUS "ERROR: There is an inconsistency between the ${PNAME} table and config files ")
  message(FATAL_ERROR "${PNAME} versions DO NOT match: ${${PNAME_UC}_VERSION} ${${PNAME}_UPS_VERSION} ")
endif()

endmacro( _use_find_package )

# since variables are passed, this is implemented as a macro
macro( find_ups_product PRODUCTNAME version )

# get upper and lower case versions of the name
string(TOUPPER  ${PRODUCTNAME} ${PRODUCTNAME}_UC )

# require ${${PRODUCTNAME}_UC}_VERSION or ${${PRODUCTNAME}_UC}_UPS_VERSION
set( ${${PRODUCTNAME}_UC}_VERSION $ENV{${${PRODUCTNAME}_UC}_VERSION} )
if ( NOT ${${PRODUCTNAME}_UC}_VERSION )
  set( ${${PRODUCTNAME}_UC}_VERSION $ENV{${${PRODUCTNAME}_UC}_UPS_VERSION} )
  if ( NOT ${${PRODUCTNAME}_UC}_VERSION )
     message(FATAL_ERROR "${${PRODUCTNAME}_UC} has not been setup")
  endif ()
endif ()

# compare for recursion
#message(STATUS "find_ups_product debug: ${PRODUCTNAME} ${product_list}")
list(FIND product_list ${PRODUCTNAME} found_product_match)
if( ${PRODUCTNAME} MATCHES "cetbuildtools" )
elseif( ${found_product_match} LESS 0 )
  #message(STATUS "find_ups_product debug: ${found_product_match} for ${PRODUCTNAME} ")
  # add to product list
  set(CONFIG_FIND_UPS_COMMANDS "${CONFIG_FIND_UPS_COMMANDS}
  find_ups_product( ${PRODUCTNAME} ${version} )")
  set(product_list ${PRODUCTNAME} ${product_list} )
  #message(STATUS "adding find_ups_product( ${PRODUCTNAME} ${version} )")
  _cet_debug_message("find_ups_product: ${PRODUCTNAME} version is ${${${PRODUCTNAME}_UC}_VERSION} ")
endif()

# MUST use a unique variable name for the config path
find_file( ${${PRODUCTNAME}_UC}_CONFIG_PATH ${PRODUCTNAME}-config.cmake $ENV{${${PRODUCTNAME}_UC}_FQ_DIR}/lib/${PRODUCTNAME}/cmake $ENV{${${PRODUCTNAME}_UC}_DIR}/cmake )
if(${${PRODUCTNAME}_UC}_CONFIG_PATH)
  #message(STATUS "find_ups_product: found ${PRODUCTNAME}-config.cmake in ${${${PRODUCTNAME}_UC}_CONFIG_PATH}")
  _use_find_package( ${PRODUCTNAME} ${${PRODUCTNAME}_UC} ${version} )
else()
  #message(STATUS "find_ups_product: ${PRODUCTNAME}-config.cmake NOT FOUND")
  _check_version( ${PRODUCTNAME} ${${${PRODUCTNAME}_UC}_VERSION} ${version} )
endif()

SET ( ${${PRODUCTNAME}_UC}_STRING $ENV{SETUP_${${PRODUCTNAME}_UC}} )
STRING( REGEX MATCH "[-][q]" has_qual  "${${${PRODUCTNAME}_UC}_STRING}" )
STRING( REGEX MATCH "[-][j]" has_j  "${${${PRODUCTNAME}_UC}_STRING}" )
if( has_qual )
  if( has_j )
     STRING( REGEX REPLACE ".*([-][q]+ )(.*)[ *]([-][-j])" "\\2" ${${PRODUCTNAME}_UC}_QUAL "${${${PRODUCTNAME}_UC}_STRING}" )
  else( )
     STRING( REGEX REPLACE ".*([-][q]+ )(.*)" "\\2" ${${PRODUCTNAME}_UC}_QUAL "${${${PRODUCTNAME}_UC}_STRING}" )
  endif( )
  STRING( REGEX REPLACE ":" ";" ${${PRODUCTNAME}_UC}_QUAL_LIST "${${${PRODUCTNAME}_UC}_QUAL}" )
  list(REMOVE_ITEM ${${PRODUCTNAME}_UC}_QUAL_LIST debug opt prof)
  STRING( REGEX REPLACE ";" ":" ${${PRODUCTNAME}_UC}_BASE_QUAL "${${${PRODUCTNAME}_UC}_QUAL_LIST}" )
else( )
#  message(STATUS "${${PRODUCTNAME}_UC} has no qualifier")
endif( )
#message(STATUS "${${PRODUCTNAME}_UC} version and qualifier are ${${${PRODUCTNAME}_UC}_VERSION} ${${${PRODUCTNAME}_UC}_QUAL}" )
#message(STATUS "${${PRODUCTNAME}_UC} base qualifier is ${${${PRODUCTNAME}_UC}_BASE_QUAL}" )

# add include directory to include path if it exists
set( ${${PRODUCTNAME}_UC}_INC $ENV{${${PRODUCTNAME}_UC}_INC} )
if ( NOT ${${PRODUCTNAME}_UC}_INC )
  #message(STATUS "find_ups_product: ${PRODUCTNAME} ${${PRODUCTNAME}_UC} has no ${${PRODUCTNAME}_UC}_INC")
else()
  include_directories ( ${${${PRODUCTNAME}_UC}_INC} )
  #message( STATUS "find_ups_product: ${PRODUCTNAME} ${${${PRODUCTNAME}_UC}_INC} added to include path" )
endif ()


endmacro( find_ups_product )
