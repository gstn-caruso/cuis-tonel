Class {
	#name : 'TonelWriterTest',
	#superclass : 'TestCase',
	#category : 'Tests-Tonel',
	#package : 'Tests',
	#tag : 'Tonel'
}

{ #category : 'testing' }
TonelWriterTest class >> isAbstract [
	^ false
]

{ #category : 'assertions' }
TonelWriterTest >> assert: aString includes: expectedSubstring [
	self
		assert: (aString includesSubString: expectedSubstring)
		description: [ 'Expected to find ', expectedSubstring printString, ' in ', aString printString ]
]

{ #category : 'tests' }
TonelWriterTest >> testClassDefinitionIncludesReconstructionMetadata [
	| source |
	source := TonelWriter sourceForClass: TonelWriterTest.
	self assert: source includes: 'Class {'.
	self assert: source includes: '#name : ''TonelWriterTest'''.
	self assert: source includes: '#superclass : ''TestCase'''.
	self assert: source includes: '#category : ''Tests-Tonel'''.
	self assert: source includes: '#package : ''Tests'''.
	self assert: source includes: '#tag : ''Tonel'''
]

{ #category : 'tests' }
TonelWriterTest >> testClassDefinitionIncludesVariablesWhenPresent [
	| source |
	source := TonelWriter sourceForClass: Editor.
	self assert: source includes: '#instVars : ['.
	self assert: source includes: '''morph'''.
	self assert: source includes: '#classInstVars : ['.
	self assert: source includes: '''keyboardActions'''
]

{ #category : 'tests' }
TonelWriterTest >> testClassMethodUsesClassSideDeclaration [
	| source |
	source := TonelWriter sourceForClass: TonelWriterTest.
	self assert: source includes: '{ #category : ''testing'' }'.
	self assert: source includes: 'TonelWriterTest class >> isAbstract ['
]

{ #category : 'tests' }
TonelWriterTest >> testCommentIsWrittenBeforeClassDefinition [
	| source |
	source := TonelWriter sourceForClass: Object.
	self assert: source includes: '"
Object is the root class'.
	self assert: source includes: '"
Class {'
]

{ #category : 'tests' }
TonelWriterTest >> testInstanceMethodIncludesCategoryDeclarationAndBody [
	| source |
	source := TonelWriter sourceForClass: TonelWriterTest.
	self assert: source includes: '{ #category : ''assertions'' }'.
	self assert: source includes: 'TonelWriterTest >> assert: aString includes: expectedSubstring ['.
	self assert: source includes: 'includesSubString: expectedSubstring'
]
