Class {
	#name : 'ShSysVSharedMemory',
	#superclass : 'ShAbstractSysVKeyed',
	#instVars : [
		'address',
		'sharedMemoryId',
		'initialSize'
	],
	#category : 'SharedObjects-IO',
	#package : 'SharedObjects-IO'
}

{ #category : 'instance creation' }
ShSysVSharedMemory class >> named: aFileReference [

	^ self named: aFileReference projectId: $A codePoint size: 1 * (1024*1024)
]

{ #category : 'as yet unclassified' }
ShSysVSharedMemory class >> named: aFileReference projectId: aProjectId size: initialSize [

	^ self new
		file: aFileReference resolve fullName;
		projectId: aProjectId;
		initialSize: initialSize;
		yourself
]

{ #category : 'instance creation' }
ShSysVSharedMemory class >> named: aFileReference size: aSize [

	^ self named: aFileReference projectId: $A codePoint size: aSize
]

{ #category : 'instance creation' }
ShSysVSharedMemory class >> openNamed: aFileReference [

	^ self new
		file: aFileReference resolve fullName;
		projectId: $A codePoint;
		yourself

]

{ #category : 'accessing' }
ShSysVSharedMemory >> address [

	^ address
]

{ #category : 'instance creation' }
ShSysVSharedMemory >> createAndOpen [

	sharedMemoryId := self shmget: self key initialSize: initialSize shmflg: IPC_CREAT | IPC_EXCL | S_IWUSR | S_IRUSR.
	sharedMemoryId = 0 ifTrue: [ self error: 'Error in shmget: ' , self errno printString ].
	
	address := self shmat: sharedMemoryId requestedAddress: ExternalAddress null flags: 0.
	
	address asInteger = ((1 << (Smalltalk wordSize * 8)) - 1) 
		ifTrue: [ self error: 'Error doing shmat:' , self errno printString ].
]

{ #category : 'instance creation' }
ShSysVSharedMemory >> destroy [

	(address isNotNil and: [address isNull not])
		ifTrue: [ self shmdt: address ].

	
	(sharedMemoryId isNotNil and: [sharedMemoryId ~= 0])
		ifTrue: [ self shmctl: sharedMemoryId cmd: IPC_RMID buf: ExternalAddress null ].
	
	address beNull.
	address := nil.
	sharedMemoryId := nil.
]

{ #category : 'as yet unclassified' }
ShSysVSharedMemory >> initialSize: anInteger [ 
	
	initialSize := anInteger 

]

{ #category : 'testing' }
ShSysVSharedMemory >> isValid [
	
	^ address isNotNil and: [ address isNull not ]
]

{ #category : 'instance creation' }
ShSysVSharedMemory >> open [

	sharedMemoryId := self shmget: self key initialSize: 0 shmflg: 0.
	sharedMemoryId = 0 ifTrue: [ self error: 'Error in shmget: ' , self errno printString ].
	
	address := self shmat: sharedMemoryId requestedAddress: ExternalAddress null flags: 0.
	
	address asInteger = ((1 << (Smalltalk wordSize * 8)) - 1) 
		ifTrue: [ self error: 'Error doing shmat:' , self errno printString ].
]

{ #category : 'as yet unclassified' }
ShSysVSharedMemory >> shmat: shmid requestedAddress: shmaddr flags: shmflg [ 
	
	self ffiCall: #(void* shmat(int shmid,void* shmaddr, int shmflg))
]

{ #category : 'as yet unclassified' }
ShSysVSharedMemory >> shmctl: shmid cmd: cmd buf: buf [ 

	^ self ffiCall: #(int shmctl(int shmid, int cmd, "struct shmid_ds *" void* buf))
]

{ #category : 'as yet unclassified' }
ShSysVSharedMemory >> shmdt: shmaddr [ 
	
	self ffiCall: #(int shmdt(const void *shmaddr))
]

{ #category : 'as yet unclassified' }
ShSysVSharedMemory >> shmget: key initialSize: size shmflg: shmflg [ 

	^ self ffiCall: #(int shmget(key_t key, size_t size, int shmflg))
]
