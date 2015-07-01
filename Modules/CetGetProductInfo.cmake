#-----------------------------------------------------------------------
# Modifications Copyright 2015 Ben Morgan <Ben.Morgan@warwick.ac.uk
# Modifications Copyright 2015 University of Warwick


set(GET_PRODUCT_INFO ${CETBUILDTOOLS_BINDIR}/report_product_info)
message(STATUS "${GET_PRODUCT_INFO}")

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
