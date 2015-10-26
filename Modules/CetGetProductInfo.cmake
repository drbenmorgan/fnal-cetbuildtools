set( CETBUILDTOOLS_DIR $ENV{CETBUILDTOOLS_DIR} )
if( NOT CETBUILDTOOLS_DIR )
  #message(STATUS "_get_cetpkg_info: looking in path")
  find_program(GET_PRODUCT_INFO report_product_info $ENV{PATH})
else()
  set( GET_PRODUCT_INFO "${CETBUILDTOOLS_DIR}/bin/report_product_info" )
endif ()
#message(STATUS "GET_PRODUCT_INFO: ${GET_PRODUCT_INFO}")
if( NOT GET_PRODUCT_INFO )
  message(FATAL_ERROR "CetGetProductInfo.cmake: Can't find report_product_info")
endif()

function(cet_get_product_info_item ITEM OUTPUT_VAR)
  execute_process(COMMAND ${GET_PRODUCT_INFO}
    ${CMAKE_CURRENT_BINARY_DIR}
    ${ITEM}
    OUTPUT_VARIABLE output
    OUTPUT_STRIP_TRAILING_WHITESPACE
    RESULT_VARIABLE ec
    )
  set(${OUTPUT_VAR} ${output} PARENT_SCOPE)
  if(ARGV2)
    set(${ARGV2} ${ec} PARENT_SCOPE)
  endif()
endfunction()
