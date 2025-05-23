Class {
	#name : 'ShSysVSemaphoreSet',
	#superclass : 'ShAbstractSysVKeyed',
	#instVars : [
		'numberOfSemaphores',
		'semaphoreSetId'
	],
	#category : 'SharedObjects-IO',
	#package : 'SharedObjects-IO'
}

{ #category : 'instance creation' }
ShSysVSemaphoreSet class >> named: aFileReference [

	^ self named: aFileReference projectId: $A codePoint
]

{ #category : 'instance creation' }
ShSysVSemaphoreSet class >> named: aFileReference numberOfSemaphores: semaphores [

	^ self named: aFileReference projectId: $A codePoint numberOfSemaphores: semaphores
]

{ #category : 'instance creation' }
ShSysVSemaphoreSet class >> named: aFileReference projectId: aProjectId [

	^ self named: aFileReference projectId: aProjectId numberOfSemaphores: 1

]

{ #category : 'instance creation' }
ShSysVSemaphoreSet class >> named: aFileReference projectId: aProjectId numberOfSemaphores: numSems [

	^ self new
		file: aFileReference resolve fullName;
		projectId: aProjectId;
		numberOfSemaphores: numSems;
		yourself
]

{ #category : 'instance creation' }
ShSysVSemaphoreSet >> createAndOpen [
	
	semaphoreSetId := self semget: self key nsems: numberOfSemaphores semflg: IPC_CREAT | IPC_EXCL | S_IWUSR | S_IRUSR.
	semaphoreSetId = 0 ifTrue: [ self error: 'Error in semget: ' , self errno printString ]
]

{ #category : 'deleting' }
ShSysVSemaphoreSet >> destroy [
	
	self isValid ifFalse: [ ^ self ].
	
	self semctl: semaphoreSetId semnum: 0 op: IPC_RMID.
	
	semaphoreSetId := nil.
]

{ #category : 'as yet unclassified' }
ShSysVSemaphoreSet >> doWait: semaphoreIndex withDecrement: decrement try: try [

	| buf returnValue lastErrno |
	semaphoreIndex <= numberOfSemaphores ifFalse: [ ^ self error: 'Invalid Semaphore Index' ].
	decrement >= 1 ifFalse: [ ^ self error: 'Invalid decrement' ].
	
	buf := ShSysVSemaphoreBuffer new.
	buf sem_num: semaphoreIndex - 1.
	buf sem_op: decrement negated.

	try 
		ifTrue:  [ buf sem_flg: IPC_NOWAIT ]
		ifFalse: [ buf sem_flg: 0 ].
	
	returnValue := self semop: semaphoreSetId semaphoreOperations: buf size: 1.
	returnValue < 0 ifTrue: [ 
		lastErrno := self errno.
		(lastErrno = 35 and: [ try ]) ifTrue: [ ^ false ].
		self error: 'Cannot wait:', lastErrno printString.
		^ false ].
	
	^ true.
	
]

{ #category : 'testing' }
ShSysVSemaphoreSet >> isValid [
	
	^ semaphoreSetId isNotNil and: [ semaphoreSetId > 0 ]
]

{ #category : 'as yet unclassified' }
ShSysVSemaphoreSet >> lastPidOf: semaphoreIndex [

	| returnValue |

	semaphoreIndex <= numberOfSemaphores ifFalse: [ ^ self error: 'Invalid Semaphore Index' ].
	
	returnValue := self semctl: semaphoreSetId semnum: semaphoreIndex - 1  op: GETPID.
	returnValue < 0 ifTrue: [ self error: 'Cannot get pid: ', self errno printString ].
	
	^ returnValue 
]

{ #category : 'as yet unclassified' }
ShSysVSemaphoreSet >> numberOfSemaphores: anInteger [ 
	
	numberOfSemaphores := anInteger 

]

{ #category : 'instance creation' }
ShSysVSemaphoreSet >> open [
	
	semaphoreSetId := self semget: self key nsems: numberOfSemaphores semflg: 0.
	semaphoreSetId = 0 ifTrue: [ self error: 'Error in semget: ' , self errno printString ]
]

{ #category : 'accessing' }
ShSysVSemaphoreSet >> semaphoreAt: index [ 
	
	^ ShSysVSemaphore for: self index: index
]

{ #category : 'as yet unclassified' }
ShSysVSemaphoreSet >> semctl: semid semnum: semnum op: cmd [ 
	
	self ffiCall: #(int semctl(int semid, int semnum, int cmd))
]

{ #category : 'as yet unclassified' }
ShSysVSemaphoreSet >> semctl: semid semnum: semnum op: cmd int: aValue [

	self
		ffiCall: #( int semctl( int semid #, int semnum #, int cmd #, int aValue ) )
		fixedArgumentCount: 3
]

{ #category : 'as yet unclassified' }
ShSysVSemaphoreSet >> semget: aKey nsems: nsems semflg: semflg [ 
	
	self 
		ffiCall: #(int semget(key_t aKey, int nsems, int semflg))
]

{ #category : 'as yet unclassified' }
ShSysVSemaphoreSet >> semop: semid semaphoreOperations: sops size: nsops [ 

	self ffiCall: #(int semop(int semid, ShSysVSemaphoreBuffer *sops, size_t nsops))
]

{ #category : 'as yet unclassified' }
ShSysVSemaphoreSet >> set: aValue asValueOf: semaphoreIndex [
	
	| returnValue |
	
	aValue >= 0 ifFalse: [ ^ self error: 'Value should be >= 0' ].
	semaphoreIndex <= numberOfSemaphores ifFalse: [ ^ self error: 'Invalid Semaphore Index' ].

	returnValue := self semctl: semaphoreSetId semnum: semaphoreIndex - 1  op: SETVAL int: aValue.
	returnValue < 0 ifTrue: [ self error: 'Cannot set value:', self errno printString ].
	
	^ returnValue 
]

{ #category : 'as yet unclassified' }
ShSysVSemaphoreSet >> signal: semaphoreIndex [

	^ self signal: semaphoreIndex withIncrement: 1
]

{ #category : 'as yet unclassified' }
ShSysVSemaphoreSet >> signal: semaphoreIndex withIncrement: increment [

	| buf returnValue |
	semaphoreIndex <= numberOfSemaphores ifFalse: [ ^ self error: 'Invalid Semaphore Index' ].
	increment >= 1 ifFalse: [ ^ self error: 'Invalid Increment' ].
	
	buf := ShSysVSemaphoreBuffer new.
	buf sem_num: semaphoreIndex - 1.
	buf sem_op: increment.
	buf sem_flg: 0.
	
	returnValue := self semop: semaphoreSetId semaphoreOperations: buf size: 1.
	returnValue < 0 ifTrue: [ self error: 'Cannot signal:', self errno printString ].
	
]

{ #category : 'as yet unclassified' }
ShSysVSemaphoreSet >> tryWait: semaphoreIndex [

	^ self tryWait: semaphoreIndex withDecrement: 1
]

{ #category : 'as yet unclassified' }
ShSysVSemaphoreSet >> tryWait: semaphoreIndex withDecrement: decrement [

	^ self doWait: semaphoreIndex withDecrement: decrement try: true
	
]

{ #category : 'as yet unclassified' }
ShSysVSemaphoreSet >> valueOf: semaphoreIndex [
	
	| returnValue |
	
	semaphoreIndex <= numberOfSemaphores ifFalse: [ ^ self error: 'Invalid Semaphore Index' ].
	
	returnValue := self semctl: semaphoreSetId semnum: semaphoreIndex - 1  op: GETVAL.
	returnValue < 0 ifTrue: [ self error: 'Cannot get value:', self errno printString ].
	
	^ returnValue 
]

{ #category : 'as yet unclassified' }
ShSysVSemaphoreSet >> wait: semaphoreIndex [

	^ self wait: semaphoreIndex withDecrement: 1
]

{ #category : 'as yet unclassified' }
ShSysVSemaphoreSet >> wait: semaphoreIndex withDecrement: decrement [

	^ self doWait: semaphoreIndex withDecrement: decrement try: false
	
]
