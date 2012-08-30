
INSTALL(FILES
	BuildDictionary.cmake
	BuildSubdirectories.cmake
        CetBuildTable.cmake
	CetParseArgs.cmake
	CetTest.cmake
	CetMake.cmake
	CetCMakeConfig.cmake
	CetCMakeEnv.cmake
	CheckUpsVersion.cmake
	EnsureOutOfSourceBuild.cmake
	FindCetPackage.cmake
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

