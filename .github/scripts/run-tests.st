[
	| suite result exitCode |

	Utilities classPool at: #AuthorName put: 'Gastón Caruso'.
	Utilities classPool at: #AuthorInitials put: 'GC'.

	StdIOWriteStream stdout nextPutAll: 'Loading packages...'; newLine; flush.
	CodePackageFile installPackage: DirectoryEntry currentDirectory // 'dist/Tonel.pck.st'.
	CodePackageFile installPackage: DirectoryEntry currentDirectory // 'dist/Tests-Tonel.pck.st'.

	ChangeSet fileIn: DirectoryEntry currentDirectory // '.github/scripts/TestResultConsolePrinter.st'.

	suite := TestSuite new.
	#(TonelWriterTest TonelReaderTest TonelImporterTest TonelImageExporterTest) do: [ :name |
		(Smalltalk classNamed: name) addToSuiteFromSelectors: suite ].

	result := suite run.
	result printReport.

	exitCode := (result hasFailures or: [ result hasErrors ]) ifTrue: [ 1 ] ifFalse: [ 0 ].
	Smalltalk quitPrimitive: exitCode
] on: Error do: [ :ex |
	StdIOWriteStream stdout
		nextPutAll: 'ERROR: '; nextPutAll: ex printString; newLine;
		nextPutAll: 'SIGNALER: '; nextPutAll: ex signalerContext printString; newLine;
		flush.
	Smalltalk quitPrimitive: 1
]
