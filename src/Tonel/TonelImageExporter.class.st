Class {
	#name : 'TonelImageExporter',
	#superclass : 'Object',
	#category : 'Tonel',
	#package : 'Tonel'
}

{ #category : 'exporting' }
TonelImageExporter class >> collectExtensionsOf: aClass into: extensions knownPackages: knownPackages [
	self collectExtensionsOn: aClass class classSide: true className: aClass name asString into: extensions knownPackages: knownPackages.
	self collectExtensionsOn: aClass classSide: false className: aClass name asString into: extensions knownPackages: knownPackages
]

{ #category : 'exporting' }
TonelImageExporter class >> collectExtensionsOn: aClassOrMetaclass classSide: classSide className: className into: extensions knownPackages: knownPackages [
	aClassOrMetaclass selectors do: [ :selector |
		| cat |
		cat := (TonelWriter methodCategoryOf: selector in: aClassOrMetaclass) asString.
		(TonelWriter isExtensionCategory: cat) ifTrue: [
			| targetPkg |
			targetPkg := self packageForCategory: (cat copyFrom: 2 to: cat size) knownPackages: knownPackages.
			((extensions at: targetPkg ifAbsentPut: [ Dictionary new ])
				at: className ifAbsentPut: [ OrderedCollection new ])
				add: { aClassOrMetaclass. classSide. selector } ] ]
]

{ #category : 'exporting' }
TonelImageExporter class >> exportAllTo: aDirectoryEntry [
	^ self exportClasses: (Smalltalk allClasses asArray sort: [ :left :right | left name < right name ]) to: aDirectoryEntry
]

{ #category : 'exporting' }
TonelImageExporter class >> exportClasses: classes to: aDirectoryEntry [
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
	^ outputRoot
]

{ #category : 'exporting' }
TonelImageExporter class >> fileNameForClass: aClass [
	^ aClass name asFileName, '.class.st'
]

{ #category : 'exporting' }
TonelImageExporter class >> knownPackageNamesFor: classes [
	"All package names that an extension method category could map to: loaded CodePackages plus the category buckets of the exported classes. Sorted longest-first for longest-prefix matching."
	| names |
	names := Set new.
	CodePackage installedPackages valuesDo: [ :p | names add: p packageName asString ].
	classes do: [ :c | names add: (self packageNameForCategory: (c category ifNil: [ #Unclassified ]) asString) ].
	^ names asArray sort: [ :a :b | a size > b size ]
]

{ #category : 'exporting' }
TonelImageExporter class >> packageForCategory: aCategory knownPackages: knownPackages [
	"Resolve a (system or extension) category to its owning package name by longest-prefix match against known package names; fall back to the first dash-segment."
	| lc |
	lc := aCategory asString asLowercase.
	^ (knownPackages
		detect: [ :p | | plc | plc := p asLowercase. lc = plc or: [ lc beginsWith: plc, '-' ] ]
		ifNone: [ nil ])
		ifNil: [ TonelWriter packageNameForCategory: aCategory ]
]

{ #category : 'exporting' }
TonelImageExporter class >> packageNameForCategory: aCategoryName [
	^ TonelWriter packageNameForCategory: aCategoryName
]

{ #category : 'exporting' }
TonelImageExporter class >> writeExtensions: extensions in: srcRoot intoPackages: packages [
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
					TonelWriter writeMethod: rec third of: rec first classSide: rec second className: className on: stream ] ] ] ]
]

{ #category : 'exporting' }
TonelImageExporter class >> writeManifestTo: outputRoot classCount: classCount methodCount: methodCount packages: packages [
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
			stream nextPutAll: '- '; nextPutAll: package; newLine ] ]
]

{ #category : 'exporting' }
TonelImageExporter class >> writePropertiesIn: srcRoot [
	(srcRoot // '.properties') forceWriteStreamDo: [ :stream |
		stream nextPutAll: '{'; newLine; tab; nextPutAll: '#format : #tonel'; newLine; nextPutAll: '}'; newLine ]
]
