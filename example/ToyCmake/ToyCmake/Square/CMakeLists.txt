
# how to link with boost and other system libraries
#link_libraries( ${Boost_FILESYSTEM_LIBRARY}
#                ${REFLEX}
#                dl )

add_executable( SquareIt   SquareIt.cpp   )
target_link_libraries( SquareIt ToyMath ToyMathIO )

install ( TARGETS SquareIt   DESTINATION ${flavorqual_dir}/bin )


