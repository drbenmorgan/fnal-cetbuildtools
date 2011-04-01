
INSTALL(FILES
	BuildDictionary.cmake
	BuildPlugins.cmake
	BuildSubdirectories.cmake
	CetParseArgs.cmake
	CetTest.cmake
	CheckUpsVersion.cmake
	EnsureOutOfSourceBuild.cmake
	FindCompilerVersion.cmake
	FindUpsBoost.cmake
	FindUpsPackage.cmake
	FindUpsRoot.cmake
	InstallSource.cmake
	ParseUpsVersion.cmake
	SetFlavorQual.cmake
	UseCPack.cmake
  DESTINATION ${product}/${version}/Modules
  )

