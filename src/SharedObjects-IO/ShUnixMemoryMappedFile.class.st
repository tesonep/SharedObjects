Class {
	#name : 'ShUnixMemoryMappedFile',
	#superclass : 'Object',
	#instVars : [
		'filePath',
		'size',
		'fd',
		'address'
	],
	#classVars : [
		'MAP_FILE',
		'MAP_SHARED',
		'MS_SYNC',
		'O_CREAT',
		'O_RDWR',
		'PROT_READ',
		'PROT_WRITE',
		'S_IRUSR',
		'S_IWUSR',
		'mode_t',
		'off_t'
	],
	#category : 'SharedObjects-IO',
	#package : 'SharedObjects-IO'
}

{ #category : 'class initialization' }
ShUnixMemoryMappedFile class >> initialize [

	O_CREAT := 16r00000200.
	O_RDWR := 16r0002.
	
	S_IRUSR := 8r0400.
	S_IWUSR := 8r0200.

	mode_t := FFIInt16.
	off_t := FFIInt64.
	 
	PROT_READ  := 1.
	PROT_WRITE := 2.
	MAP_FILE   := 0.
	MAP_SHARED := 1.
	MS_SYNC := 16r0010.
]

{ #category : 'accessing' }
ShUnixMemoryMappedFile >> address [
	^ address
]

{ #category : 'as yet unclassified' }
ShUnixMemoryMappedFile >> closeFile [
	
	LibC uniqueInstance close: fd. 
	fd := nil.
]

{ #category : 'library path' }
ShUnixMemoryMappedFile >> ffiLibraryName [ 

	^ LibC
]

{ #category : 'accessing' }
ShUnixMemoryMappedFile >> filePath: aString [ 
	filePath := aString
]

{ #category : 'as yet unclassified' }
ShUnixMemoryMappedFile >> mapInMemory [

	address := self
		           mmap: ExternalAddress null
		           size: size
		           prot: PROT_READ | PROT_WRITE
		           flags: MAP_FILE | MAP_SHARED
		           fd: fd
		           offset: 0.
		
	address asInteger = ((1 << (Smalltalk wordSize * 8)) - 1) 
		ifTrue: [ self error ].
]

{ #category : 'as yet unclassified' }
ShUnixMemoryMappedFile >> mmap: address size: size prot: prot flags: flags fd: fd offset: offset [ 
	
	self ffiCall: #(void* mmap(void* address, size_t size, int prot, int flags, int fd, off_t offset))
]

{ #category : 'as yet unclassified' }
ShUnixMemoryMappedFile >> msync: anAddress size: aSize flags: flags [ 
	
	self ffiCall: #(int msync(void* anAddress, size_t aSize, int flags))
]

{ #category : 'as yet unclassified' }
ShUnixMemoryMappedFile >> munmap: anAddress size: aSize [ 

		self ffiCall:#(int munmap(void* anAddress, size_t aSize))

]

{ #category : 'as yet unclassified' }
ShUnixMemoryMappedFile >> open: path flags: flags mode: mode [ 
	
	^ self ffiCall: #(int open(char* path, int flags, mode_t mode))
]

{ #category : 'as yet unclassified' }
ShUnixMemoryMappedFile >> openFile [
		
	fd := self open: filePath flags: O_RDWR mode: 0.
	
	fd < 0 ifTrue: [ self error ].
]

{ #category : 'accessing' }
ShUnixMemoryMappedFile >> size [
	
	^ size
]

{ #category : 'accessing' }
ShUnixMemoryMappedFile >> size: anInteger [ 
	size := anInteger
]

{ #category : 'public' }
ShUnixMemoryMappedFile >> sync [
	
	^ self msync: address size: size flags: MS_SYNC.
]

{ #category : 'as yet unclassified' }
ShUnixMemoryMappedFile >> unmap [

	| r |
	r := self munmap: address size: size.
	address beNull.
	
	^ r 
]
