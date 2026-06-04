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

{ #category : 'running' }
TonelImporterTest >> tearDown [
	#(TonelRoundTripExample TonelOrderingChild TonelOrderingParent) do: [ :n |
		(Smalltalk classNamed: n) ifNotNil: [ :c | c removeFromSystemUnlogged ] ].
	super tearDown

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
