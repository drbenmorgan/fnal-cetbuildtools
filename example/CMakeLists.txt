
set( installFiles
ToyCmake/ups/CMakeLists.txt
ToyCmake/ups/ToyCmake-config-version.cmake.in
ToyCmake/ups/ToyCmake-config.cmake.in
ToyCmake/ups/ToyCmake.table.in
ToyCmake/ups/ToyCmake.version.in )

INSTALL (FILES ToyCmake/CMakeLists.txt ToyCmake/README
         DESTINATION ${product}/${version}/example/ToyCmake )

INSTALL (FILES ToyCmake/ToyCmake/CMakeLists.txt ToyCmake/ToyCmake/DoMath.cc
               ToyCmake/ToyCmake/DoMath.h ToyCmake/ToyCmake/SquareIt.cpp
         DESTINATION ${product}/${version}/example/ToyCmake/ToyCmake )

INSTALL (FILES ToyCmake/test/CMakeLists.txt ToyCmake/test/ToyCmakeTest.cc
         DESTINATION ${product}/${version}/example/ToyCmake/test )

INSTALL (FILES ${installFiles}
         DESTINATION ${product}/${version}/example/ToyCmake/ups )

