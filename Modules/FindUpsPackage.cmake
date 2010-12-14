# define the environment for a ups product
#
# find_ups_product( PRODUCTNAME version )
#  PRODUCTNAME - product name 
#  version - minimum version required

# since variables are passed, this is implemented as a macro

#internal macro
macro( _check_version product version minimum )
   # convert vx_y_z to x.y.z
   # must also recognize vx_y
   STRING( REGEX REPLACE "v(.*)_(.*)_(.*)" "\\1.\\2" MINVER "${minimum}" )
   STRING(REGEX MATCH [_] has_underscore ${MINVER})
     if( has_underscore )
       STRING( REGEX REPLACE "v(.*)_(.*)" "\\1.\\2" MINVER "${minimum}" )
     endif( has_underscore )
   STRING( REGEX REPLACE "v(.*)_(.*)_(.*)" "\\1.\\2.\\3" THISVER "${version}" )
   STRING(REGEX MATCH [_] has_underscore ${THISVER})
     if( has_underscore )
       STRING( REGEX REPLACE "v(.*)_(.*)" "\\1.\\2" THISVER "${version}" )
     endif( has_underscore )
   #message(STATUS "${product} minimum version is ${MINVER} from ${minimum} " )
   #message(STATUS "${product}  version is ${THISVER} from ${version} " )
   if(  ${THISVER} STRGREATER ${MINVER} )
     message( STATUS "${product} ${THISVER} meets minimum required version ${MINVER}")
   else()
     if(  ${THISVER} EQUAL ${MINVER} )
       message( STATUS "${product} ${THISVER} meets minimum required version ${MINVER}")
     else()
       message( FATAL_ERROR "${product} ${THISVER} is less than minimum required version ${MINVER}")
     endif()
   endif()
endmacro( _check_version product version minimum )

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
