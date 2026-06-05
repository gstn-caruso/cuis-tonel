Class {
	#name : 'TonelImageExporterTest',
	#superclass : 'TestCase',
	#instVars : [
		'exportRoot'
	],
	#category : 'Tests-Tonel',
	#package : 'Tests',
	#tag : 'Tonel'
}

{ #category : 'assertions' }
TonelImageExporterTest >> contentsOf: aFileEntry [
	aFileEntry readStreamDo: [ :stream | ^ stream upToEnd ]
]

{ #category : 'running' }
TonelImageExporterTest >> setUp [
	super setUp.
	exportRoot := '/tmp/cuis-tonel-exporter-test' asDirectoryEntry assureExistence
]

{ #category : 'tests' }
TonelImageExporterTest >> testExportClassesWritesGroupedTonelFile [
	| file source |
	TonelImageExporter exportClasses: { TonelWriterTest } to: exportRoot.
	file := exportRoot / 'src' / 'Tests-Tonel' // 'TonelWriterTest.class.st'.
	self assert: file exists.
	source := self contentsOf: file.
	self assert: (source includesSubString: 'Class {').
	self assert: (source includesSubString: 'TonelWriterTest >> assert: aString includes: expectedSubstring [')
]

{ #category : 'tests' }
TonelImageExporterTest >> testExportWritesExtensionMethodsIntoOwningPackage [
	"An extension method (category starting with $*) must be written as a .extension.st under the owning package, and must NOT appear in the home class file."
	| header |
	header := 'TonelImageExporterTest >> ', 'fixtureExtensionMethod ['.
	TonelImageExporterTest compile: 'fixtureExtensionMethod
	^ 42' classified: '*ZzzFakePackage'.
	[ | classFile extFile |
		TonelImageExporter exportClasses: { TonelImageExporterTest } to: exportRoot.
		classFile := exportRoot / 'src' / 'Tests-Tonel' // 'TonelImageExporterTest.class.st'.
		extFile := exportRoot / 'src' / 'ZzzFakePackage' // 'TonelImageExporterTest.extension.st'.
		self assert: extFile exists.
		self assert: ((self contentsOf: extFile) includesSubString: 'Extension { #name : ''TonelImageExporterTest'' }').
		self assert: ((self contentsOf: extFile) includesSubString: header).
		self deny: ((self contentsOf: classFile) includesSubString: header) ]
		ensure: [ TonelImageExporterTest removeSelector: #fixtureExtensionMethod ]
]

{ #category : 'tests' }
TonelImageExporterTest >> testExportWritesTonelProperties [
	| file |
	TonelImageExporter exportClasses: { TonelWriterTest } to: exportRoot.
	file := exportRoot / 'src' // '.properties'.
	self assert: file exists.
	self assert: ((self contentsOf: file) includesSubString: '#format : #tonel')
]

{ #category : 'tests' }
TonelImageExporterTest >> testFileNameForClass [
	self assert: (TonelImageExporter fileNameForClass: TonelWriterTest) equals: 'TonelWriterTest.class.st'
]

{ #category : 'tests' }
TonelImageExporterTest >> testPackageNameForCategory [
	self assert: (TonelImageExporter packageNameForCategory: #'Kernel-Objects') equals: 'Kernel'.
	self assert: (TonelImageExporter packageNameForCategory: #'Tests-Tonel') equals: 'Tests'.
	self assert: (TonelImageExporter packageNameForCategory: #Tonel) equals: 'Tonel'
]

{ #category : 'tests - round trip' }
TonelImageExporterTest >> testRoundTripPreservesShapeAndExtension [
	| klass root reread |
	root := '/tmp/cuis-tonel-rt' asDirectoryEntry.
	root exists ifTrue: [ root recursiveDelete ].
	root assureExistence.
	[
		klass := ArrayedCollection variableByteSubclass: #TonelRTBytes instanceVariableNames: '' classVariableNames: '' poolDictionaries: '' category: 'Tests-Tonel-RT'.
		klass compile: 'fortyTwo ^ 42' classified: 'accessing'.
		klass compile: 'extPing ^ 7' classified: '*ZzzExtPkg'.
		TonelImageExporter exportClasses: { klass } to: root.
		klass removeFromSystemUnlogged.
		self assert: (Smalltalk classNamed: #TonelRTBytes) isNil.
		TonelImporter importDirectory: (root / 'src').
		reread := Smalltalk classNamed: #TonelRTBytes.
		self deny: reread isNil.
		self assert: reread isBytes.
		self assert: (reread canUnderstand: #fortyTwo).
		self assert: (reread canUnderstand: #extPing).
		self assert: (reread organization categoryOfElement: #extPing) equals: #'*ZzzExtPkg'
	] ensure: [
		(Smalltalk classNamed: #TonelRTBytes) ifNotNil: [:c | c removeFromSystemUnlogged ].
		root exists ifTrue: [ root recursiveDelete ] ]
]
