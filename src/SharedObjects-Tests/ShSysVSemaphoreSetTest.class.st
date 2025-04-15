Class {
	#name : 'ShSysVSemaphoreSetTest',
	#superclass : 'TestCase',
	#instVars : [
		'semaphoreSet'
	],
	#category : 'SharedObjects-Tests',
	#package : 'SharedObjects-Tests'
}

{ #category : 'running' }
ShSysVSemaphoreSetTest >> tearDown [
	
	semaphoreSet ifNotNil: [ semaphoreSet destroy ].
]

{ #category : 'tests' }
ShSysVSemaphoreSetTest >> testNamedSemaphoreSet [

	semaphoreSet := ShSysVSemaphoreSet named: FileLocator imageDirectory.
	
	semaphoreSet open.
	
	self assert: semaphoreSet isValid.
]

{ #category : 'tests' }
ShSysVSemaphoreSetTest >> testNewSemaphoreDoesNotHavePID [

	semaphoreSet := ShSysVSemaphoreSet named: FileLocator imageDirectory.
	
	semaphoreSet open.
		
	self assert: (semaphoreSet lastPidOf: 1) equals: 0
]

{ #category : 'tests' }
ShSysVSemaphoreSetTest >> testNewSemaphoreHasCorrectValue [

	semaphoreSet := ShSysVSemaphoreSet named: FileLocator imageDirectory.
	
	semaphoreSet open.
	
	self assert: (semaphoreSet valueOf: 1) equals: 0.
]

{ #category : 'tests' }
ShSysVSemaphoreSetTest >> testSettingTheValueOfASemaphoreAffectsTheValue [

	semaphoreSet := ShSysVSemaphoreSet named: FileLocator imageDirectory.
	
	semaphoreSet open.
	semaphoreSet set: 23 asValueOf: 1.
	
	self assert: (semaphoreSet valueOf: 1) equals: 23.
]

{ #category : 'tests' }
ShSysVSemaphoreSetTest >> testSignallingChangesLastPID [

	semaphoreSet := ShSysVSemaphoreSet named: FileLocator imageDirectory.
	
	semaphoreSet open.
	semaphoreSet signal: 1.
	
	self assert: (semaphoreSet lastPidOf: 1) equals: LibC uniqueInstance getpid
]

{ #category : 'tests' }
ShSysVSemaphoreSetTest >> testSignallingWillIncreaseTheValue [

	semaphoreSet := ShSysVSemaphoreSet named: FileLocator imageDirectory.
	
	semaphoreSet open.
	semaphoreSet signal: 1.
	
	self assert: (semaphoreSet valueOf: 1) equals: 1.
]

{ #category : 'tests' }
ShSysVSemaphoreSetTest >> testTryWaitWithAvailableSignalsWork [

	semaphoreSet := ShSysVSemaphoreSet named: FileLocator imageDirectory.
	
	semaphoreSet open.
	semaphoreSet set: 23 asValueOf: 1.
	
	semaphoreSet tryWait: 1 withDecrement: 23.
	
	self assert: (semaphoreSet valueOf: 1) equals: 0.
]

{ #category : 'tests' }
ShSysVSemaphoreSetTest >> testTryWaitWithoutSignalsDoesNotHungAndGeneratesError [

	semaphoreSet := ShSysVSemaphoreSet named: FileLocator imageDirectory.
	
	semaphoreSet open.
	
	self should: [semaphoreSet tryWait: 1 withDecrement: 23] raise: ShSemaphoreWillBlock.
	

]

{ #category : 'tests' }
ShSysVSemaphoreSetTest >> testWaitingAffectsValue [

	semaphoreSet := ShSysVSemaphoreSet named: FileLocator imageDirectory.
	
	semaphoreSet open.
	semaphoreSet set: 23 asValueOf: 1.
	
	semaphoreSet wait: 1.
	
	self assert: (semaphoreSet valueOf: 1) equals: 22.
]

{ #category : 'tests' }
ShSysVSemaphoreSetTest >> testWaitingWithExactValueDoesNotBlock [

	semaphoreSet := ShSysVSemaphoreSet named: FileLocator imageDirectory.
	
	semaphoreSet open.
	semaphoreSet set: 23 asValueOf: 1.
	
	semaphoreSet wait: 1 withDecrement: 23.
	
	self assert: (semaphoreSet valueOf: 1) equals: 0.
]
