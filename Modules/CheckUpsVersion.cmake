########################################################################
# Utility macros and functions, mostly for private use by other
# cetbuildtools CMake utilities.
#
# Also provides the public function check_ups_version.
#
####################################
# check_ups_version(product version minimum
#                   [PRODUCT_OLDER_VAR <var>]
#                   [PRODUCT_MATCHES_VAR <var>])
#
# Options and arguments:
#
# product
#   The name of the UPS product whose version is to be tested.
#
# version
#   The version of the product (eg from $ENV{<product>_VERSION}).
#
# minimum
#   The minimum required version of the product.
#
# PRODUCT_OLDER_VAR
#   If the product's version is does not satisfy the required minimum,
#   the variable specified herein is set to TRUE. Otherwise it is set to
#   FALSE.
#
# PRODUCT_MATCHES_VAR
#   If the product's version is at least the requiremd minimum, the
#   variable specified herein is set to TRUE. Otherwise it is set to
#   FALSE.
#
# NOTES.
#
# * At least one of PRODUCT_OLDER_VAR or PRODUCT_MATCHES_VAR must be
# supplied.
########################################################################

include(CMakeParseArguments)

#internal macro
macro(_get_dotver myversion )
   # replace all underscores with dots
   STRING( REGEX REPLACE "_" "." dotver1 "${myversion}" )
   STRING( REGEX REPLACE "v(.*)" "\\1" dotver "${dotver1}" )
endmacro(_get_dotver myversion )

#internal macro
macro(_parse_version version )
   # standard case
   # convert vx_y_z to x.y.z
   # special cases
   # convert va_b_c_d to a.b.c.d
   # convert vx_y to x.y
   
   # replace all underscores with dots
   _get_dotver( ${version} )
   ##message( STATUS "_parse_version: ${version} becomes ${dotver}" )
   string(REGEX MATCHALL "_" nfound ${version} )
   ##message( STATUS "_parse_version: matchall returns ${nfound}" )
   list(LENGTH nfound nfound)
   ##message( STATUS "_parse_version: nfound is now ${nfound} " )
   if( ${nfound} EQUAL 3 )
      STRING( REGEX REPLACE "v(.*)_(.*)_(.*)_(.*)" "\\1" major "${version}" )
      STRING( REGEX REPLACE "v(.*)_(.*)_(.*)_(.*)" "\\2" minor "${version}" )
      STRING( REGEX REPLACE "v(.*)_(.*)_(.*)_(.*)" "\\3" patch "${version}" )
      STRING( REGEX REPLACE "v(.*)_(.*)_(.*)_(.*)" "\\4" micro "${version}" )
   elseif( ${nfound} EQUAL 2 )
      STRING( REGEX REPLACE "v(.*)_(.*)_(.*)" "\\1" major "${version}" )
      STRING( REGEX REPLACE "v(.*)_(.*)_(.*)" "\\2" minor "${version}" )
      STRING( REGEX REPLACE "v(.*)_(.*)_(.*)" "\\3" patch "${version}" )
      set( micro "0")
   elseif( ${nfound} EQUAL 1 )
      STRING( REGEX REPLACE "v(.*)_(.*)" "\\1" major "${version}" )
      STRING( REGEX REPLACE "v(.*)_(.*)" "\\2" minor "${version}" )
      set( patch "0")
      set( micro "0")
   elseif( ${nfound} EQUAL 0 )
      STRING( REGEX REPLACE "v(.*)" "\\1" major "${version}" )
      set( minor "0")
      set( patch "0")
      set( micro "0")
   else()
      message( STATUS "_parse_version found extra underscores in ${version}" )
      STRING( REGEX REPLACE "v(.*)_(.*)_(.*)_(.*)" "\\1" major "${version}" )
      STRING( REGEX REPLACE "v(.*)_(.*)_(.*)_(.*)" "\\2" minor "${version}" )
      STRING( REGEX REPLACE "v(.*)_(.*)_(.*)_(.*)" "\\3" patch "${version}" )
      STRING( REGEX REPLACE "v(.*)_(.*)_(.*)_(.*)" "\\4" micro "${version}" )
   endif()
   ##message( STATUS "_parse_version: major ${major} " )
   ##message( STATUS "_parse_version: minor ${minor} " )
   ##message( STATUS "_parse_version: patch ${patch} " )
   ##message( STATUS "_parse_version: micro ${micro}" )
   string(TOUPPER  ${patch} PATCH_UC )
   STRING(REGEX MATCH [A-Z] has_alpha ${PATCH_UC})
   if( has_alpha )
      #message( STATUS "deal with alphabetical character in patch version ${patch}" )
      STRING(REGEX REPLACE "(.*)([A-Z])" "\\1" patch  ${PATCH_UC})
      STRING(REGEX REPLACE "(.*)([A-Z])" "\\2" patchchar  ${PATCH_UC})
   else( has_alpha )
      set( patchchar " ")
   endif( has_alpha )
   set( basicdotver ${major}.${minor}.${patch} )
   #message( STATUS "_parse_version: ${version} becomes ${dotver} ${basicdotver}" )
