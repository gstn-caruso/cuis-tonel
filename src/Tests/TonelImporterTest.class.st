Class {
	#name : 'TonelImporterTest',
	#superclass : 'TestCase',
	#category : 'Tests-Tonel',
	#package : 'Tests',
	#tag : 'Tonel'
}

{ #category : 'fixtures' }
TonelImporterTest >> sampleTonelSource [
	^ TonelReaderTest new sampleTonelSource
]

{ #category : 'running' }
TonelImporterTest >> tearDown [
	(Smalltalk classNamed: #TonelRoundTripExample) ifNotNil: [ :class |
		class removeFromSystemUnlogged ].
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
TonelImporterTest >> testReimportUpdatesExistingMethod [
	| class source instance |
	TonelImporter importStream: self sampleTonelSource readStream.
	source := self sampleTonelSource copyReplaceAll: '^ value' with: '^ value + 1'.
	TonelImporter importStream: source readStream.
	class := Smalltalk classNamed: #TonelRoundTripExample.
	instance := class withValue: 7.
	self assert: instance value equals: 8
]
