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
string(TOUPPER  ${PRODUCTNAME} PRODUCTNAME_UC )
string(TOLOWER ${PRODUCTNAME} PRODUCTNAME_LC )
# add to product list
set(FIND_UPS_INIT "${FIND_UPS_INIT}
find_ups_product( ${PRODUCTNAME} ${version} )")

# require ${PRODUCTNAME_UC}_VERSION or ${PRODUCTNAME_UC}_UPS_VERSION
set( ${PRODUCTNAME_UC}_VERSION $ENV{${PRODUCTNAME_UC}_VERSION} )
if ( NOT ${PRODUCTNAME_UC}_VERSION )
  set( ${PRODUCTNAME_UC}_VERSION $ENV{${PRODUCTNAME_UC}_UPS_VERSION} )
  if ( NOT ${PRODUCTNAME_UC}_VERSION )
     message(FATAL_ERROR "${PRODUCTNAME_UC} has not been setup")
  endif ()
endif ()
#message(STATUS "find_ups_product: ${PRODUCTNAME} version is ${${PRODUCTNAME_UC}_VERSION} ")

# MUST use a unique variable name for the config path
find_file( ${PRODUCTNAME_UC}_CONFIG_PATH ${PRODUCTNAME}-config.cmake $ENV{${PRODUCTNAME_UC}_FQ_DIR}/lib/${PRODUCTNAME}/cmake $ENV{${PRODUCTNAME_UC}_DIR}/cmake )
if(${PRODUCTNAME_UC}_CONFIG_PATH)
  #message(STATUS "find_ups_product: found ${PRODUCTNAME}-config.cmake in ${${PRODUCTNAME_UC}_CONFIG_PATH}")
  _use_find_package( ${PRODUCTNAME} ${PRODUCTNAME_UC} ${version} )
else()
  #message(STATUS "find_ups_product: ${PRODUCTNAME}-config.cmake NOT FOUND")
  _check_version( ${PRODUCTNAME} ${${PRODUCTNAME_UC}_VERSION} ${version} )
endif()


SET ( ${PRODUCTNAME_UC}_STRING $ENV{SETUP_${PRODUCTNAME_UC}} )
STRING( REGEX MATCH "[-][q]" has_qual  "${${PRODUCTNAME_UC}_STRING}" )
STRING( REGEX MATCH "[-][j]" has_j  "${${PRODUCTNAME_UC}_STRING}" )
if( has_qual )
  if( has_j )
     STRING( REGEX REPLACE ".*([-][q]+ )(.*)[ *]([-][-j])" "\\2" ${PRODUCTNAME_UC}_QUAL "${${PRODUCTNAME_UC}_STRING}" )
  else( )
     STRING( REGEX REPLACE ".*([-][q]+ )(.*)" "\\2" ${PRODUCTNAME_UC}_QUAL "${${PRODUCTNAME_UC}_STRING}" )
  endif( )
  STRING( REGEX REPLACE ":" ";" ${PRODUCTNAME_UC}_QUAL_LIST "${${PRODUCTNAME_UC}_QUAL}" )
  list(REMOVE_ITEM ${PRODUCTNAME_UC}_QUAL_LIST debug opt prof)
  STRING( REGEX REPLACE ";" ":" ${PRODUCTNAME_UC}_BASE_QUAL "${${PRODUCTNAME_UC}_QUAL_LIST}" )
else( )
#  message(STATUS "${PRODUCTNAME_UC} has no qualifier")
endif( )
message(STATUS "${PRODUCTNAME_UC} version and qualifier are ${${PRODUCTNAME_UC}_VERSION} ${${PRODUCTNAME_UC}_QUAL}" )
#message(STATUS "${PRODUCTNAME_UC} base qualifier is ${${PRODUCTNAME_UC}_BASE_QUAL}" )

# add include directory to include path if it exists
set( ${PRODUCTNAME_UC}_INC $ENV{${PRODUCTNAME_UC}_INC} )
if ( NOT ${PRODUCTNAME_UC}_INC )
#  message(STATUS "${PRODUCTNAME_UC} has no ${PRODUCTNAME_UC}_INC")
else()
  include_directories ( ${${PRODUCTNAME_UC}_INC} )
  #message( STATUS "${${PRODUCTNAME_UC}_INC} added to include path" )
endif ()


endmacro( find_ups_product )
