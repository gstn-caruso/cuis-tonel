'From Cuis7.7 [latest update: #7965] on 4 June 2026 at 8:55:59 pm'!
'Description Tests for Cuis Tonel export support.'!
!provides: 'Tests-Tonel' 1 4!
!requires: 'Tonel' 1 1 nil!
SystemOrganization addCategory: #'Tests-Tonel'!
SystemOrganization addCategory: #'Tests-Tonel-Imported'!


!classDefinition: #TonelImageExporterTest category: #'Tests-Tonel'!
TestCase subclass: #TonelImageExporterTest
	instanceVariableNames: 'exportRoot'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Tests-Tonel'!
!classDefinition: 'TonelImageExporterTest class' category: #'Tests-Tonel'!
TonelImageExporterTest class
	instanceVariableNames: ''!

!classDefinition: #TonelImporterTest category: #'Tests-Tonel'!
TestCase subclass: #TonelImporterTest
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Tests-Tonel'!
!classDefinition: 'TonelImporterTest class' category: #'Tests-Tonel'!
TonelImporterTest class
	instanceVariableNames: ''!

!classDefinition: #TonelReaderTest category: #'Tests-Tonel'!
TestCase subclass: #TonelReaderTest
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Tests-Tonel'!
!classDefinition: 'TonelReaderTest class' category: #'Tests-Tonel'!
TonelReaderTest class
	instanceVariableNames: ''!

!classDefinition: #TonelWriterTest category: #'Tests-Tonel'!
TestCase subclass: #TonelWriterTest
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Tests-Tonel'!
!classDefinition: 'TonelWriterTest class' category: #'Tests-Tonel'!
TonelWriterTest class
	instanceVariableNames: ''!


!TonelImageExporterTest methodsFor: 'assertions' stamp: 'GC 4/Jun/2026 20:53:46'!
contentsOf: aFileEntry
	aFileEntry readStreamDo: [ :stream | ^ stream upToEnd ]! !

!TonelImageExporterTest methodsFor: 'running' stamp: 'GC 4/Jun/2026 20:53:46'!
setUp
	super setUp.
	exportRoot := '/tmp/cuis-tonel-exporter-test' asDirectoryEntry assureExistence! !

!TonelImageExporterTest methodsFor: 'tests' stamp: 'GC 4/Jun/2026 20:53:46'!
testExportClassesWritesGroupedTonelFile
	| file source |
	TonelImageExporter exportClasses: { TonelWriterTest } to: exportRoot.
	file := exportRoot / 'src' / 'Tests-Tonel' // 'TonelWriterTest.class.st'.
	self assert: file exists.
	source := self contentsOf: file.
	self assert: (source includesSubString: 'Class {').
	self assert: (source includesSubString: 'TonelWriterTest >> assert: aString includes: expectedSubstring [')! !