endmacro(_parse_version)

macro( _check_version product version minimum )
  _check_if_version_greater( ${product} ${version} ${minimum} )
  if( product_version_less )
    message( FATAL_ERROR "Bad Version: ${product} ${THISVER} is less than minimum required version ${MINVER}")
  endif()

  #message( STATUS "${product} ${THISVER} meets minimum required version ${MINVER}")
endmacro( _check_version product version minimum )
 
macro( _compare_root_micro microversion micromin )
   # root release old numbering:
   # 5.28.00.rc1 (release candidate)
   # 5.28.00 (release)
   # 5.28.00.p01 (fermi patch release)
   # 5.28.00a (patch release)
   # root release new numbering:
   # 5.30.00.rc1 (release candidate)
   # 5.30.00 (release)
   # 5.30.00.p01 (fermi patch release)
   # 5.30.01 (patch release)
   # 5.30.01.p01 (fermi patch release)
   ##message(STATUS "_compare_root_micro: check ${microversion} against ${micromin}")   
   string(TOUPPER  ${microversion} VERUC )
   STRING(REGEX MATCH [R][C] rcver ${VERUC})
   if( rcver )
      STRING(REGEX REPLACE "[R][C](.*)" "\\1" rcvnum  ${VERUC})
      ##message(STATUS "_compare_root_micro: version is release candidate ${microversion} ${rcvnum}")
   endif( rcver )
   STRING(REGEX MATCH [P] fermipatch ${VERUC})
   if( fermipatch )
      STRING(REGEX REPLACE "[P](.*)" "\\1" pvnum  ${VERUC})
      ##message(STATUS "_compare_root_micro: version is fermi patch ${microversion} ${pvnum}")
   endif( fermipatch )
   string(TOUPPER  ${micromin} MINUC )
   STRING(REGEX MATCH [R][C] rcmin ${MINUC})
   if( rcmin )
      STRING(REGEX REPLACE "[R][C](.*)" "\\1" rcminnum  ${MINUC})
   endif( rcmin )
   STRING(REGEX MATCH [P] fermipatchmin ${MINUC})
   if( fermipatchmin )
      STRING(REGEX REPLACE "[P](.*)" "\\1" pminnum  ${MINUC})
   endif( fermipatchmin )
   
   # is the minimum microversion a fermi patch?
   # when comparing microversions, a fermi patch should trump everything else
   if( fermipatchmin )
      ##message(STATUS "_compare_root_micro: minimum is fermi patch ${micromin} ${pminnum}")
      if( fermipatch )
         if(  ${pvnum} LESS ${pminnum} )
            set( product_version_less TRUE )
	 endif()
      else()
        set( product_version_less TRUE )
      endif()
   endif( fermipatchmin )
   # is the minimum microversion a release candidate?
   # when comparing microversions, everything else is better than a release candidate
   if( rcmin )
      ##message(STATUS "_compare_root_micro: minimum is release candidate ${micromin} ${rcminnum}")
      if( rcver )
         if(  ${rcvnum} LESS ${rcminnum} )
            set( product_version_less TRUE )
	 endif()
      endif()
   endif( rcmin )
