[
	| repoRoot allClasses pkg exportFile |

	Utilities classPool at: #AuthorName put: 'Gastón Caruso'.
	Utilities classPool at: #AuthorInitials put: 'GC'.

	repoRoot := DirectoryEntry currentDirectory.
	CodePackageFile installPackage: repoRoot // 'dist/Tonel.pck.st'.
	CodePackageFile installPackage: repoRoot // 'dist/Tests-Tonel.pck.st'.

	StdIOWriteStream stdout nextPutAll: 'Patching TonelImageExporterTest>>setUp...'; newLine; flush.
	(Smalltalk classNamed: #TonelImageExporterTest) compile:
'setUp
	super setUp.
	exportRoot := ''/tmp/cuis-tonel-exporter-test'' asDirectoryEntry assureExistence'
		classified: 'running'.

	StdIOWriteStream stdout nextPutAll: 'Exporting src/...'; newLine; flush.
	allClasses := #(
		TonelClassDefinition TonelMethodDefinition
		TonelReader TonelWriter TonelImporter TonelImageExporter
		TonelWriterTest TonelReaderTest TonelImporterTest TonelImageExporterTest)
			collect: [ :name | Smalltalk classNamed: name ].
	TonelImageExporter exportClasses: allClasses to: repoRoot.

	StdIOWriteStream stdout nextPutAll: 'Exporting dist/Tests-Tonel.pck.st...'; newLine; flush.
	pkg := CodePackage named: 'Tests-Tonel' createIfAbsent: [ nil ] registerIfNew: false.
	exportFile := repoRoot // 'dist/Tests-Tonel.pck.st'.
	pkg fullFileName: exportFile pathName.
	pkg save.

	StdIOWriteStream stdout nextPutAll: 'Done.'; newLine; flush.
	Smalltalk quitPrimitive: 0
] on: Error do: [ :ex |
	StdIOWriteStream stdout
		nextPutAll: 'ERROR: '; nextPutAll: ex printString; newLine;
		nextPutAll: 'SIGNALER: '; nextPutAll: ex signalerContext printString; newLine;
		flush.
	Smalltalk quitPrimitive: 1
]
