
include(CMakeParseArguments)


function(cet_make_completions exec)
  set(output_file ${CMAKE_CURRENT_BINARY_DIR}/${exec}_completions)
  add_custom_command(
    OUTPUT ${output_file}
    COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/make_bash_completions ${output_file} ${exec}
    COMMENT "Generating bash completions for ${exec}")
  add_custom_target(MakeCompletions_${exec} ALL DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/${exec}_completions)
  add_dependencies(MakeCompletions_${exec} ${exec})

  install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${exec}_completions DESTINATION ${${product}_bin_dir})
endfunction(cet_make_completions)