endmacro( _compare_root_micro microversion micromin )

function( check_ups_version product version minimum )
  cmake_parse_arguments(CV "" "PRODUCT_OLDER_VAR;PRODUCT_MATCHES_VAR" "" ${ARGN})
  if ((NOT CV_PRODUCT_OLDER_VAR) AND (NOT CV_PRODUCT_MATCHES_VAR))
    message(FATAL_ERROR "check_ups_version requires at least one of PRODUCT_OLDER_VAR or PRODUCT_MATCHES_VAR")
  endif()
  _parse_version( ${minimum}  )
  set( MINVER ${dotver} )
  set( MINCVER ${basicdotver} )
  set( MINMAJOR ${major} )
  set( MINMINOR ${minor} )
  set( MINPATCH ${patch} )
  set( MINCHAR ${patchchar} )
  set( MINMICRO ${micro} )
  _parse_version( ${version}  )
  set( THISVER ${dotver} )
  set( THISCVER ${basicdotver} )
  set( THISMAJOR ${major} )
  set( THISMINOR ${minor} )
  set( THISPATCH ${patch} )
  set( THISCHAR ${patchchar} )
  set( THISMICRO ${micro} )
  ##message(STATUS "check_ups_version: ${product} minimum version is ${MINVER} ${MINMAJOR} ${MINMINOR} ${MINPATCH} ${MINCHAR} ${MINMICRO} from ${minimum} " )
  ##message(STATUS "check_ups_version: ${product} version is ${THISVER} ${THISMAJOR} ${THISMINOR} ${THISPATCH} ${THISCHAR} ${THISMICRO} from ${version} " )
  # initialize product_older
  set( product_older FALSE )
  if( ${product} MATCHES "ROOT" )
    if( ${THISCVER} VERSION_LESS ${MINCVER} )
	    set( product_older TRUE )
    elseif( ${THISCVER} VERSION_EQUAL ${MINCVER}
	      AND ${THISCHAR} STRLESS ${MINCHAR} )
	    set( product_older TRUE )
    elseif( ${THISCVER} VERSION_EQUAL ${MINCVER}
	      AND ${THISCHAR} STREQUAL ${MINCHAR} )
	    # root micro versions require special handling
	    #message(STATUS "root versions match so far, compare  ${THISMICRO} to ${MINMICRO}")
	    _compare_root_micro( ${THISMICRO} ${MINMICRO} )
    endif()
  else()
    if( ${THISCVER} VERSION_LESS ${MINCVER} )
      set( product_older TRUE )
    elseif( ${THISCVER} VERSION_EQUAL ${MINCVER}
	      AND ${THISCHAR} STRLESS ${MINCHAR} )
	    set( product_older TRUE )
    elseif( ${THISCVER} VERSION_EQUAL ${MINCVER}
	      AND ${THISCHAR} STREQUAL ${MINCHAR} 
	      AND ${THISMICRO} LESS ${MINMICRO} )
	    set( product_older TRUE )
    endif()
  endif()
  # check for special cases such as "nightly"
  STRING(REGEX MATCH "([0-9]+)" isnumeric "${version}")
  if( NOT isnumeric )
    ##message(STATUS "check_ups_version: ${product} ${version} is not numeric")
    set( product_older FALSE )
  endif()
  if (CV_PROUCT_OLDER_VAR)
    set(${CV_PRODUCT_OLDER_VAR} ${product_older} PARENT_SCOPE)
  endif()
  if (CV_PRODUCT_MATCHES_VAR)
    if (product_older)
      set(${CV_PRODUCT_MATCHES_VAR} FALSE PARENT_SCOPE)
    else()
      set(${CV_PRODUCT_MATCHES_VAR} TRUE PARENT_SCOPE)
    endif()
  endif()
  ##message( STATUS "check_ups_version: ${product} ${THISVER} check if greater returns ${product_older}")
endfunction( check_ups_version product version minimum )

# For backward compatibility.
macro(_check_if_version_greater product version minimum)
  check_ups_version(${product} ${version} ${minimum}
    PRODUCT_OLDER_VAR product_version_less)
endmacro(_check_if_version_greater product version minimum)
