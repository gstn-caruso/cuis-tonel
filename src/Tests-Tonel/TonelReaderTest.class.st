Class {
	#name : 'TonelReaderTest',
	#superclass : 'TestCase',
	#category : 'Tests-Tonel',
	#package : 'Tests',
	#tag : 'Tonel'
}

{ #category : 'fixtures' }
TonelReaderTest >> bytesClassSource [
	^ 'Class {
	#name : ''TonelBytesExample'',
	#superclass : ''ArrayedCollection'',
	#type : ''bytes'',
	#category : ''Tests-Tonel-Imported'',
	#package : ''Tests'',
	#tag : ''Tonel-Imported''
}
'
]

{ #category : 'fixtures' }
TonelReaderTest >> extensionSource [
	^ 'Extension { #name : ''TonelRoundTripExample'' }

{ #category : ''*ZzzPkg'' }
TonelRoundTripExample >> extMethod [
	^ 42
]

{ #category : ''*ZzzPkg'' }
TonelRoundTripExample class >> classExtMethod [
	^ 43
]
'
]

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

{ #category : 'tests - round trip' }
TonelReaderTest >> testParsedMethodSourceHasNoTrailingNewline [
	| def |
	def := TonelReader readStream: self sampleTonelSource readStream.
	self assert: def methods notEmpty.
	def methods do: [:m |
		self deny: (m source notEmpty and: [m source last = Character lf])
			description: m selector printString, ' source has a trailing newline' ]
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

{ #category : 'tests - type' }
TonelReaderTest >> testReadsClassType [
	| def |
	def := TonelReader readStream: self bytesClassSource readStream.
	self assert: def type equals: 'bytes'
]

{ #category : 'tests - extension' }
TonelReaderTest >> testReadsExtensionDefinition [
	| def |
	def := TonelReader readStream: self extensionSource readStream.
	self assert: def isExtension.
	self assert: def className equals: #TonelRoundTripExample.
	self assert: def methods size equals: 2
]

{ #category : 'tests - extension' }
TonelReaderTest >> testReadsExtensionMethodSidesAndProtocol [
	| def inst cls |
	def := TonelReader readStream: self extensionSource readStream.
	inst := def methods detect: [:m | m selector = #extMethod].
	cls := def methods detect: [:m | m selector = #classExtMethod].
	self deny: inst classSide.
	self assert: cls classSide.
	self assert: inst protocol equals: #'*ZzzPkg'
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

{ #category : 'tests - type' }
TonelReaderTest >> testReadsNoTypeForFixedClassAsNil [
	| def |
	def := TonelReader readStream: self sampleTonelSource readStream.
	self assert: def type isNil
]

{ #category : 'tests' }
TonelReaderTest >> testReadsWriterOutput [
	| definition |
	definition := TonelReader readStream: (TonelWriter sourceForClass: TonelReaderTest) readStream.
	self assert: definition className equals: #TonelReaderTest.
	self assert: (definition methods anySatisfy: [ :method | method selector = #sampleTonelSource ])
]