!TonelImageExporterTest methodsFor: 'tests' stamp: 'GC 4/Jun/2026 20:53:46'!
testExportWritesExtensionMethodsIntoOwningPackage
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
		ensure: [ TonelImageExporterTest removeSelector: #fixtureExtensionMethod ]! !

!TonelImageExporterTest methodsFor: 'tests' stamp: 'GC 4/Jun/2026 20:53:46'!
testExportWritesTonelProperties
	| file |
	TonelImageExporter exportClasses: { TonelWriterTest } to: exportRoot.
	file := exportRoot / 'src' // '.properties'.
	self assert: file exists.
	self assert: ((self contentsOf: file) includesSubString: '#format : #tonel')! !

!TonelImageExporterTest methodsFor: 'tests' stamp: 'GC 4/Jun/2026 20:53:46'!
testFileNameForClass
	self assert: (TonelImageExporter fileNameForClass: TonelWriterTest) equals: 'TonelWriterTest.class.st'! !

!TonelImageExporterTest methodsFor: 'tests' stamp: 'GC 4/Jun/2026 20:53:46'!
testPackageNameForCategory
	self assert: (TonelImageExporter packageNameForCategory: #'Kernel-Objects') equals: 'Kernel'.
	self assert: (TonelImageExporter packageNameForCategory: #'Tests-Tonel') equals: 'Tests'.
	self assert: (TonelImageExporter packageNameForCategory: #Tonel) equals: 'Tonel'! !

!TonelImageExporterTest methodsFor: 'tests - round trip' stamp: 'GC 4/Jun/2026 20:26:29'!
testRoundTripPreservesShapeAndExtension
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
		root exists ifTrue: [ root recursiveDelete ] ]! !

!TonelImporterTest methodsFor: 'fixtures' stamp: 'GC 4/Jun/2026 20:53:46'!
orderingChildSource
	^ 'Class {
	#name : ''TonelOrderingChild'',
	#superclass : ''TonelOrderingParent'',
	#category : ''Tests-Tonel-Imported'',
	#package : ''Tests'',
	#tag : ''Tonel-Imported''
}
'! !

!TonelImporterTest methodsFor: 'fixtures' stamp: 'GC 4/Jun/2026 20:53:46'!
orderingParentSource
	^ 'Class {
	#name : ''TonelOrderingParent'',
	#superclass : ''Object'',
	#category : ''Tests-Tonel-Imported'',
	#package : ''Tests'',
	#tag : ''Tonel-Imported''
}
'! !

!TonelImporterTest methodsFor: 'fixtures' stamp: 'GC 4/Jun/2026 20:53:46'!
sampleTonelSource
	^ TonelReaderTest new sampleTonelSource! !

!TonelImporterTest methodsFor: 'fixtures' stamp: 'GC 4/Jun/2026 20:22:06'!
shapeSourceNamed: name superclass: sup type: type
	^ String streamContents: [:s |
		s nextPutAll: 'Class {'; newLine.
		s nextPutAll: '	#name : '''; nextPutAll: name; nextPutAll: ''','; newLine.
		s nextPutAll: '	#superclass : '''; nextPutAll: sup; nextPutAll: ''','; newLine.
		s nextPutAll: '	#type : '''; nextPutAll: type; nextPutAll: ''','; newLine.
		s nextPutAll: '	#category : ''Tests-Tonel-Imported'','; newLine.
		s nextPutAll: '	#package : ''Tests'','; newLine.
		s nextPutAll: '	#tag : ''Tonel-Imported'''; newLine.
		s nextPutAll: '}'; newLine ]! !

!TonelImporterTest methodsFor: 'running' stamp: 'GC 4/Jun/2026 20:22:06'!
tearDown
	#(TonelRoundTripExample TonelOrderingChild TonelOrderingParent TonelBytesExample TonelWordsExample TonelWeakExample TonelVariableExample) do: [ :n |
		(Smalltalk classNamed: n) ifNotNil: [ :c | c removeFromSystemUnlogged ] ].
	super tearDown! !

!TonelImporterTest methodsFor: 'tests' stamp: 'GC 4/Jun/2026 20:53:46'!
testImportCreatesClassAndCompilesInstanceMethods
	| class instance |
	TonelImporter importStream: self sampleTonelSource readStream.
	class := Smalltalk classNamed: #TonelRoundTripExample.
	self deny: class isNil.
	self assert: class superclass equals: Object.
	self assert: class category equals: #'Tests-Tonel-Imported'.
	instance := class withValue: 7.
	self assert: instance value equals: 7! !

