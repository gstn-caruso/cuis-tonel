'From Cuis7.7 [latest update: #7965] on 4 June 2026 at 8:53:52 pm'!
'Description Cuis-native Tonel export/import support based on the Tonel v3 source format.'!
!provides: 'Tonel' 1 4!
!requires: 'Cuis-Base' 60 5557 nil!
SystemOrganization addCategory: #Tonel!


!classDefinition: #TonelClassDefinition category: #Tonel!
Object subclass: #TonelClassDefinition
	instanceVariableNames: 'comment className superclassName instanceVariableNames classVariableNames poolDictionaries classInstanceVariableNames category package tag methods type isExtension'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Tonel'!
!classDefinition: 'TonelClassDefinition class' category: #Tonel!
TonelClassDefinition class
	instanceVariableNames: ''!

!classDefinition: #TonelImageExporter category: #Tonel!
Object subclass: #TonelImageExporter
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Tonel'!
!classDefinition: 'TonelImageExporter class' category: #Tonel!
TonelImageExporter class
	instanceVariableNames: ''!

!classDefinition: #TonelImporter category: #Tonel!
Object subclass: #TonelImporter
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Tonel'!
!classDefinition: 'TonelImporter class' category: #Tonel!
TonelImporter class
	instanceVariableNames: ''!

!classDefinition: #TonelMethodDefinition category: #Tonel!
Object subclass: #TonelMethodDefinition
	instanceVariableNames: 'className selector protocol classSide source'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Tonel'!
!classDefinition: 'TonelMethodDefinition class' category: #Tonel!
TonelMethodDefinition class
	instanceVariableNames: ''!

!classDefinition: #TonelReader category: #Tonel!
Object subclass: #TonelReader
	instanceVariableNames: 'stream currentLine'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Tonel'!
!classDefinition: 'TonelReader class' category: #Tonel!
TonelReader class
	instanceVariableNames: ''!

!classDefinition: #TonelWriter category: #Tonel!
Object subclass: #TonelWriter
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Tonel'!
!classDefinition: 'TonelWriter class' category: #Tonel!
TonelWriter class
	instanceVariableNames: ''!


!TonelClassDefinition methodsFor: 'accessing' stamp: 'GC 4/Jun/2026 20:53:45'!
category
	^ category! !

!TonelClassDefinition methodsFor: 'accessing' stamp: 'GC 4/Jun/2026 20:53:46'!
category: aSymbol
	category := aSymbol! !

