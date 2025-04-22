Class {
	#name : 'ShSysVSharedChannel',
	#superclass : 'ShChannel',
	#instVars : [
		'sharedMemory',
		'semaphoreSet'
	],
	#category : 'SharedObjects-IO',
	#package : 'SharedObjects-IO'
}

{ #category : 'as yet unclassified' }
ShSysVSharedChannel class >> createNamed: aFileLocator withSize: aSize [ 
	
	^ self new
		createNamed: aFileLocator withSize: aSize;
		yourself
]

{ #category : 'as yet unclassified' }
ShSysVSharedChannel class >> openNamed: aFileLocator [
	
	^ self new
		openNamed: aFileLocator;
		yourself
]

{ #category : 'as yet unclassified' }
ShSysVSharedChannel >> createNamed: aFileLocator withSize: aSize [ 
	
	sharedMemory := ShSysVSharedMemory named: aFileLocator size: aSize.
	sharedMemory createAndOpen.
	
	semaphoreSet := ShSysVSemaphoreSet named: aFileLocator numberOfSemaphores: 3.
	semaphoreSet createAndOpen.

	self 
		initializeMemory: sharedMemory address withSize: aSize;
		accessMutex: ((semaphoreSet semaphoreAt: 1) setValue: 1; yourself);
		sendSemaphore: ((semaphoreSet semaphoreAt: 2) setValue: 1; yourself);
		receiveSemaphore: ((semaphoreSet semaphoreAt: 3) setValue: 0; yourself)
]

{ #category : 'deleting' }
ShSysVSharedChannel >> destroy [
	
	sharedMemory destroy.
	semaphoreSet destroy
]

{ #category : 'as yet unclassified' }
ShSysVSharedChannel >> openNamed: aFileLocator [
	
	sharedMemory := ShSysVSharedMemory openNamed: aFileLocator.
	sharedMemory open.
	
	semaphoreSet := ShSysVSemaphoreSet named: aFileLocator numberOfSemaphores: 3.
	semaphoreSet open.

	self 
		memory: sharedMemory address;
		accessMutex: (semaphoreSet semaphoreAt: 1);
		sendSemaphore: (semaphoreSet semaphoreAt: 2);
		receiveSemaphore: (semaphoreSet semaphoreAt: 3)
]
