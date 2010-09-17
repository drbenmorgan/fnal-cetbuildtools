
ADD_EXECUTABLE (ToyCmakeTest ToyCmakeTest.cc )

TARGET_LINK_LIBRARIES ( ToyCmakeTest ToyCmake )

ADD_TEST(ToyCmakeTest ${EXECUTABLE_OUTPUT_PATH}/ToyCmakeTest)

