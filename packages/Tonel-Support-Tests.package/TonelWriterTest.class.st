" Tests for TonelWriter - serializes Cuis classes to Tonel format. "
Class {
	#name : 'TonelWriterTest',
	#superclass : 'TestCase',
	#instVars : [ 'stream' 'writer' ],
	#category : 'Tonel-Support-Tests'
}

{ #category : 'running' }
TonelWriterTest >> setUp [
	stream := WriteStream on: String new.
	writer := TonelWriter on: stream
]

{ #category : 'tests - zero' }
TonelWriterTest >> testWriteEmptyCommentIsSkipped [
	writer writeComment: ''.
	self assertEmpty: stream contents
]

{ #category : 'tests - zero' }
TonelWriterTest >> testWriteNilCommentIsSkipped [
	writer writeComment: nil.
	self assertEmpty: stream contents
]

{ #category : 'tests - one' }
TonelWriterTest >> testWriteCommentProducesQuotedString [
	writer writeComment: 'A simple class'.
	self assert: stream contents equals: '"A simple class"' , (String nl)
]

{ #category : 'tests - one' }
TonelWriterTest >> testWriteClassDefinitionIncludesName [
	writer writeClassDefinition: TonelWriterTest.
	self assert: (stream contents includesSubString: '#name : ''TonelWriterTest''')
]

{ #category : 'tests - one' }
TonelWriterTest >> testWriteClassDefinitionIncludesSuperclass [
	writer writeClassDefinition: TonelWriterTest.
	self assert: (stream contents includesSubString: '#superclass : ''TestCase''')
]

{ #category : 'tests - one' }
TonelWriterTest >> testWriteClassDefinitionIncludesCategory [
	writer writeClassDefinition: TonelWriterTest.
	self assert: (stream contents includesSubString: '#category : ''Tonel-Support-Tests''')
]

{ #category : 'tests - many' }
TonelWriterTest >> testWriteClassWithInstVarsIncludesThem [
	" TonelWriterTest has instVars stream and writer "
	writer writeClassDefinition: TonelWriterTest.
	self assert: (stream contents includesSubString: '#instVars').
	self assert: (stream contents includesSubString: 'stream').
	self assert: (stream contents includesSubString: 'writer')
]

{ #category : 'tests - boundaries' }
TonelWriterTest >> testWriteClassWithNoInstVarsOmitsInstVarsLine [
	" Object has no instVars "
	writer writeClassDefinition: Object.
	self deny: (stream contents includesSubString: '#instVars')
]

{ #category : 'tests - interface' }
TonelWriterTest >> testWriteClassReturnsNonEmptyString [
	| result |
	result := TonelWriter writeClass: TonelWriterTest.
	self assert: result notEmpty
]

{ #category : 'tests - interface' }
TonelWriterTest >> testWriteClassResultStartsWithClassKeyword [
	| result |
	result := TonelWriter writeClass: Object.
	self assert: (result includesSubString: 'Class {')
]

{ #category : 'tests - interface' }
TonelWriterTest >> testRoundTripProducesTonelFormat [
	" The output should be valid Tonel: has Class {, #name, #superclass "
	| result |
	result := TonelWriter writeClass: TonelWriterTest.
	self assert: (result includesSubString: 'Class {').
	self assert: (result includesSubString: '#name').
	self assert: (result includesSubString: '#superclass')
]
