Class {
	#name : 'TonelImporter',
	#superclass : 'Object',
	#category : 'Tonel',
	#package : 'Tonel'
}

{ #category : 'importing' }
TonelImporter class >> creationSelectorFor: definition [
	"The class-creation selector matching the definition's storage shape."
	definition type = 'variable' ifTrue: [ ^ #variableSubclass:instanceVariableNames:classVariableNames:poolDictionaries:category: ].
	definition type = 'bytes' ifTrue: [ ^ #variableByteSubclass:instanceVariableNames:classVariableNames:poolDictionaries:category: ].
	definition type = 'words' ifTrue: [ ^ #variableWordSubclass:instanceVariableNames:classVariableNames:poolDictionaries:category: ].
	definition type = 'weak' ifTrue: [ ^ #weakSubclass:instanceVariableNames:classVariableNames:poolDictionaries:category: ].
	^ #subclass:instanceVariableNames:classVariableNames:poolDictionaries:category:
]

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
	definition isExtension ifTrue: [ ^ self importExtension: definition ].
	targetClass := Smalltalk classNamed: definition className.
	targetClass ifNil: [
		superClassToUse := Smalltalk classNamed: definition superclassName.
		superClassToUse ifNil: [ self error: 'Missing superclass ', definition superclassName ].
		targetClass := superClassToUse
			perform: (self creationSelectorFor: definition)
			withArguments: {
				definition className.
				self namesStringFrom: definition instanceVariableNames.
				self namesStringFrom: definition classVariableNames.
				self namesStringFrom: definition poolDictionaries.
				definition category }.
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
	"Import definitions dependency-first: repeatedly import any whose dependency is already
	 satisfied (class exists, or superclass exists, or extension target exists), until none
	 remain. Lets a subclass or extension be filed before the class it depends on."
	| pending progressed |
	pending := aCollectionOfDefinitions asOrderedCollection.
	[ pending isEmpty ] whileFalse: [
		progressed := false.
		pending copy do: [ :definition |
			(self isReady: definition) ifTrue: [
				self importDefinition: definition.
				pending remove: definition.
				progressed := true ] ].
		progressed ifFalse: [
			self error: 'Cannot resolve dependencies for: ',
				(pending collect: [ :each | each className ]) asArray printString ] ]
]

{ #category : 'importing' }
TonelImporter class >> importDirectory: aDirectoryEntry [
	self importDefinitions: (self definitionsIn: aDirectoryEntry)
]

{ #category : 'importing' }
TonelImporter class >> importExtension: definition [
	"Compile the extension's methods onto the already-existing target class."
	| targetClass |
	targetClass := Smalltalk classNamed: definition className.
	targetClass ifNil: [ ^ self error: 'Missing class for extension: ', definition className ].
	definition methods do: [ :method |
		(method classSide ifTrue: [ targetClass class ] ifFalse: [ targetClass ])
			compile: method source
			classified: method protocol ].
	^ targetClass
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
TonelImporter class >> isReady: definition [
	"A definition can be imported once its dependency exists: for an extension, the target
	 class; for a class, the class itself (re-import) or its superclass."
	definition isExtension ifTrue: [ ^ (Smalltalk classNamed: definition className) notNil ].
	^ (Smalltalk classNamed: definition className) notNil
		or: [ (Smalltalk classNamed: definition superclassName) notNil ]
]

{ #category : 'importing' }
TonelImporter class >> namesStringFrom: aCollection [
	^ String streamContents: [ :stream |
		aCollection do: [ :each |
			stream nextPutAll: each asString.
			each == aCollection last ifFalse: [ stream space ] ] ]
]
