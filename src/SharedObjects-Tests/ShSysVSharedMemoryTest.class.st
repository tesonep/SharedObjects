Class {
	#name : 'ShSysVSharedMemoryTest',
	#superclass : 'TestCase',
	#instVars : [
		'sharedMemory'
	],
	#category : 'SharedObjects-Tests',
	#package : 'SharedObjects-Tests'
}

{ #category : 'running' }
ShSysVSharedMemoryTest >> tearDown [
	
	sharedMemory ifNotNil: [ sharedMemory destroy ].
]

{ #category : 'running' }
ShSysVSharedMemoryTest >> testNamedSharedMemory [

	sharedMemory := ShSysVSharedMemory named: FileLocator imageDirectory.
	
	sharedMemory createAndOpen.
	
	self assert: sharedMemory isValid.
]