!TonelImporterTest methodsFor: 'tests' stamp: 'GC 4/Jun/2026 20:53:46'!
testImportDefinitionsImportsSubclassListedBeforeItsSuperclass
	"importDefinitions: must order definitions superclass-first, regardless of the
	 order given, so a subclass listed before its superclass is still imported."
	| parentDef childDef |
	parentDef := TonelReader readStream: self orderingParentSource readStream.
	childDef := TonelReader readStream: self orderingChildSource readStream.
	TonelImporter importDefinitions: { childDef. parentDef }.
	self deny: (Smalltalk classNamed: #TonelOrderingParent) isNil.
	self deny: (Smalltalk classNamed: #TonelOrderingChild) isNil.
	self assert: (Smalltalk classNamed: #TonelOrderingChild) superclass
	          equals: (Smalltalk classNamed: #TonelOrderingParent)! !

!TonelImporterTest methodsFor: 'tests' stamp: 'GC 4/Jun/2026 20:53:46'!
testReimportUpdatesExistingMethod
	| class source instance |
	TonelImporter importStream: self sampleTonelSource readStream.
	source := self sampleTonelSource copyReplaceAll: '^ value' with: '^ value + 1'.
	TonelImporter importStream: source readStream.
	class := Smalltalk classNamed: #TonelRoundTripExample.
	instance := class withValue: 7.
	self assert: instance value equals: 8! !

!TonelImporterTest methodsFor: 'tests - type' stamp: 'GC 4/Jun/2026 20:22:06'!
testImportCreatesBytesClassWithCorrectShape
	TonelImporter importDefinitions: { TonelReader readStream: (self shapeSourceNamed: 'TonelBytesExample' superclass: 'ArrayedCollection' type: 'bytes') readStream }.
	self assert: (Smalltalk classNamed: #TonelBytesExample) isBytes! !

!TonelImporterTest methodsFor: 'tests - type' stamp: 'GC 4/Jun/2026 20:22:11'!
testImportCreatesVariableClassWithCorrectShape
	| class |
	TonelImporter importDefinitions: { TonelReader readStream: (self shapeSourceNamed: 'TonelVariableExample' superclass: 'Object' type: 'variable') readStream }.
	class := Smalltalk classNamed: #TonelVariableExample.
	self assert: class isVariable.
	self deny: class isBytes! !

!TonelImporterTest methodsFor: 'tests - type' stamp: 'GC 4/Jun/2026 20:22:06'!
testImportCreatesWeakClassWithCorrectShape
	TonelImporter importDefinitions: { TonelReader readStream: (self shapeSourceNamed: 'TonelWeakExample' superclass: 'Array' type: 'weak') readStream }.
	self assert: (Smalltalk classNamed: #TonelWeakExample) isWeak! !

!TonelImporterTest methodsFor: 'tests - type' stamp: 'GC 4/Jun/2026 20:22:06'!
testImportCreatesWordsClassWithCorrectShape
	TonelImporter importDefinitions: { TonelReader readStream: (self shapeSourceNamed: 'TonelWordsExample' superclass: 'ArrayedCollection' type: 'words') readStream }.
	self assert: (Smalltalk classNamed: #TonelWordsExample) isWords! !

!TonelImporterTest methodsFor: 'tests - extension' stamp: 'GC 4/Jun/2026 20:24:17'!
testImportDefinitionsAppliesExtensionAfterItsTargetClass
	| extDef classDef |
	extDef := TonelReader readStream: TonelReaderTest new extensionSource readStream.
	classDef := TonelReader readStream: self sampleTonelSource readStream.
	TonelImporter importDefinitions: { extDef. classDef }.
	self assert: ((Smalltalk classNamed: #TonelRoundTripExample) canUnderstand: #extMethod)! !

!TonelImporterTest methodsFor: 'tests - extension' stamp: 'GC 4/Jun/2026 20:24:17'!
testImportExtensionCompilesMethodsOntoExistingClass
	| target |
	TonelImporter importStream: self sampleTonelSource readStream.
	target := Smalltalk classNamed: #TonelRoundTripExample.
	TonelImporter importDefinitions: { TonelReader readStream: TonelReaderTest new extensionSource readStream }.
	self assert: (target canUnderstand: #extMethod).
	self assert: (target class canUnderstand: #classExtMethod).
	self assert: (target organization categoryOfElement: #extMethod) equals: #'*ZzzPkg'! !

!TonelImporterTest methodsFor: 'tests - round trip' stamp: 'GC 4/Jun/2026 20:31:37'!
testRoundTripExportIsByteStable
	| first second |
	TonelImporter importStream: self sampleTonelSource readStream.
	first := TonelWriter sourceForClass: (Smalltalk classNamed: #TonelRoundTripExample).
	(Smalltalk classNamed: #TonelRoundTripExample) removeFromSystemUnlogged.
	TonelImporter importStream: first readStream.
	second := TonelWriter sourceForClass: (Smalltalk classNamed: #TonelRoundTripExample).
	self assert: first equals: second! !

!TonelReaderTest methodsFor: 'fixtures' stamp: 'GC 4/Jun/2026 20:21:07'!
bytesClassSource
	^ 'Class {
	#name : ''TonelBytesExample'',
	#superclass : ''ArrayedCollection'',
	#type : ''bytes'',
	#category : ''Tests-Tonel-Imported'',
	#package : ''Tests'',
	#tag : ''Tonel-Imported''
}
'! !

!TonelReaderTest methodsFor: 'fixtures' stamp: 'GC 4/Jun/2026 20:23:14'!
extensionSource
	^ 'Extension { #name : ''TonelRoundTripExample'' }

{ #category : ''*ZzzPkg'' }
TonelRoundTripExample >> extMethod [
	^ 42
]

{ #category : ''*ZzzPkg'' }
TonelRoundTripExample class >> classExtMethod [
	^ 43
]
'! !

!TonelReaderTest methodsFor: 'fixtures' stamp: 'GC 4/Jun/2026 20:53:46'!
sampleTonelSource
	^ '"
Imported comment.
"
Class {
	#name : ''TonelRoundTripExample'',
	#superclass : ''Object'',
	#instVars : [
		''value''
	],
	#classInstVars : [
		''classValue''
	],
	#category : ''Tests-Tonel-Imported'',
	#package : ''Tests'',
	#tag : ''Tonel-Imported''
}

{ #category : ''accessing'' }
TonelRoundTripExample >> value [
	^ value
]

{ #category : ''accessing'' }
TonelRoundTripExample >> value: anObject [
	value := anObject
]

{ #category : ''instance creation'' }
TonelRoundTripExample class >> withValue: anObject [
	^ self new value: anObject; yourself
]
'! !

!TonelReaderTest methodsFor: 'tests' stamp: 'GC 4/Jun/2026 20:53:46'!
testReadsClassMetadata
	| definition |
	definition := TonelReader readStream: self sampleTonelSource readStream.
	self assert: definition className equals: #TonelRoundTripExample.
	self assert: definition superclassName equals: #Object.
	self assert: definition instanceVariableNames equals: #('value').
	self assert: definition classInstanceVariableNames equals: #('classValue').
	self assert: definition category equals: #'Tests-Tonel-Imported'.
	self assert: definition package equals: #Tests.
	self assert: definition tag equals: #'Tonel-Imported'! !

!TonelReaderTest methodsFor: 'tests' stamp: 'GC 4/Jun/2026 20:53:46'!
testReadsMethodDefinitions
	| definition selectors |
	definition := TonelReader readStream: self sampleTonelSource readStream.
	selectors := definition methods collect: [ :method | method selector ].
	self assert: selectors asArray equals: #(value value: withValue:).
	self assert: definition methods first protocol equals: #accessing.
	self assert: definition methods first classSide not.
	self assert: definition methods third classSide! !

!TonelReaderTest methodsFor: 'tests' stamp: 'GC 4/Jun/2026 20:53:46'!
testReadsWriterOutput
	| definition |
	definition := TonelReader readStream: (TonelWriter sourceForClass: TonelReaderTest) readStream.
	self assert: definition className equals: #TonelReaderTest.
	self assert: (definition methods anySatisfy: [ :method | method selector = #sampleTonelSource ])! !

!TonelReaderTest methodsFor: 'tests - type' stamp: 'GC 4/Jun/2026 20:21:07'!
testReadsClassType
	| def |
	def := TonelReader readStream: self bytesClassSource readStream.
	self assert: def type equals: 'bytes'! !

!TonelReaderTest methodsFor: 'tests - type' stamp: 'GC 4/Jun/2026 20:21:07'!
testReadsNoTypeForFixedClassAsNil
	| def |
	def := TonelReader readStream: self sampleTonelSource readStream.
	self assert: def type isNil! !

!TonelReaderTest methodsFor: 'tests - extension' stamp: 'GC 4/Jun/2026 20:23:14'!
testReadsExtensionDefinition
	| def |
	def := TonelReader readStream: self extensionSource readStream.
	self assert: def isExtension.
	self assert: def className equals: #TonelRoundTripExample.
	self assert: def methods size equals: 2! !

!TonelReaderTest methodsFor: 'tests - extension' stamp: 'GC 4/Jun/2026 20:23:14'!
testReadsExtensionMethodSidesAndProtocol
	| def inst cls |
	def := TonelReader readStream: self extensionSource readStream.
	inst := def methods detect: [:m | m selector = #extMethod].
	cls := def methods detect: [:m | m selector = #classExtMethod].
	self deny: inst classSide.
	self assert: cls classSide.
	self assert: inst protocol equals: #'*ZzzPkg'! !

!TonelReaderTest methodsFor: 'tests - round trip' stamp: 'GC 4/Jun/2026 20:30:38'!
testParsedMethodSourceHasNoTrailingNewline
	| def |
	def := TonelReader readStream: self sampleTonelSource readStream.
	self assert: def methods notEmpty.
	def methods do: [:m |
		self deny: (m source notEmpty and: [m source last = Character lf])
			description: m selector printString, ' source has a trailing newline' ]! !

!TonelWriterTest methodsFor: 'assertions' stamp: 'GC 4/Jun/2026 20:53:46'!
assert: aString includes: expectedSubstring
	self
		assert: (aString includesSubString: expectedSubstring)
		description: [ 'Expected to find ', expectedSubstring printString, ' in ', aString printString ]! !

!TonelWriterTest methodsFor: 'tests' stamp: 'GC 4/Jun/2026 20:53:46'!
testClassDefinitionIncludesReconstructionMetadata
	| source |
	source := TonelWriter sourceForClass: TonelWriterTest.
	self assert: source includes: 'Class {'.
	self assert: source includes: '#name : ''TonelWriterTest'''.
	self assert: source includes: '#superclass : ''TestCase'''.
	self assert: source includes: '#category : ''Tests-Tonel'''.
	self assert: source includes: '#package : ''Tests'''.
	self assert: source includes: '#tag : ''Tonel'''! !

!TonelWriterTest methodsFor: 'tests' stamp: 'GC 4/Jun/2026 20:53:46'!
testClassDefinitionIncludesVariablesWhenPresent
	| source |
	source := TonelWriter sourceForClass: Editor.
	self assert: source includes: '#instVars : ['.
	self assert: source includes: '''morph'''.
	self assert: source includes: '#classInstVars : ['.
	self assert: source includes: '''keyboardActions'''! !

!TonelWriterTest methodsFor: 'tests' stamp: 'GC 4/Jun/2026 20:53:46'!
testClassMethodUsesClassSideDeclaration
	| source |
	source := TonelWriter sourceForClass: TonelWriterTest.
	self assert: source includes: '{ #category : ''testing'' }'.
	self assert: source includes: 'TonelWriterTest class >> isAbstract ['! !

!TonelWriterTest methodsFor: 'tests' stamp: 'GC 4/Jun/2026 20:53:46'!
testCommentIsWrittenBeforeClassDefinition
	| source |
	source := TonelWriter sourceForClass: Object.
	self assert: source includes: '"
Object is the root class'.
	self assert: source includes: '"
Class {'! !

!TonelWriterTest methodsFor: 'tests' stamp: 'GC 4/Jun/2026 20:53:46'!
testInstanceMethodIncludesCategoryDeclarationAndBody
	| source |
	source := TonelWriter sourceForClass: TonelWriterTest.
	self assert: source includes: '{ #category : ''assertions'' }'.
	self assert: source includes: 'TonelWriterTest >> assert: aString includes: expectedSubstring ['.
	self assert: source includes: 'includesSubString: expectedSubstring'! !

!TonelWriterTest methodsFor: 'tests - type' stamp: 'GC 4/Jun/2026 20:19:45'!
testTonelTypeOfShapes
	self assert: (TonelWriter tonelTypeOf: ByteArray) equals: 'bytes'.
	self assert: (TonelWriter tonelTypeOf: Bitmap) equals: 'words'.
	self assert: (TonelWriter tonelTypeOf: WeakArray) equals: 'weak'.
	self assert: (TonelWriter tonelTypeOf: Array) equals: 'variable'.
	self assert: (TonelWriter tonelTypeOf: Association) equals: nil! !

!TonelWriterTest methodsFor: 'tests - type' stamp: 'GC 4/Jun/2026 20:19:45'!
testWritesNoTypeForFixedClass
	| source |
	source := TonelWriter sourceForClass: Association.
	self deny: (source includesSubString: '#type :')! !

!TonelWriterTest methodsFor: 'tests - type' stamp: 'GC 4/Jun/2026 20:19:45'!
testWritesTypeForVariableByteClass
	| source |
	source := TonelWriter sourceForClass: ByteArray.
	self assert: (source includesSubString: '#type : ''bytes''')! !

!TonelWriterTest class methodsFor: 'testing' stamp: 'GC 4/Jun/2026 20:53:46'!
isAbstract
	^ false! !
