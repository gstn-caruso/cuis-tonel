Class {
	#name : 'TonelReaderTest',
	#superclass : 'TestCase',
	#category : 'Tests-Tonel',
	#package : 'Tests',
	#tag : 'Tonel'
}

{ #category : 'fixtures' }
TonelReaderTest >> sampleTonelSource [
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
'
]

{ #category : 'tests' }
TonelReaderTest >> testReadsClassMetadata [
	| definition |
	definition := TonelReader readStream: self sampleTonelSource readStream.
	self assert: definition className equals: #TonelRoundTripExample.
	self assert: definition superclassName equals: #Object.
	self assert: definition instanceVariableNames equals: #('value').
	self assert: definition classInstanceVariableNames equals: #('classValue').
	self assert: definition category equals: #'Tests-Tonel-Imported'.
	self assert: definition package equals: #Tests.
	self assert: definition tag equals: #'Tonel-Imported'
]

{ #category : 'tests' }
TonelReaderTest >> testReadsMethodDefinitions [
	| definition selectors |
	definition := TonelReader readStream: self sampleTonelSource readStream.
	selectors := definition methods collect: [ :method | method selector ].
	self assert: selectors asArray equals: #(value value: withValue:).
	self assert: definition methods first protocol equals: #accessing.
	self assert: definition methods first classSide not.
	self assert: definition methods third classSide
]

{ #category : 'tests' }
TonelReaderTest >> testReadsWriterOutput [
	| definition |
	definition := TonelReader readStream: (TonelWriter sourceForClass: TonelReaderTest) readStream.
	self assert: definition className equals: #TonelReaderTest.
	self assert: (definition methods anySatisfy: [ :method | method selector = #sampleTonelSource ])
]
