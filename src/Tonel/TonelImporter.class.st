Class {
	#name : 'TonelImporter',
	#superclass : 'Object',
	#category : 'Tonel',
	#package : 'Tonel'
}

{ #category : 'importing' }
TonelImporter class >> definitionsIn: aDirectoryEntry [
	"Recursively read every Tonel definition (.st) under the directory."
	| definitions |
	definitions := OrderedCollection new.
	aDirectoryEntry children do: [ :entry |
		entry isDirectoryEntry
			ifTrue: [ definitions addAll: (self definitionsIn: entry) ]
			ifFalse: [ (entry name endsWith: '.st') ifTrue: [
				definitions add: (entry readStreamDo: [ :stream | TonelReader readStream: stream ]) ] ] ].
	^ definitions

]

{ #category : 'importing' }
TonelImporter class >> importDefinition: definition [
	| superClassToUse targetClass |
	targetClass := Smalltalk classNamed: definition className.
	targetClass ifNil: [
		superClassToUse := Smalltalk classNamed: definition superclassName.
		superClassToUse ifNil: [ self error: 'Missing superclass ', definition superclassName ].
		targetClass := superClassToUse
			subclass: definition className
			instanceVariableNames: (self namesStringFrom: definition instanceVariableNames)
			classVariableNames: (self namesStringFrom: definition classVariableNames)
			poolDictionaries: (self namesStringFrom: definition poolDictionaries)
			category: definition category.
		definition classInstanceVariableNames isEmpty ifFalse: [
			ClassBuilder new class: targetClass class instanceVariableNames: (self namesStringFrom: definition classInstanceVariableNames) ] ].
	definition comment isEmptyOrNil ifFalse: [
		targetClass classComment: definition comment stamp: '<tonel>' ].
	definition methods do: [ :method |
		(method classSide ifTrue: [ targetClass class ] ifFalse: [ targetClass ])
			compile: method source
			classified: method protocol ].
	^ targetClass
]

{ #category : 'importing' }
TonelImporter class >> importDefinitions: aCollectionOfDefinitions [
	"Import the definitions superclass-first: repeatedly import any whose class already
	 exists or whose superclass is already defined, until none remain. This lets a subclass
	 be listed (or filed) before its superclass without failing on a missing superclass."
	| pending progressed |
	pending := aCollectionOfDefinitions asOrderedCollection.
	[ pending isEmpty ] whileFalse: [
		progressed := false.
		pending copy do: [ :definition |
			((Smalltalk classNamed: definition className) notNil
				or: [ (Smalltalk classNamed: definition superclassName) notNil ]) ifTrue: [
					self importDefinition: definition.
					pending remove: definition.
					progressed := true ] ].
		progressed ifFalse: [
			self error: 'Missing superclass for: ',
				(pending collect: [ :each | each className ]) asArray printString ] ]

]

{ #category : 'importing' }
TonelImporter class >> importDirectory: aDirectoryEntry [
	self importDefinitions: (self definitionsIn: aDirectoryEntry)

]

{ #category : 'importing' }
TonelImporter class >> importFile: aFileEntry [
	aFileEntry readStreamDo: [ :stream | ^ self importStream: stream ]
]

{ #category : 'importing' }
TonelImporter class >> importStream: aStream [
	^ self importDefinition: (TonelReader readStream: aStream)
]

{ #category : 'importing' }
TonelImporter class >> namesStringFrom: aCollection [
	^ String streamContents: [ :stream |
		aCollection do: [ :each |
			stream nextPutAll: each asString.
			each == aCollection last ifFalse: [ stream space ] ] ]
]
