# This macro is used by the FindUps modules

#internal macro
macro(_parse_version version )
   # standard case
   # convert vx_y_z to x.y.z
   # special cases
   # convert va_b_c_d to a.b.c.d
   # convert vx_y to x.y
   
   # replace all underscores with dots
   STRING( REGEX REPLACE "_" "." dotver1 "${version}" )
   STRING( REGEX REPLACE "v(.*)" "\\1" dotver "${dotver1}" )
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
      set( micro " ")
   elseif( ${nfound} EQUAL 1 )
      STRING( REGEX REPLACE "v(.*)_(.*)" "\\1" major "${version}" )
      STRING( REGEX REPLACE "v(.*)_(.*)" "\\2" minor "${version}" )
      set( patch "0")
      set( micro " ")
   elseif( ${nfound} EQUAL 0 )
      STRING( REGEX REPLACE "v(.*)" "\\1" major "${version}" )
      set( minor "0")
      set( patch "0")
      set( micro " ")
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
endmacro(_parse_version)

macro( _check_version product version minimum )
   _parse_version( ${minimum}  )
   set( MINVER ${dotver} )
   set( MINMAJOR ${major} )
   set( MINMINOR ${minor} )
   set( MINPATCH ${patch} )
   set( MINCHAR ${patchchar} )
   set( MINMICRO ${micro} )
   _parse_version( ${version}  )
   set( THISVER ${dotver} )
   set( THISMAJOR ${major} )
   set( THISMINOR ${minor} )
   set( THISPATCH ${patch} )
   set( THISCHAR ${patchchar} )
   set( THISMICRO ${micro} )
   ##message(STATUS "${product} minimum version is ${MINVER} ${MINMAJOR} ${MINMINOR} ${MINPATCH} ${MINCHAR} ${MINMICRO} from ${minimum} " )
   ##message(STATUS "${product} version is ${THISVER} ${THISMAJOR} ${THISMINOR} ${THISPATCH} ${THISCHAR} ${THISMICRO} from ${version} " )
  if( ${THISMAJOR} LESS ${MINMAJOR} )
    message( FATAL_ERROR "Bad Major Version: ${product} ${THISVER} is less than minimum required version ${MINVER}")
  elseif( ${THISMAJOR} EQUAL ${MINMAJOR}
      AND ${THISMINOR} LESS ${MINMINOR} )
    message( FATAL_ERROR "Bad Minor Version: ${product} ${THISVER} is less than minimum required version ${MINVER}")
  elseif( ${THISMAJOR} EQUAL ${MINMAJOR}
      AND ${THISMINOR} EQUAL ${MINMINOR}
      AND ${THISPATCH} LESS ${MINPATCH} )
    message( FATAL_ERROR "Bad Patch Version: ${product} ${THISVER} is less than minimum required version ${MINVER}")
  elseif( ${THISMAJOR} EQUAL ${MINMAJOR}
      AND ${THISMINOR} EQUAL ${MINMINOR}
      AND ${THISPATCH} EQUAL ${MINPATCH}
      AND ${THISCHAR} STRLESS ${MINCHAR} )
    message( FATAL_ERROR "Bad Patch Version: ${product} ${THISVER} is less than minimum required version ${MINVER}")
  elseif( ${THISMAJOR} EQUAL ${MINMAJOR}
      AND ${THISMINOR} EQUAL ${MINMINOR}
      AND ${THISPATCH} EQUAL ${MINPATCH}
      AND ${THISCHAR} EQUAL ${MINCHAR} 
      AND ${THISMICRO} STRLESS ${MINMICRO} )
    message( FATAL_ERROR "Bad Micro Version: ${product} ${THISVER} is less than minimum required version ${MINVER}")
  endif()

  message( STATUS "${product} ${THISVER} meets minimum required version ${MINVER}")
endmacro( _check_version product version minimum )

macro( _check_if_version_greater product version minimum )
   _parse_version( ${minimum}  )
   set( MINVER ${dotver} )
   set( MINMAJOR ${major} )
   set( MINMINOR ${minor} )
   set( MINPATCH ${patch} )
   set( MINCHAR ${patchchar} )
   set( MINMICRO ${micro} )
   _parse_version( ${version}  )
   set( THISVER ${dotver} )
   set( THISMAJOR ${major} )
   set( THISMINOR ${minor} )
   set( THISPATCH ${patch} )
   set( THISCHAR ${patchchar} )
   set( THISMICRO ${micro} )
   ##message(STATUS "${product} minimum version is ${MINVER} ${MINMAJOR} ${MINMINOR} ${MINPATCH} ${MINCHAR} ${MINMICRO} from ${minimum} " )
   ##message(STATUS "${product} version is ${THISVER} ${THISMAJOR} ${THISMINOR} ${THISPATCH} ${THISCHAR} ${THISMICRO} from ${version} " )
  if( ${THISMAJOR} LESS ${MINMAJOR} )
    set( product_version_greater FALSE )
  elseif( ${THISMAJOR} EQUAL ${MINMAJOR}
      AND ${THISMINOR} LESS ${MINMINOR} )
    set( product_version_greater FALSE )
  elseif( ${THISMAJOR} EQUAL ${MINMAJOR}
      AND ${THISMINOR} EQUAL ${MINMINOR}
      AND ${THISPATCH} LESS ${MINPATCH} )
    set( product_version_greater FALSE )
  elseif( ${THISMAJOR} EQUAL ${MINMAJOR}
      AND ${THISMINOR} EQUAL ${MINMINOR}
      AND ${THISPATCH} EQUAL ${MINPATCH}
      AND ${THISCHAR} STRLESS ${MINCHAR} )
    set( product_version_greater FALSE )
  elseif( ${THISMAJOR} EQUAL ${MINMAJOR}
      AND ${THISMINOR} EQUAL ${MINMINOR}
      AND ${THISPATCH} EQUAL ${MINPATCH}
      AND ${THISCHAR} EQUAL ${MINCHAR} 
      AND ${THISMICRO} STRLESS ${MINMICRO} )
    set( product_version_greater FALSE )
  endif()

  #message( STATUS "${product} ${THISVER} check if greater returns ${product_version_greater}")
endmacro( _check_if_version_greater product version minimum )
