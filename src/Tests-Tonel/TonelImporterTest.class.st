Class {
	#name : 'TonelImporterTest',
	#superclass : 'TestCase',
	#category : 'Tests-Tonel',
	#package : 'Tests',
	#tag : 'Tonel'
}

{ #category : 'fixtures' }
TonelImporterTest >> orderingChildSource [
	^ 'Class {
	#name : ''TonelOrderingChild'',
	#superclass : ''TonelOrderingParent'',
	#category : ''Tests-Tonel-Imported'',
	#package : ''Tests'',
	#tag : ''Tonel-Imported''
}
'
]

{ #category : 'fixtures' }
TonelImporterTest >> orderingParentSource [
	^ 'Class {
	#name : ''TonelOrderingParent'',
	#superclass : ''Object'',
	#category : ''Tests-Tonel-Imported'',
	#package : ''Tests'',
	#tag : ''Tonel-Imported''
}
'
]

{ #category : 'fixtures' }
TonelImporterTest >> sampleTonelSource [
	^ TonelReaderTest new sampleTonelSource
]

{ #category : 'fixtures' }
TonelImporterTest >> shapeSourceNamed: name superclass: sup type: type [
	^ String streamContents: [:s |
		s nextPutAll: 'Class {'; newLine.
		s nextPutAll: '	#name : '''; nextPutAll: name; nextPutAll: ''','; newLine.
		s nextPutAll: '	#superclass : '''; nextPutAll: sup; nextPutAll: ''','; newLine.
		s nextPutAll: '	#type : '''; nextPutAll: type; nextPutAll: ''','; newLine.
		s nextPutAll: '	#category : ''Tests-Tonel-Imported'','; newLine.
		s nextPutAll: '	#package : ''Tests'','; newLine.
		s nextPutAll: '	#tag : ''Tonel-Imported'''; newLine.
		s nextPutAll: '}'; newLine ]
]

{ #category : 'running' }
TonelImporterTest >> tearDown [
	#(TonelRoundTripExample TonelOrderingChild TonelOrderingParent TonelBytesExample TonelWordsExample TonelWeakExample TonelVariableExample) do: [ :n |
		(Smalltalk classNamed: n) ifNotNil: [ :c | c removeFromSystemUnlogged ] ].
	super tearDown
]

{ #category : 'tests - type' }
TonelImporterTest >> testImportCreatesBytesClassWithCorrectShape [
	TonelImporter importDefinitions: { TonelReader readStream: (self shapeSourceNamed: 'TonelBytesExample' superclass: 'ArrayedCollection' type: 'bytes') readStream }.
	self assert: (Smalltalk classNamed: #TonelBytesExample) isBytes
]

{ #category : 'tests' }
TonelImporterTest >> testImportCreatesClassAndCompilesInstanceMethods [
	| class instance |
	TonelImporter importStream: self sampleTonelSource readStream.
	class := Smalltalk classNamed: #TonelRoundTripExample.
	self deny: class isNil.
	self assert: class superclass equals: Object.
	self assert: class category equals: #'Tests-Tonel-Imported'.
	instance := class withValue: 7.
	self assert: instance value equals: 7
]

{ #category : 'tests - type' }
TonelImporterTest >> testImportCreatesVariableClassWithCorrectShape [
	| class |
	TonelImporter importDefinitions: { TonelReader readStream: (self shapeSourceNamed: 'TonelVariableExample' superclass: 'Object' type: 'variable') readStream }.
	class := Smalltalk classNamed: #TonelVariableExample.
	self assert: class isVariable.
	self deny: class isBytes
]

{ #category : 'tests - type' }
TonelImporterTest >> testImportCreatesWeakClassWithCorrectShape [
	TonelImporter importDefinitions: { TonelReader readStream: (self shapeSourceNamed: 'TonelWeakExample' superclass: 'Array' type: 'weak') readStream }.
	self assert: (Smalltalk classNamed: #TonelWeakExample) isWeak
]

{ #category : 'tests - type' }
TonelImporterTest >> testImportCreatesWordsClassWithCorrectShape [
	TonelImporter importDefinitions: { TonelReader readStream: (self shapeSourceNamed: 'TonelWordsExample' superclass: 'ArrayedCollection' type: 'words') readStream }.
	self assert: (Smalltalk classNamed: #TonelWordsExample) isWords
]

{ #category : 'tests - extension' }
TonelImporterTest >> testImportDefinitionsAppliesExtensionAfterItsTargetClass [
	| extDef classDef |
	extDef := TonelReader readStream: TonelReaderTest new extensionSource readStream.
	classDef := TonelReader readStream: self sampleTonelSource readStream.
	TonelImporter importDefinitions: { extDef. classDef }.
	self assert: ((Smalltalk classNamed: #TonelRoundTripExample) canUnderstand: #extMethod)
]

{ #category : 'tests' }
TonelImporterTest >> testImportDefinitionsImportsSubclassListedBeforeItsSuperclass [
	"importDefinitions: must order definitions superclass-first, regardless of the
	 order given, so a subclass listed before its superclass is still imported."
	| parentDef childDef |
	parentDef := TonelReader readStream: self orderingParentSource readStream.
	childDef := TonelReader readStream: self orderingChildSource readStream.
	TonelImporter importDefinitions: { childDef. parentDef }.
	self deny: (Smalltalk classNamed: #TonelOrderingParent) isNil.
	self deny: (Smalltalk classNamed: #TonelOrderingChild) isNil.
	self assert: (Smalltalk classNamed: #TonelOrderingChild) superclass
	          equals: (Smalltalk classNamed: #TonelOrderingParent)
]

{ #category : 'tests - extension' }
TonelImporterTest >> testImportExtensionCompilesMethodsOntoExistingClass [
	| target |
	TonelImporter importStream: self sampleTonelSource readStream.
	target := Smalltalk classNamed: #TonelRoundTripExample.
	TonelImporter importDefinitions: { TonelReader readStream: TonelReaderTest new extensionSource readStream }.
	self assert: (target canUnderstand: #extMethod).
	self assert: (target class canUnderstand: #classExtMethod).
	self assert: (target organization categoryOfElement: #extMethod) equals: #'*ZzzPkg'
]

{ #category : 'tests' }
TonelImporterTest >> testReimportUpdatesExistingMethod [
	| class source instance |
	TonelImporter importStream: self sampleTonelSource readStream.
	source := self sampleTonelSource copyReplaceAll: '^ value' with: '^ value + 1'.
	TonelImporter importStream: source readStream.
	class := Smalltalk classNamed: #TonelRoundTripExample.
	instance := class withValue: 7.
	self assert: instance value equals: 8
]

{ #category : 'tests - round trip' }
TonelImporterTest >> testRoundTripExportIsByteStable [
	| first second |
	TonelImporter importStream: self sampleTonelSource readStream.
	first := TonelWriter sourceForClass: (Smalltalk classNamed: #TonelRoundTripExample).
	(Smalltalk classNamed: #TonelRoundTripExample) removeFromSystemUnlogged.
	TonelImporter importStream: first readStream.
	second := TonelWriter sourceForClass: (Smalltalk classNamed: #TonelRoundTripExample).
	self assert: first equals: second
]
