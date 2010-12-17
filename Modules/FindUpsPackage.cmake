# define the environment for a ups product
#
# find_ups_product( PRODUCTNAME version )
#  PRODUCTNAME - product name
#  version - minimum version required

include(CheckUpsVersion)

# since variables are passed, this is implemented as a macro
macro( find_ups_product PRODUCTNAME version )

# get upper and lower case versions of the name
string(TOUPPER  ${PRODUCTNAME} PRODUCTNAME_UC )
string(TOLOWER ${PRODUCTNAME} PRODUCTNAME_LC )

# require ${PRODUCTNAME_UC}_VERSION
set( ${PRODUCTNAME_UC}_VERSION $ENV{${PRODUCTNAME_UC}_VERSION} )
if ( NOT ${PRODUCTNAME_UC}_VERSION )
  message(FATAL_ERROR "${PRODUCTNAME_UC} has not been setup")
endif ()

_check_version( ${PRODUCTNAME} ${${PRODUCTNAME_UC}_VERSION} ${version} )

SET ( ${PRODUCTNAME_UC}_STRING $ENV{SETUP_${PRODUCTNAME_UC}} )
STRING( REGEX MATCH "[-][q]" has_qual  "${${PRODUCTNAME_UC}_STRING}" )
STRING( REGEX MATCH "[-][j]" has_j  "${${PRODUCTNAME_UC}_STRING}" )
if( has_qual )
  if( has_j )
     STRING( REGEX REPLACE ".*([-][q]+ )(.*)([-][-j])" "-q \\2" ${PRODUCTNAME_UC}_QUAL "${${PRODUCTNAME_UC}_STRING}" )
  else( )
     STRING( REGEX REPLACE ".*([-][q]+ )(.*)" "-q \\2" ${PRODUCTNAME_UC}_QUAL "${${PRODUCTNAME_UC}_STRING}" )
  endif( )
else( )
  message(STATUS "${PRODUCTNAME_UC} has no qualifier")
endif( )
message(STATUS "${PRODUCTNAME_UC} version and qualifier are ${${PRODUCTNAME_UC}_VERSION} ${${PRODUCTNAME_UC}_QUAL}" )

# add include directory to include path if it exists
set( ${PRODUCTNAME_UC}_INC $ENV{${PRODUCTNAME_UC}_INC} )
if ( NOT ${PRODUCTNAME_UC}_INC )
#  message(STATUS "${PRODUCTNAME_UC} has no ${PRODUCTNAME_UC}_INC")
else()
  include_directories ( ${${PRODUCTNAME_UC}_INC} )
  message( STATUS "${${PRODUCTNAME_UC}_INC} added to include path" )
endif ()


endmacro( find_ups_product )