!TonelClassDefinition methodsFor: 'accessing' stamp: 'GC 4/Jun/2026 20:53:46'!
classInstanceVariableNames
	^ classInstanceVariableNames ifNil: [ #() ]! !

!TonelClassDefinition methodsFor: 'accessing' stamp: 'GC 4/Jun/2026 20:53:46'!
classInstanceVariableNames: aCollection
	classInstanceVariableNames := aCollection asArray! !

!TonelClassDefinition methodsFor: 'accessing' stamp: 'GC 4/Jun/2026 20:53:46'!
className
	^ className! !

!TonelClassDefinition methodsFor: 'accessing' stamp: 'GC 4/Jun/2026 20:53:46'!
className: aSymbol
	className := aSymbol! !

!TonelClassDefinition methodsFor: 'accessing' stamp: 'GC 4/Jun/2026 20:53:45'!
classVariableNames
	^ classVariableNames ifNil: [ #() ]! !

!TonelClassDefinition methodsFor: 'accessing' stamp: 'GC 4/Jun/2026 20:53:46'!
classVariableNames: aCollection
	classVariableNames := aCollection asArray! !

!TonelClassDefinition methodsFor: 'accessing' stamp: 'GC 4/Jun/2026 20:53:45'!
comment
	^ comment ifNil: [ '' ]! !

!TonelClassDefinition methodsFor: 'accessing' stamp: 'GC 4/Jun/2026 20:53:46'!
comment: aString
	comment := aString! !

!TonelClassDefinition methodsFor: 'accessing' stamp: 'GC 4/Jun/2026 20:53:45'!
instanceVariableNames
	^ instanceVariableNames ifNil: [ #() ]! !

!TonelClassDefinition methodsFor: 'accessing' stamp: 'GC 4/Jun/2026 20:53:46'!
instanceVariableNames: aCollection
	instanceVariableNames := aCollection asArray! !

!TonelClassDefinition methodsFor: 'accessing' stamp: 'GC 4/Jun/2026 20:23:06'!
isExtension
	^ isExtension == true! !

!TonelClassDefinition methodsFor: 'accessing' stamp: 'GC 4/Jun/2026 20:23:06'!
isExtension: aBoolean
	isExtension := aBoolean! !

!TonelClassDefinition methodsFor: 'accessing' stamp: 'GC 4/Jun/2026 20:53:45'!
methods
	^ methods ifNil: [ methods := OrderedCollection new ]! !

!TonelClassDefinition methodsFor: 'accessing' stamp: 'GC 4/Jun/2026 20:53:46'!
package
	^ package! !

!TonelClassDefinition methodsFor: 'accessing' stamp: 'GC 4/Jun/2026 20:53:46'!
package: aSymbol
	package := aSymbol! !

!TonelClassDefinition methodsFor: 'accessing' stamp: 'GC 4/Jun/2026 20:53:45'!
poolDictionaries
	^ poolDictionaries ifNil: [ #() ]! !

!TonelClassDefinition methodsFor: 'accessing' stamp: 'GC 4/Jun/2026 20:53:46'!
poolDictionaries: aCollection
	poolDictionaries := aCollection asArray! !

!TonelClassDefinition methodsFor: 'accessing' stamp: 'GC 4/Jun/2026 20:53:45'!
superclassName
	^ superclassName! !

!TonelClassDefinition methodsFor: 'accessing' stamp: 'GC 4/Jun/2026 20:53:46'!
superclassName: aSymbol
	superclassName := aSymbol! !

!TonelClassDefinition methodsFor: 'accessing' stamp: 'GC 4/Jun/2026 20:53:45'!
tag
	^ tag! !

!TonelClassDefinition methodsFor: 'accessing' stamp: 'GC 4/Jun/2026 20:53:46'!
tag: aSymbol
	tag := aSymbol! !

!TonelClassDefinition methodsFor: 'accessing' stamp: 'GC 4/Jun/2026 20:20:55'!
type
	^ type! !

!TonelClassDefinition methodsFor: 'accessing' stamp: 'GC 4/Jun/2026 20:20:55'!
type: aString
	type := aString! !

!TonelImageExporter class methodsFor: 'exporting' stamp: 'GC 4/Jun/2026 20:53:46'!
collectExtensionsOf: aClass into: extensions knownPackages: knownPackages
	self collectExtensionsOn: aClass class classSide: true className: aClass name asString into: extensions knownPackages: knownPackages.
	self collectExtensionsOn: aClass classSide: false className: aClass name asString into: extensions knownPackages: knownPackages! !

!TonelImageExporter class methodsFor: 'exporting' stamp: 'GC 4/Jun/2026 20:53:46'!
collectExtensionsOn: aClassOrMetaclass classSide: classSide className: className into: extensions knownPackages: knownPackages
	aClassOrMetaclass selectors do: [ :selector |
		| cat |
		cat := (TonelWriter methodCategoryOf: selector in: aClassOrMetaclass) asString.
		(TonelWriter isExtensionCategory: cat) ifTrue: [
			| targetPkg |
			targetPkg := self packageForCategory: (cat copyFrom: 2 to: cat size) knownPackages: knownPackages.
			((extensions at: targetPkg ifAbsentPut: [ Dictionary new ])
				at: className ifAbsentPut: [ OrderedCollection new ])
				add: { aClassOrMetaclass. classSide. selector } ] ]! !

!TonelImageExporter class methodsFor: 'exporting' stamp: 'GC 4/Jun/2026 20:53:46'!
exportAllTo: aDirectoryEntry
	^ self exportClasses: (Smalltalk allClasses asArray sort: [ :left :right | left name < right name ]) to: aDirectoryEntry! !

!TonelImageExporter class methodsFor: 'exporting' stamp: 'GC 4/Jun/2026 20:53:46'!
exportClasses: classes to: aDirectoryEntry
	| outputRoot srcRoot classCount methodCount packages knownPackages extensions |
	outputRoot := aDirectoryEntry assureExistence.
	srcRoot := (outputRoot / 'src') assureExistence.
	self writePropertiesIn: srcRoot.
	knownPackages := self knownPackageNamesFor: classes.
	extensions := Dictionary new.
	classCount := 0.
	methodCount := 0.
	packages := Set new.
	classes do: [ :class |
		| package packageDir file |
		package := self packageForCategory: (class category ifNil: [ #Unclassified ]) asString knownPackages: knownPackages.
		packages add: package.
		packageDir := (srcRoot / package) assureExistence.
		file := packageDir // (self fileNameForClass: class).
		file forceWriteStreamDo: [ :stream | TonelWriter writeClass: class on: stream ].
		self collectExtensionsOf: class into: extensions knownPackages: knownPackages.
		classCount := classCount + 1.
		methodCount := methodCount + class selectors size + class class selectors size ].
	self writeExtensions: extensions in: srcRoot intoPackages: packages.
	self
		writeManifestTo: outputRoot
		classCount: classCount
		methodCount: methodCount
		packages: packages.
	^ outputRoot! !

!TonelImageExporter class methodsFor: 'exporting' stamp: 'GC 4/Jun/2026 20:53:46'!
fileNameForClass: aClass
	^ aClass name asFileName, '.class.st'! !

!TonelImageExporter class methodsFor: 'exporting' stamp: 'GC 4/Jun/2026 20:53:46'!
knownPackageNamesFor: classes
	"All package names that an extension method category could map to: loaded CodePackages plus the category buckets of the exported classes. Sorted longest-first for longest-prefix matching."
	| names |
	names := Set new.
	CodePackage installedPackages valuesDo: [ :p | names add: p packageName asString ].
	classes do: [ :c | names add: (self packageNameForCategory: (c category ifNil: [ #Unclassified ]) asString) ].
	^ names asArray sort: [ :a :b | a size > b size ]! !

!TonelImageExporter class methodsFor: 'exporting' stamp: 'GC 4/Jun/2026 20:53:46'!
packageForCategory: aCategory knownPackages: knownPackages
	"Resolve a (system or extension) category to its owning package name by longest-prefix match against known package names; fall back to the first dash-segment."
	| lc |
	lc := aCategory asString asLowercase.
	^ (knownPackages
		detect: [ :p | | plc | plc := p asLowercase. lc = plc or: [ lc beginsWith: plc, '-' ] ]
		ifNone: [ nil ])
		ifNil: [ TonelWriter packageNameForCategory: aCategory ]! !

!TonelImageExporter class methodsFor: 'exporting' stamp: 'GC 4/Jun/2026 20:53:46'!
packageNameForCategory: aCategoryName
	^ TonelWriter packageNameForCategory: aCategoryName! !

!TonelImageExporter class methodsFor: 'exporting' stamp: 'GC 4/Jun/2026 20:53:46'!
writeExtensions: extensions in: srcRoot intoPackages: packages
	extensions keysAndValuesDo: [ :pkgName :classMap |
		packages add: pkgName.
		classMap keysAndValuesDo: [ :className :recs |
			| dir file ordered |
			dir := (srcRoot / pkgName) assureExistence.
			file := dir // (className asFileName, '.extension.st').
			ordered := recs asSortedCollection: [ :x :y |
				x second = y second ifTrue: [ x third <= y third ] ifFalse: [ y second ] ].
			file forceWriteStreamDo: [ :stream |
				stream nextPutAll: 'Extension { #name : '''; nextPutAll: className; nextPutAll: ''' }'; newLine.
				ordered do: [ :rec |
					TonelWriter writeMethod: rec third of: rec first classSide: rec second className: className on: stream ] ] ] ]! !

!TonelImageExporter class methodsFor: 'exporting' stamp: 'GC 4/Jun/2026 20:53:46'!
writeManifestTo: outputRoot classCount: classCount methodCount: methodCount packages: packages
	(outputRoot // 'manifest.txt') forceWriteStreamDo: [ :stream |
		stream nextPutAll: 'Tonel image export manifest'; newLine.
		stream nextPutAll: 'Generated: '; nextPutAll: DateAndTime now printString; newLine.
		stream nextPutAll: 'Image name: '; nextPutAll: Smalltalk imageName; newLine.
		stream nextPutAll: 'Image version: '; nextPutAll: SystemVersion current versionString; newLine.
		stream nextPutAll: 'Exported class count: '; nextPutAll: classCount printString; newLine.
		stream nextPutAll: 'Exported method count: '; nextPutAll: methodCount printString; newLine.
		stream nextPutAll: 'Package directory count: '; nextPutAll: packages size printString; newLine.
		stream nextPutAll: 'Format: Tonel v3-compatible source'; newLine.
		stream newLine.
		stream nextPutAll: 'Packages:'; newLine.
		(packages asArray sort) do: [ :package |
			stream nextPutAll: '- '; nextPutAll: package; newLine ] ]! !

!TonelImageExporter class methodsFor: 'exporting' stamp: 'GC 4/Jun/2026 20:53:46'!
writePropertiesIn: srcRoot
	(srcRoot // '.properties') forceWriteStreamDo: [ :stream |
		stream nextPutAll: '{'; newLine; tab; nextPutAll: '#format : #tonel'; newLine; nextPutAll: '}'; newLine ]! !

!TonelImporter class methodsFor: 'importing' stamp: 'GC 4/Jun/2026 20:22:37'!
creationSelectorFor: definition
	"The class-creation selector matching the definition's storage shape."
	definition type = 'variable' ifTrue: [ ^ #variableSubclass:instanceVariableNames:classVariableNames:poolDictionaries:category: ].
	definition type = 'bytes' ifTrue: [ ^ #variableByteSubclass:instanceVariableNames:classVariableNames:poolDictionaries:category: ].
	definition type = 'words' ifTrue: [ ^ #variableWordSubclass:instanceVariableNames:classVariableNames:poolDictionaries:category: ].
	definition type = 'weak' ifTrue: [ ^ #weakSubclass:instanceVariableNames:classVariableNames:poolDictionaries:category: ].
	^ #subclass:instanceVariableNames:classVariableNames:poolDictionaries:category:! !

!TonelImporter class methodsFor: 'importing' stamp: 'GC 4/Jun/2026 20:53:46'!
definitionsIn: aDirectoryEntry
	"Recursively read every Tonel definition (.st) under the directory."
	| definitions |
	definitions := OrderedCollection new.
	aDirectoryEntry children do: [ :entry |
		entry isDirectoryEntry
			ifTrue: [ definitions addAll: (self definitionsIn: entry) ]
			ifFalse: [ (entry name endsWith: '.st') ifTrue: [
				definitions add: (entry readStreamDo: [ :stream | TonelReader readStream: stream ]) ] ] ].
	^ definitions! !

!TonelImporter class methodsFor: 'importing' stamp: 'GC 4/Jun/2026 20:25:08'!
importDefinition: definition
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
	^ targetClass! !

!TonelImporter class methodsFor: 'importing' stamp: 'GC 4/Jun/2026 20:25:08'!
importDefinitions: aCollectionOfDefinitions
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
				(pending collect: [ :each | each className ]) asArray printString ] ]! !

!TonelImporter class methodsFor: 'importing' stamp: 'GC 4/Jun/2026 20:53:46'!
importDirectory: aDirectoryEntry
	self importDefinitions: (self definitionsIn: aDirectoryEntry)! !

!TonelImporter class methodsFor: 'importing' stamp: 'GC 4/Jun/2026 20:25:08'!
importExtension: definition
	"Compile the extension's methods onto the already-existing target class."
	| targetClass |
	targetClass := Smalltalk classNamed: definition className.
	targetClass ifNil: [ ^ self error: 'Missing class for extension: ', definition className ].
	definition methods do: [ :method |
		(method classSide ifTrue: [ targetClass class ] ifFalse: [ targetClass ])
			compile: method source
			classified: method protocol ].
	^ targetClass! !

!TonelImporter class methodsFor: 'importing' stamp: 'GC 4/Jun/2026 20:53:46'!
importFile: aFileEntry
	aFileEntry readStreamDo: [ :stream | ^ self importStream: stream ]! !

!TonelImporter class methodsFor: 'importing' stamp: 'GC 4/Jun/2026 20:53:46'!
importStream: aStream
	^ self importDefinition: (TonelReader readStream: aStream)! !

!TonelImporter class methodsFor: 'importing' stamp: 'GC 4/Jun/2026 20:25:08'!
isReady: definition
	"A definition can be imported once its dependency exists: for an extension, the target
	 class; for a class, the class itself (re-import) or its superclass."
	definition isExtension ifTrue: [ ^ (Smalltalk classNamed: definition className) notNil ].
	^ (Smalltalk classNamed: definition className) notNil
		or: [ (Smalltalk classNamed: definition superclassName) notNil ]! !

!TonelImporter class methodsFor: 'importing' stamp: 'GC 4/Jun/2026 20:53:46'!
namesStringFrom: aCollection
	^ String streamContents: [ :stream |
		aCollection do: [ :each |
			stream nextPutAll: each asString.
			each == aCollection last ifFalse: [ stream space ] ] ]! !

!TonelMethodDefinition methodsFor: 'accessing' stamp: 'GC 4/Jun/2026 20:53:46'!
className
	^ className! !

!TonelMethodDefinition methodsFor: 'accessing' stamp: 'GC 4/Jun/2026 20:53:46'!
className: aSymbol
	className := aSymbol! !

!TonelMethodDefinition methodsFor: 'accessing' stamp: 'GC 4/Jun/2026 20:53:46'!
classSide
	^ classSide ifNil: [ false ]! !

!TonelMethodDefinition methodsFor: 'accessing' stamp: 'GC 4/Jun/2026 20:53:46'!
classSide: aBoolean
	classSide := aBoolean! !

!TonelMethodDefinition methodsFor: 'accessing' stamp: 'GC 4/Jun/2026 20:53:46'!
protocol
	^ protocol! !

!TonelMethodDefinition methodsFor: 'accessing' stamp: 'GC 4/Jun/2026 20:53:46'!
protocol: aSymbol
	protocol := aSymbol! !

!TonelMethodDefinition methodsFor: 'accessing' stamp: 'GC 4/Jun/2026 20:53:46'!
selector
	^ selector! !

!TonelMethodDefinition methodsFor: 'accessing' stamp: 'GC 4/Jun/2026 20:53:46'!
selector: aSymbol
	selector := aSymbol! !

!TonelMethodDefinition methodsFor: 'accessing' stamp: 'GC 4/Jun/2026 20:53:46'!
source
	^ source! !

!TonelMethodDefinition methodsFor: 'accessing' stamp: 'GC 4/Jun/2026 20:53:46'!
source: aString
	source := aString! !

!TonelReader methodsFor: 'parsing' stamp: 'GC 4/Jun/2026 20:53:46'!
metadataAt: key in: lines
	| prefix line raw |
	prefix := '#', key, ' : '.
	line := lines detect: [ :each | each withBlanksTrimmed beginsWith: prefix ] ifNone: [ ^ nil ].
	raw := (line copyFrom: ((line findString: ': ' startingAt: 1) + 2) to: line size) withBlanksTrimmed.
	(raw endsWith: ',') ifTrue: [ raw := raw allButLast ].
	^ self unquote: raw! !

!TonelReader methodsFor: 'parsing' stamp: 'GC 4/Jun/2026 20:53:46'!
metadataListAt: key in: lines
	| prefix startIndex values index line trimmed |
	prefix := '#', key, ' : ['.
	startIndex := lines findFirst: [ :each | each withBlanksTrimmed beginsWith: prefix ].
	startIndex = 0 ifTrue: [ ^ #() ].
	values := OrderedCollection new.
	index := startIndex + 1.
	[ index <= lines size ] whileTrue: [
		line := lines at: index.
		trimmed := line withBlanksTrimmed.
		trimmed = ']' ifTrue: [ ^ values asArray ].
		trimmed = '],' ifTrue: [ ^ values asArray ].
		trimmed notEmpty ifTrue: [
			(trimmed endsWith: ',') ifTrue: [ trimmed := trimmed allButLast ].
			values add: (self unquote: trimmed) ].
		index := index + 1 ].
	^ values asArray! !

!TonelReader methodsFor: 'parsing' stamp: 'GC 4/Jun/2026 20:32:34'!
parse
	| definition lines line |
	definition := TonelClassDefinition new.
	lines := OrderedCollection new.
	line := stream nextLine.
	line = '"' ifTrue: [
		| commentStream next first |
		commentStream := WriteStream on: ''.
		first := true.
		[ (next := stream nextLine) = '"' ] whileFalse: [
			first ifFalse: [ commentStream newLine ].
			commentStream nextPutAll: next.
			first := false ].
		definition comment: commentStream contents.
		line := stream nextLine ].
	(line notNil and: [ line withBlanksTrimmed beginsWith: 'Extension {' ]) ifTrue: [
		definition isExtension: true.
		definition className: ((line copyAfter: $') copyUpTo: $') asSymbol.
		^ self parseMethodsInto: definition ].
	[ line notNil and: [ (line withBlanksTrimmed beginsWith: 'Class {') not ] ] whileTrue: [
		line := stream nextLine ].
	lines add: line.
	[ stream atEnd ] whileFalse: [
		line := stream nextLine.
		lines add: line.
		line withBlanksTrimmed = '}' ifTrue: [ ^ self parseMethodsInto: (self parseTypeDefinitionFrom: lines into: definition) ] ].
	^ definition! !

!TonelReader methodsFor: 'parsing' stamp: 'GC 4/Jun/2026 20:31:08'!
parseMethodHeader: headerLine metadata: metadataLine into: definition
	| protocol declaration method sourceStream classSide className selectorSource depth inString inComment |
	protocol := self unquote: ((metadataLine copyAfter: $:) copyUpTo: $}) withBlanksTrimmed.
	declaration := (headerLine copyUpToLast: $[) withBlanksTrimmed.
	classSide := declaration includesSubString: ' class >> '.
	classSide
		ifTrue: [
			| markerStart |
			markerStart := declaration findString: ' class >> ' startingAt: 1.
			className := declaration copyFrom: 1 to: markerStart - 1.
			selectorSource := declaration copyFrom: markerStart + ' class >> ' size to: declaration size ]
		ifFalse: [
			| markerStart |
			markerStart := declaration findString: ' >> ' startingAt: 1.
			className := declaration copyFrom: 1 to: markerStart - 1.
			selectorSource := declaration copyFrom: markerStart + ' >> ' size to: declaration size ].
	sourceStream := WriteStream on: ''.
	sourceStream nextPutAll: selectorSource.
	depth := 1.
	inString := false.
	inComment := false.
	[ stream atEnd ] whileFalse: [
		| line index |
		line := stream nextLine.
		sourceStream newLine.
		index := 1.
		[ index <= line size ] whileTrue: [
			| character handled |
			character := line at: index.
			handled := false.
			inString ifTrue: [
				sourceStream nextPut: character.
				character = $' ifTrue: [
					(index < line size and: [ (line at: index + 1) = $' ])
						ifTrue: [ index := index + 1. sourceStream nextPut: $' ]
						ifFalse: [ inString := false ] ].
				handled := true ].
			(handled not and: [ inComment ]) ifTrue: [
				sourceStream nextPut: character.
				character = $" ifTrue: [
					(index < line size and: [ (line at: index + 1) = $" ])
						ifTrue: [ index := index + 1. sourceStream nextPut: $" ]
						ifFalse: [ inComment := false ] ].
				handled := true ].
			(handled not and: [ character = $$ ]) ifTrue: [
				sourceStream nextPut: character.
				index < line size ifTrue: [
					index := index + 1.
					sourceStream nextPut: (line at: index) ].
				handled := true ].
			(handled not and: [ character = $' ]) ifTrue: [
				inString := true.
				sourceStream nextPut: character.
				handled := true ].
			(handled not and: [ character = $" ]) ifTrue: [
				inComment := true.
				sourceStream nextPut: character.
				handled := true ].
			(handled not and: [ character = $[ ]) ifTrue: [
				depth := depth + 1.
				sourceStream nextPut: character.
				handled := true ].
			(handled not and: [ character = $] ]) ifTrue: [
				depth := depth - 1.
				depth = 0 ifTrue: [
					| methodSource |
					methodSource := sourceStream contents.
					(methodSource notEmpty and: [ methodSource last = Character lf ]) ifTrue: [
						methodSource := methodSource allButLast ].
					method := TonelMethodDefinition new.
					method
						className: className asSymbol;
						classSide: classSide;
						protocol: protocol asSymbol;
						source: methodSource;
						selector: (self selectorFromMethodSource: methodSource).
					definition methods add: method.
					^ self ].
				sourceStream nextPut: character.
				handled := true ].
			handled ifFalse: [ sourceStream nextPut: character ].
			index := index + 1 ] ]! !

!TonelReader methodsFor: 'parsing' stamp: 'GC 4/Jun/2026 20:53:46'!
parseMethodsInto: definition
	| line metadata |
	[ stream atEnd ] whileFalse: [
		line := stream nextLine.
		(line notNil and: [ line withBlanksTrimmed beginsWith: '{' ]) ifTrue: [
			metadata := line.
			self parseMethodHeader: stream nextLine metadata: metadata into: definition ] ].
	^ definition! !

!TonelReader methodsFor: 'parsing' stamp: 'GC 4/Jun/2026 20:21:22'!
parseTypeDefinitionFrom: lines into: definition
	definition
		className: (self metadataAt: 'name' in: lines) asSymbol;
		superclassName: (self metadataAt: 'superclass' in: lines) asSymbol;
		instanceVariableNames: (self metadataListAt: 'instVars' in: lines);
		classVariableNames: (self metadataListAt: 'classVars' in: lines);
		poolDictionaries: (self metadataListAt: 'pools' in: lines);
		classInstanceVariableNames: (self metadataListAt: 'classInstVars' in: lines);
		category: (self metadataAt: 'category' in: lines) asSymbol;
		package: (self metadataAt: 'package' in: lines) asSymbol.
	(self metadataAt: 'type' in: lines) ifNotNil: [ :t | definition type: t ].
	(self metadataAt: 'tag' in: lines) ifNotNil: [ :tagName | definition tag: tagName asSymbol ].
	^ definition! !

!TonelReader methodsFor: 'parsing' stamp: 'GC 4/Jun/2026 20:53:46'!
selectorFromMethodSource: sourceString
	| firstLine tokens selector |
	firstLine := sourceString readStream nextLine.
	tokens := firstLine substrings.
	(tokens anySatisfy: [ :each | each includes: $: ]) ifTrue: [
		selector := WriteStream on: ''.
		tokens do: [ :each | (each includes: $:) ifTrue: [ selector nextPutAll: each ] ].
		^ selector contents asSymbol ].
	^ tokens first asSymbol! !

!TonelReader methodsFor: 'parsing' stamp: 'GC 4/Jun/2026 20:53:46'!
stream: aStream
	stream := aStream! !

!TonelReader methodsFor: 'parsing' stamp: 'GC 4/Jun/2026 20:53:46'!
unquote: aString
	| trimmed |
	trimmed := aString withBlanksTrimmed.
	((trimmed size >= 2) and: [ trimmed first = $' and: [ trimmed last = $' ] ])
		ifFalse: [ ^ trimmed ].
	^ (trimmed copyFrom: 2 to: trimmed size - 1) copyReplaceAll: '''''' with: ''''! !

!TonelReader class methodsFor: 'instance creation' stamp: 'GC 4/Jun/2026 20:53:46'!
readStream: aStream
	^ self new
		stream: aStream;
		parse! !

!TonelWriter class methodsFor: 'writing' stamp: 'GC 4/Jun/2026 20:53:46'!
isExtensionCategory: aCategory
	| s |
	s := aCategory asString.
	^ s notEmpty and: [ s first = $* ]! !

!TonelWriter class methodsFor: 'writing' stamp: 'GC 4/Jun/2026 20:53:46'!
methodCategoryOf: selector in: aClassOrMetaclass
	^ (aClassOrMetaclass organization categoryOfElement: selector) ifNil: [ #'as yet unclassified' ]! !

!TonelWriter class methodsFor: 'writing' stamp: 'GC 4/Jun/2026 20:53:46'!
packageNameForCategory: aCategoryName
	| category dashIndex |
	category := aCategoryName asString.
	dashIndex := category findString: '-' startingAt: 1.
	dashIndex = 0 ifTrue: [ ^ category ].
	^ category copyFrom: 1 to: dashIndex - 1! !

!TonelWriter class methodsFor: 'writing' stamp: 'GC 4/Jun/2026 20:53:46'!
sourceForClass: aClass
	^ String streamContents: [ :stream | self writeClass: aClass on: stream ]! !

!TonelWriter class methodsFor: 'writing' stamp: 'GC 4/Jun/2026 20:53:46'!
stonKey: key value: value on: stream last: isLast
	stream
		tab; nextPut: $#; nextPutAll: key; nextPutAll: ' : ';
		nextPut: $'; nextPutAll: (self stonString: value); nextPut: $'.
	isLast ifFalse: [ stream nextPut: $, ].
	stream newLine! !

!TonelWriter class methodsFor: 'writing' stamp: 'GC 4/Jun/2026 20:53:46'!
stonListKey: key values: values on: stream
	values isEmpty ifTrue: [ ^ self ].
	stream tab; nextPut: $#; nextPutAll: key; nextPutAll: ' : ['; newLine.
	values do: [ :each |
		stream tab; tab; nextPut: $'; nextPutAll: (self stonString: each); nextPut: $'.
		each == values last ifFalse: [ stream nextPut: $, ].
		stream newLine ].
	stream tab; nextPutAll: '],'; newLine! !

!TonelWriter class methodsFor: 'writing' stamp: 'GC 4/Jun/2026 20:53:46'!
stonString: aString
	^ aString asString copyReplaceAll: '''' with: ''''''! !

!TonelWriter class methodsFor: 'writing' stamp: 'GC 4/Jun/2026 20:20:25'!
tonelTypeOf: aClass
	"The Tonel #type token for aClass's storage shape, or nil for a normal fixed class."
	aClass isWeak ifTrue: [ ^ 'weak' ].
	aClass isBytes ifTrue: [ ^ 'bytes' ].
	aClass isWords ifTrue: [ ^ 'words' ].
	aClass isVariable ifTrue: [ ^ 'variable' ].
	^ nil! !

!TonelWriter class methodsFor: 'writing' stamp: 'GC 4/Jun/2026 20:20:25'!
writeClass: aClass on: stream
	| comment category package tag classVars pools |
	comment := aClass organization classComment.
	comment isEmptyOrNil ifFalse: [
		stream nextPut: $"; newLine; nextPutAll: comment; newLine; nextPut: $"; newLine ].
	category := aClass category asString.
	package := self packageNameForCategory: category.
	tag := category = package ifTrue: [ nil ] ifFalse: [ category copyFrom: package size + 2 to: category size ].
	stream nextPutAll: 'Class {'; newLine.
	self stonKey: 'name' value: aClass name on: stream last: false.
	self stonKey: 'superclass' value: (aClass superclass ifNil: [ nil ] ifNotNil: [ :parentClass | parentClass name ]) on: stream last: false.
	(self tonelTypeOf: aClass) ifNotNil: [ :t | self stonKey: 'type' value: t on: stream last: false ].
	self stonListKey: 'instVars' values: aClass instVarNames on: stream.
	classVars := aClass classPool keys asArray sort.
	self stonListKey: 'classVars' values: classVars on: stream.
	pools := (aClass sharedPools collect: [ :pool | Smalltalk keyAtIdentityValue: pool ]) asArray sort.
	self stonListKey: 'pools' values: pools on: stream.
	self stonListKey: 'classInstVars' values: aClass class instVarNames on: stream.
	self stonKey: 'category' value: category on: stream last: false.
	self stonKey: 'package' value: package on: stream last: tag isNil.
	tag ifNotNil: [ self stonKey: 'tag' value: tag on: stream last: true ].
	stream nextPutAll: '}'; newLine.
	self writeMethodsOf: aClass class classSide: true className: aClass name on: stream.
	self writeMethodsOf: aClass classSide: false className: aClass name on: stream! !

!TonelWriter class methodsFor: 'writing' stamp: 'GC 4/Jun/2026 20:33:20'!
writeMethod: selector of: aClassOrMetaclass classSide: classSide className: className on: stream
	| source sourceStream declarationLine body category |
	source := aClassOrMetaclass sourceCodeAt: selector.
	sourceStream := source readStream.
	declarationLine := sourceStream nextLine.
	body := sourceStream upToEnd.
	[ body notEmpty and: [ body last = Character lf or: [ body last = Character cr ] ] ]
		whileTrue: [ body := body allButLast ].
	category := self methodCategoryOf: selector in: aClassOrMetaclass.
	stream newLine.
	stream nextPutAll: '{ #category : '''; nextPutAll: (self stonString: category); nextPutAll: ''' }'; newLine.
	stream nextPutAll: className.
	classSide ifTrue: [ stream nextPutAll: ' class' ].
	stream nextPutAll: ' >> '; nextPutAll: declarationLine; nextPutAll: ' ['.
	stream newLine; nextPutAll: body; newLine; nextPutAll: ']'; newLine! !

!TonelWriter class methodsFor: 'writing' stamp: 'GC 4/Jun/2026 20:53:46'!
writeMethodsOf: aClassOrMetaclass classSide: classSide className: className on: stream
	"Write only the methods owned by this class (skip extension methods, whose category starts with $*; those belong to another package and are written as .extension.st files)."
	| selectors |
	selectors := aClassOrMetaclass selectors asArray sort.
	selectors do: [ :selector |
		(self isExtensionCategory: (self methodCategoryOf: selector in: aClassOrMetaclass))
			ifFalse: [ self writeMethod: selector of: aClassOrMetaclass classSide: classSide className: className on: stream ] ]! !
