# we install all the example files here
# All cmake files below this directory are part of the example

set( installUPSfiles ToyCmake/ups/CMakeLists.txt
		     ToyCmake/ups/setup_for_development
		     ToyCmake/ups/ToyCmake-config-version.cmake.in
		     ToyCmake/ups/ToyCmake-config.cmake.in
		     ToyCmake/ups/ToyCmake.table.in
		     ToyCmake/ups/ToyCmake.version.in )

set( installTestFiles ToyCmake/test/CMakeLists.txt
                      ToyCmake/test/ToyCmakeTest.cc )

set( installMathFiles ToyCmake/ToyCmake/Math/CMakeLists.txt
                      ToyCmake/ToyCmake/Math/DoMath.h
		      ToyCmake/ToyCmake/Math/DoMath.cc  )

set( installMathIOFiles ToyCmake/ToyCmake/MathIO/CMakeLists.txt
                        ToyCmake/ToyCmake/MathIO/writeResult.h
		        ToyCmake/ToyCmake/MathIO/writeResult.cc  )

set( installSquareFiles ToyCmake/ToyCmake/Square/CMakeLists.txt
		        ToyCmake/ToyCmake/Square/SquareIt.cpp  )

INSTALL (FILES ToyCmake/CMakeLists.txt ToyCmake/README
         DESTINATION ${product}/${version}/example/ToyCmake )

INSTALL (FILES ToyCmake/ToyCmake/CMakeLists.txt 
         DESTINATION ${product}/${version}/example/ToyCmake/ToyCmake )

INSTALL (FILES ${installMathFiles}
         DESTINATION ${product}/${version}/example/ToyCmake/ToyCmake/Math )

INSTALL (FILES ${installMathIOFiles}
         DESTINATION ${product}/${version}/example/ToyCmake/ToyCmake/MathIO )

INSTALL (FILES ${installSquareFiles}
         DESTINATION ${product}/${version}/example/ToyCmake/ToyCmake/Square )

INSTALL (FILES ${installTestFiles}
         DESTINATION ${product}/${version}/example/ToyCmake/test )

INSTALL (FILES ${installUPSfiles}
         DESTINATION ${product}/${version}/example/ToyCmake/ups )

