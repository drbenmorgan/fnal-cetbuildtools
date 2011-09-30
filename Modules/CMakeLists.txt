
INSTALL(FILES
	BuildDictionary.cmake
	BuildSubdirectories.cmake
	CetParseArgs.cmake
	CetTest.cmake
	CetMake.cmake
	CheckUpsVersion.cmake
	EnsureOutOfSourceBuild.cmake
	FindCompilerVersion.cmake
	FindUpsBoost.cmake
	FindUpsPackage.cmake
	FindUpsRoot.cmake
	InstallSource.cmake
	ParseUpsVersion.cmake
	SetCompilerFlags.cmake
	SetFlavorQual.cmake
	UseCPack.cmake
  DESTINATION ${product}/${version}/Modules
  )

