[
	| repoRoot allClasses |

	Utilities classPool at: #AuthorName put: 'Gastón Caruso'.
	Utilities classPool at: #AuthorInitials put: 'GC'.

	StdIOWriteStream stdout nextPutAll: 'Loading Tonel packages...'; newLine; flush.
	CodePackageFile installPackage: (DirectoryEntry currentDirectory // 'dist/Tonel.pck.st').
	CodePackageFile installPackage: (DirectoryEntry currentDirectory // 'dist/Tests-Tonel.pck.st').

	StdIOWriteStream stdout nextPutAll: 'Exporting Tonel source to src/...'; newLine; flush.
	repoRoot := '/Users/gaston/Code/cuis-tonel' asDirectoryEntry.
	allClasses := #(
		TonelClassDefinition TonelMethodDefinition
		TonelReader TonelWriter TonelImporter TonelImageExporter
		TonelWriterTest TonelReaderTest TonelImporterTest TonelImageExporterTest)
			collect: [ :name | Smalltalk classNamed: name ].
	TonelImageExporter exportClasses: allClasses to: repoRoot.

	StdIOWriteStream stdout nextPutAll: 'Done. src/ updated.'; newLine; flush.
	Smalltalk quitPrimitive: 0
] on: Error do: [ :ex |
	StdIOWriteStream stdout
		nextPutAll: 'ERROR: '; nextPutAll: ex printString; newLine;
		nextPutAll: 'SIGNALER: '; nextPutAll: ex signalerContext printString; newLine;
		flush.
	Smalltalk quitPrimitive: 1
]
