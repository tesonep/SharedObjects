Class {
	#name : 'ShUnixMemoryMappedFile',
	#superclass : 'Object',
	#instVars : [
		'filePath',
		'size',
		'fd',
		'address'
	],
	#pools : [
		'ShUnixConstants',
		'ShUnixTypes'
	],
	#category : 'SharedObjects-IO',
	#package : 'SharedObjects-IO'
}

{ #category : 'accessing' }
ShUnixMemoryMappedFile >> address [
	^ address
]

{ #category : 'public' }
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

{ #category : 'public' }
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

{ #category : 'private - ffi' }
ShUnixMemoryMappedFile >> mmap: address size: size prot: prot flags: flags fd: fd offset: offset [ 
	
	self ffiCall: #(void* mmap(void* address, size_t size, int prot, int flags, int fd, off_t offset))
]

{ #category : 'private - ffi' }
ShUnixMemoryMappedFile >> msync: anAddress size: aSize flags: flags [ 
	
	self ffiCall: #(int msync(void* anAddress, size_t aSize, int flags))
]

{ #category : 'private - ffi' }
ShUnixMemoryMappedFile >> munmap: anAddress size: aSize [ 

		self ffiCall:#(int munmap(void* anAddress, size_t aSize))

]

{ #category : 'private - ffi' }
ShUnixMemoryMappedFile >> open: path flags: flags mode: mode [ 
	
	^ self ffiCall: #(int open(char* path, int flags, mode_t mode))
]

{ #category : 'public' }
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

{ #category : 'public' }
ShUnixMemoryMappedFile >> unmap [

	| r |
	r := self munmap: address size: size.
	address beNull.
	
	^ r 
]
