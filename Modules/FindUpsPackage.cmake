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
macro( find_ups_product MY_PRODUCTNAME version )

# get upper and lower case versions of the name
string(TOUPPER  ${MY_PRODUCTNAME} MY_PRODUCTNAME_UC )
string(TOLOWER ${MY_PRODUCTNAME} MY_PRODUCTNAME_LC )
# add to product list
set(CONFIG_FIND_UPS_COMMANDS "${CONFIG_FIND_UPS_COMMANDS}
find_ups_product( ${MY_PRODUCTNAME} ${version} )")
message(STATUS "find_ups_product 0: ${MY_PRODUCTNAME} ${MY_PRODUCTNAME_UC} ")

# require ${MY_PRODUCTNAME_UC}_VERSION or ${MY_PRODUCTNAME_UC}_UPS_VERSION
set( ${MY_PRODUCTNAME_UC}_VERSION $ENV{${MY_PRODUCTNAME_UC}_VERSION} )
if ( NOT ${MY_PRODUCTNAME_UC}_VERSION )
  set( ${MY_PRODUCTNAME_UC}_VERSION $ENV{${MY_PRODUCTNAME_UC}_UPS_VERSION} )
  if ( NOT ${MY_PRODUCTNAME_UC}_VERSION )
     message(FATAL_ERROR "${MY_PRODUCTNAME_UC} has not been setup")
  endif ()
endif ()
message(STATUS "find_ups_product: ${MY_PRODUCTNAME} version is ${${MY_PRODUCTNAME_UC}_VERSION} ")
message(STATUS "find_ups_product 1: ${MY_PRODUCTNAME} ${MY_PRODUCTNAME_UC} ")

# MUST use a unique variable name for the config path
find_file( ${MY_PRODUCTNAME_UC}_CONFIG_PATH ${MY_PRODUCTNAME}-config.cmake $ENV{${MY_PRODUCTNAME_UC}_FQ_DIR}/lib/${MY_PRODUCTNAME}/cmake $ENV{${MY_PRODUCTNAME_UC}_DIR}/cmake )
if(${MY_PRODUCTNAME_UC}_CONFIG_PATH)
  #message(STATUS "find_ups_product: found ${MY_PRODUCTNAME}-config.cmake in ${${MY_PRODUCTNAME_UC}_CONFIG_PATH}")
  _use_find_package( ${MY_PRODUCTNAME} ${MY_PRODUCTNAME_UC} ${version} )
else()
  #message(STATUS "find_ups_product: ${MY_PRODUCTNAME}-config.cmake NOT FOUND")
  _check_version( ${MY_PRODUCTNAME} ${${MY_PRODUCTNAME_UC}_VERSION} ${version} )
endif()
# get upper and lower case versions of the name again
string(TOUPPER  ${MY_PRODUCTNAME} MY_PRODUCTNAME_UC )
string(TOLOWER ${MY_PRODUCTNAME} MY_PRODUCTNAME_LC )
message(STATUS "find_ups_product 2: ${MY_PRODUCTNAME} ${MY_PRODUCTNAME_UC} ")


SET ( ${MY_PRODUCTNAME_UC}_STRING $ENV{SETUP_${MY_PRODUCTNAME_UC}} )
STRING( REGEX MATCH "[-][q]" has_qual  "${${MY_PRODUCTNAME_UC}_STRING}" )
STRING( REGEX MATCH "[-][j]" has_j  "${${MY_PRODUCTNAME_UC}_STRING}" )
if( has_qual )
  if( has_j )
     STRING( REGEX REPLACE ".*([-][q]+ )(.*)[ *]([-][-j])" "\\2" ${MY_PRODUCTNAME_UC}_QUAL "${${MY_PRODUCTNAME_UC}_STRING}" )
  else( )
     STRING( REGEX REPLACE ".*([-][q]+ )(.*)" "\\2" ${MY_PRODUCTNAME_UC}_QUAL "${${MY_PRODUCTNAME_UC}_STRING}" )
  endif( )
  STRING( REGEX REPLACE ":" ";" ${MY_PRODUCTNAME_UC}_QUAL_LIST "${${MY_PRODUCTNAME_UC}_QUAL}" )
  list(REMOVE_ITEM ${MY_PRODUCTNAME_UC}_QUAL_LIST debug opt prof)
  STRING( REGEX REPLACE ";" ":" ${MY_PRODUCTNAME_UC}_BASE_QUAL "${${MY_PRODUCTNAME_UC}_QUAL_LIST}" )
else( )
#  message(STATUS "${MY_PRODUCTNAME_UC} has no qualifier")
endif( )
message(STATUS "${MY_PRODUCTNAME_UC} version and qualifier are ${${MY_PRODUCTNAME_UC}_VERSION} ${${MY_PRODUCTNAME_UC}_QUAL}" )
#message(STATUS "${MY_PRODUCTNAME_UC} base qualifier is ${${MY_PRODUCTNAME_UC}_BASE_QUAL}" )
message(STATUS "find_ups_product 3: ${MY_PRODUCTNAME} ${MY_PRODUCTNAME_UC} ")

# add include directory to include path if it exists
set( ${MY_PRODUCTNAME_UC}_INC $ENV{${MY_PRODUCTNAME_UC}_INC} )
if ( NOT ${MY_PRODUCTNAME_UC}_INC )
  message(STATUS "find_ups_product: ${MY_PRODUCTNAME} ${MY_PRODUCTNAME_UC} has no ${MY_PRODUCTNAME_UC}_INC")
else()
  include_directories ( ${${MY_PRODUCTNAME_UC}_INC} )
  message( STATUS "find_ups_product: ${MY_PRODUCTNAME} ${${MY_PRODUCTNAME_UC}_INC} added to include path" )
endif ()


endmacro( find_ups_product )
