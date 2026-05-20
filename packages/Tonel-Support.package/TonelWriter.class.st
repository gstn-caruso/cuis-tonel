" Serializes a Cuis CodePackage to Tonel format (one .st file per class or extension). "
Class {
	#name : 'TonelWriter',
	#superclass : 'Object',
	#instVars : [ 'stream' ],
	#category : 'Tonel-Support'
}

{ #category : 'accessing' }
TonelWriter >> stream [
	^ stream
]

{ #category : 'accessing' }
TonelWriter >> stream: aStream [
	stream := aStream
]

{ #category : 'writing' }
TonelWriter >> writeClass: aClass [
	" Write a complete class definition to stream in Tonel format. "
	self writeComment: aClass comment.
	self writeClassDefinition: aClass.
	self writeMethodsOf: aClass
]

{ #category : 'writing - private' }
TonelWriter >> writeComment: aString [
	aString isNil ifTrue: [ ^ self ].
	aString isEmpty ifTrue: [ ^ self ].
	stream
		nextPutAll: '"';
		nextPutAll: aString;
		nextPutAll: '"';
		nl
]

{ #category : 'writing - private' }
TonelWriter >> writeClassDefinition: aClass [
	stream
		nextPutAll: 'Class {';
		nl;
		nextPutAll: '	#name : ''';
		nextPutAll: aClass name;
		nextPutAll: ''',';
		nl;
		nextPutAll: '	#superclass : ''';
		nextPutAll: aClass superclass name;
		nextPutAll: ''',';
		nl.
	aClass instVarNames isEmpty ifFalse: [
		stream nextPutAll: '	#instVars : [ '.
		aClass instVarNames do: [:v | stream nextPutAll: ''''; nextPutAll: v; nextPutAll: ''' '].
		stream nextPutAll: '],'; nl.
	].
	stream
		nextPutAll: '	#category : ''';
		nextPutAll: aClass category;
		nextPutAll: '''';
		nl;
		nextPutAll: '}';
		nl
]

{ #category : 'writing - private' }
TonelWriter >> writeMethodsOf: aClass [
	aClass methodDictionary do: [:m | self writeMethod: m ofClass: aClass]
]

{ #category : 'writing - private' }
TonelWriter >> writeMethod: aMethod ofClass: aClass [
	stream nl.
	stream
		nextPutAll: '{ #category : ''';
		nextPutAll: aMethod category;
		nextPutAll: ''' }';
		nl.
	stream
		nextPutAll: aClass name;
		nextPutAll: ' >> ';
		nextPutAll: aMethod selector;
		nextPutAll: ' [';
		nl.
	stream
		nextPutAll: aMethod sourceCode;
		nl;
		nextPutAll: ']';
		nl
]

{ #category : 'instance creation' }
TonelWriter class >> on: aStream [
	^ self new stream: aStream; yourself
]

{ #category : 'instance creation' }
TonelWriter class >> writeClass: aClass [
	" Convenience. Returns the Tonel string for a class. "
	| s |
	s := WriteStream on: String new.
	(self on: s) writeClass: aClass.
	^ s contents
]
