# define the environment for a CET style ups product
#
# find_cet_product( PRODUCTNAME version )
#  PRODUCTNAME - product name
#  version - minimum version required
# The find_cet_product uses find_package to check version numbers
# and pick up any other variables defined by the package-config.cmake file
# ----------------------------------------------------------------------
macro( find_cet_product PRODUCTNAME version )

# get upper and lower case versions of the name
string(TOUPPER  ${PRODUCTNAME} PRODUCTNAME_UC )
string(TOLOWER ${PRODUCTNAME} PRODUCTNAME_LC )

# require ${PRODUCTNAME_UC}_VERSION
set( ${PRODUCTNAME_UC}_VERSION $ENV{${PRODUCTNAME_UC}_VERSION} )
if ( NOT ${PRODUCTNAME_UC}_VERSION )
  message(FATAL_ERROR "${PRODUCTNAME_UC} has not been setup")
endif ()

# we use find package to check the version
# replace all underscores with dots
STRING( REGEX REPLACE "_" "." dotver1 "${version}" )
STRING( REGEX REPLACE "v(.*)" "\\1" dotver "${dotver1}" )
find_package( ${PRODUCTNAME} ${dotver}  )
if( NOT ${${PRODUCTNAME}_FOUND} )
  message(FATAL_ERROR "ERROR: ${PRODUCTNAME} was NOT found ")
endif()
if(  ${${PRODUCTNAME_UC}_VERSION} MATCHES ${${PRODUCTNAME}_UPS_VERSION})
  #message(STATUS "${PRODUCTNAME} versions match: ${${PRODUCTNAME_UC}_VERSION} ${${PRODUCTNAME}_UPS_VERSION} ")
else()
  message(STATUS "ERROR: There is an inconsistency between the ${PRODUCTNAME} table and config files ")
  message(FATAL_ERROR "${PRODUCTNAME} versions DO NOT match: ${${PRODUCTNAME_UC}_VERSION} ${${PRODUCTNAME}_UPS_VERSION} ")
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

endmacro( find_cet_product )
# ----------------------------------------------------------------------
