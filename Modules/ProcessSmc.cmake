# macro for State Machine Compiler

function(process_smc SMC_LIB_SOURCES)
  foreach(source ${ARGN})
    string(REPLACE ".sm" "_sm.cpp" SMC_CPP_OUTPUT ${source})
    string(REPLACE ".sm" "_sm.h"   SMC_H_OUTPUT   ${source})
    string(REPLACE ".sm" "_sm.dot" SMC_DOT_OUTPUT ${source})
    list(APPEND TMP_SOURCES ${SMC_CPP_OUTPUT})
    add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${SMC_H_OUTPUT}
      ${CMAKE_CURRENT_BINARY_DIR}/${SMC_CPP_OUTPUT}
      ${CMAKE_CURRENT_BINARY_DIR}/${SMC_DOT_OUTPUT}
      COMMAND java -jar $ENV{SMC_HOME}/bin/Smc.jar -d ${CMAKE_CURRENT_BINARY_DIR} -graph -glevel 2 ${CMAKE_CURRENT_SOURCE_DIR}/${source}
      COMMAND java -jar $ENV{SMC_HOME}/bin/Smc.jar -d ${CMAKE_CURRENT_BINARY_DIR} -c++ ${CMAKE_CURRENT_SOURCE_DIR}/${source}
      COMMAND perl -wapi\\~ -e 's&\(\#\\s*include\\s+\"\)\\Q${CMAKE_BINARY_DIR}/\\E&$$1&' ${CMAKE_CURRENT_BINARY_DIR}/${SMC_CPP_OUTPUT}
      DEPENDS ${source}
      )
  endforeach()
  set_source_files_properties(${TMP_SOURCES}
    PROPERTIES COMPILE_FLAGS "-Wno-unused-parameter" )
  set(${SMC_LIB_SOURCES} ${TMP_SOURCES} PARENT_SCOPE)
endfunction()
