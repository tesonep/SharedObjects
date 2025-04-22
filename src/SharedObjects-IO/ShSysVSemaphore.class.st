Class {
	#name : 'ShSysVSemaphore',
	#superclass : 'Object',
	#instVars : [
		'semaphoreSet',
		'index'
	],
	#category : 'SharedObjects-IO',
	#package : 'SharedObjects-IO'
}

{ #category : 'as yet unclassified' }
ShSysVSemaphore class >> for: aShSysVSemaphoreSet index: anInteger [ 
	
	^ self new
		semaphoreSet: aShSysVSemaphoreSet;
		index: anInteger;
		yourself
]

{ #category : 'initialization' }
ShSysVSemaphore >> critical: mutuallyExcludedBlock [

	| blockValue caught |
	caught := false.
	[
		caught := true.
		(self tryWait not and: [ self isOwnerProcess not ]) 
			ifTrue: [ self wait ].
			
		blockValue := mutuallyExcludedBlock value
	] ensure: [caught ifTrue: [self signal]].
	^blockValue
]

{ #category : 'accessing' }
ShSysVSemaphore >> index: anInteger [ 
	
	index := anInteger 

]

{ #category : 'initialization' }
ShSysVSemaphore >> isOwnerProcess [

	^ self lastPid = LibC uniqueInstance getpid
]

{ #category : 'initialization' }
ShSysVSemaphore >> lastPid [

	^ semaphoreSet lastPidOf: index
]

{ #category : 'as yet unclassified' }
ShSysVSemaphore >> semaphoreSet: aShSysVSemaphoreSet [ 
	
	semaphoreSet := aShSysVSemaphoreSet 

]

{ #category : 'initialization' }
ShSysVSemaphore >> setValue: aValue [ 
	
	^ semaphoreSet set: aValue asValueOf: index
]

{ #category : 'initialization' }
ShSysVSemaphore >> signal [

	semaphoreSet signal: index
]

{ #category : 'initialization' }
ShSysVSemaphore >> tryWait [

	^ semaphoreSet tryWait: index
]

{ #category : 'initialization' }
ShSysVSemaphore >> wait [

	semaphoreSet wait: index
]
