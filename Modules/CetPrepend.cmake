# internal function

function (_cet_prepend_directory OUTPUT_VAR prefix)
  set( fileList "" )
  message(STATUS "prepend ${prefix} to ${ARGN}")
  foreach( myfile ${ARGN} )
      get_filename_component( mydir "${myfile}" DIRECTORY )
      if( NOT IS_ABSOLUTE "${mydir}" )
      list(APPEND fileList "${prefix}/${myfile}")
      endif()
  endforeach()
  set (${OUTPUT_VAR} "${fileList}" PARENT_SCOPE)
  message(STATUS "_cet_prepend_directory new list ${OUTPUT_VAR}" )
endfunction()
