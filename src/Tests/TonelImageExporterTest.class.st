Class {
	#name : 'TonelImageExporterTest',
	#superclass : 'TestCase',
	#instVars : [
		'exportRoot'
	],
	#category : 'Tests-Tonel',
	#package : 'Tests',
	#tag : 'Tonel'
}

{ #category : 'assertions' }
TonelImageExporterTest >> contentsOf: aFileEntry [
	aFileEntry readStreamDo: [ :stream | ^ stream upToEnd ]
]

{ #category : 'running' }
TonelImageExporterTest >> setUp [
	super setUp.
	exportRoot := '/tmp/cuis-tonel-exporter-test' asDirectoryEntry assureExistence
]

{ #category : 'tests' }
TonelImageExporterTest >> testExportClassesWritesGroupedTonelFile [
	| file source |
	TonelImageExporter exportClasses: { TonelWriterTest } to: exportRoot.
	file := exportRoot / 'src' / 'Tests' // 'TonelWriterTest.class.st'.
	self assert: file exists.
	source := self contentsOf: file.
	self assert: (source includesSubString: 'Class {').
	self assert: (source includesSubString: 'TonelWriterTest >> assert: aString includes: expectedSubstring [')
]

{ #category : 'tests' }
TonelImageExporterTest >> testExportWritesTonelProperties [
	| file |
	TonelImageExporter exportClasses: { TonelWriterTest } to: exportRoot.
	file := exportRoot / 'src' // '.properties'.
	self assert: file exists.
	self assert: ((self contentsOf: file) includesSubString: '#format : #tonel')
]

{ #category : 'tests' }
TonelImageExporterTest >> testFileNameForClass [
	self assert: (TonelImageExporter fileNameForClass: TonelWriterTest) equals: 'TonelWriterTest.class.st'
]

{ #category : 'tests' }
TonelImageExporterTest >> testPackageNameForCategory [
	self assert: (TonelImageExporter packageNameForCategory: #'Kernel-Objects') equals: 'Kernel'.
	self assert: (TonelImageExporter packageNameForCategory: #'Tests-Tonel') equals: 'Tests'.
	self assert: (TonelImageExporter packageNameForCategory: #Tonel) equals: 'Tonel'
]
