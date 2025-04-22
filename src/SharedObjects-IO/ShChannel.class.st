Class {
	#name : 'ShChannel',
	#superclass : 'Object',
	#instVars : [
		'memory',
		'accessMutex',
		'sendSemaphore',
		'receiveSemaphore'
	],
	#classVars : [
		'BUFFER_OFFSET',
		'FIELD_SIZE',
		'MAX_SIZE_OFFSET',
		'REMAINING_DATA_OFFSET',
		'STATUS_CLOSED',
		'STATUS_OFFSET',
		'USED_SIZE_OFFSET'
	],
	#category : 'SharedObjects-IO',
	#package : 'SharedObjects-IO'
}

{ #category : 'as yet unclassified' }
ShChannel class >> forSameImage [
	
	^ self forSameImageWithSize: 1024
]

{ #category : 'as yet unclassified' }
ShChannel class >> forSameImageWithSize: aSize [
	
	^ self new
		initializeMemory: (ByteArray new: aSize) withSize: aSize;
		accessMutex: Mutex new;
		sendSemaphore: (Semaphore new signal; yourself);
		receiveSemaphore: Semaphore new;
		yourself
]

{ #category : 'class initialization' }
ShChannel class >> initialize [

	FIELD_SIZE := 8.

	MAX_SIZE_OFFSET := 0.
	USED_SIZE_OFFSET := MAX_SIZE_OFFSET + FIELD_SIZE.
	REMAINING_DATA_OFFSET := USED_SIZE_OFFSET + FIELD_SIZE.
	STATUS_OFFSET := REMAINING_DATA_OFFSET + FIELD_SIZE.
	
	BUFFER_OFFSET := STATUS_OFFSET + FIELD_SIZE.
	
	STATUS_CLOSED := 1.
]

{ #category : 'accessing' }
ShChannel >> accessMutex: aMutex [ 
	accessMutex := aMutex
]

{ #category : 'accessing' }
ShChannel >> atEnd [
	
	^ accessMutex critical: [ self closed and: [ self usedSize = 0 ]]
]

{ #category : 'streams' }
ShChannel >> binaryReadStreamDo: aBlock [ 
	
	| stream |
	stream := ZnBufferedReadStream on: self.

	^ [ aBlock value: stream ]
		ensure: [ stream close ]
]

{ #category : 'streams' }
ShChannel >> binaryWriteStream [

	^ ZnBufferedWriteStream on: self
]

{ #category : 'streams' }
ShChannel >> binaryWriteStreamDo: aBlock [ 
	
	| stream |
	stream := self binaryWriteStream.

	^ [ aBlock value: stream ]
		ensure: [ stream close ]
]

{ #category : 'initialization' }
ShChannel >> close [
	
	^ accessMutex critical: [ self status: STATUS_CLOSED ]
]

{ #category : 'initialization' }
ShChannel >> closed [
	
	^ self status = STATUS_CLOSED
]

{ #category : 'accessing' }
ShChannel >> doSend: numberOfBytes from: from startingIndex: startingIndex [

	| actualSendBytes |
	
	sendSemaphore wait.
	accessMutex critical: [
		actualSendBytes := self remainingSize min: numberOfBytes.

		memory
			replaceFrom: BUFFER_OFFSET + self usedSize + 1
			to: actualSendBytes + BUFFER_OFFSET + self usedSize
			with: from
			startingAt: startingIndex.

		self usedSize: self usedSize + actualSendBytes.

		self remainingData: numberOfBytes - actualSendBytes.

		receiveSemaphore signal.
		^ actualSendBytes ]
]

{ #category : 'accessing' }
ShChannel >> flush [
	
	"I have already flushed it"
]

{ #category : 'initialization' }
ShChannel >> initializeMemory: someMemory withSize: memorySize [ 
	
	memory := someMemory.
	
	self maxSize: memorySize - BUFFER_OFFSET.
	self remainingData: 0.
	self usedSize: 0.
	self status: 0.
]

{ #category : 'testing' }
ShChannel >> isBinary [
	
	^ true
]

{ #category : 'accessing' }
ShChannel >> maxSize [
	
	^ memory uint64AtOffset: MAX_SIZE_OFFSET
]

{ #category : 'accessing' }
ShChannel >> maxSize: anInteger [ 
	
	memory uint64AtOffset: MAX_SIZE_OFFSET put: anInteger
]

{ #category : 'accessing' }
ShChannel >> next: numberOfBytes putAll: from startingAt: startingIndex [
	
	| sendBytes |
	
	sendBytes := 0.

	[ sendBytes < numberOfBytes ] whileTrue: [
		sendBytes := sendBytes + (self
			             doSend: numberOfBytes - sendBytes
			             from: from
			             startingIndex: startingIndex + sendBytes) ].
	^ from
]

{ #category : 'accessing' }
ShChannel >> nextPutAll: aCollection [ 
	
	^ self next: aCollection size putAll: aCollection startingAt: 1
]

{ #category : 'accessing' }
ShChannel >> readInto: aCollection startingAt: startingIndex count: count [ 
	
	| actualCount fromPosition fromLimit toPosition |
	
	receiveSemaphore wait.
	
	accessMutex critical: [  
		
		actualCount := self usedSize min: count.
			
		fromPosition := BUFFER_OFFSET.
		fromLimit := BUFFER_OFFSET + actualCount.
		toPosition := startingIndex - 1.

		[fromPosition < fromLimit] 
			whileTrue: [ 
				aCollection uint8AtOffset: toPosition put: (memory uint8AtOffset: fromPosition).
				toPosition := toPosition + 1.
				fromPosition := fromPosition + 1 ].
				
		self usedSize: self usedSize - actualCount.
		
		sendSemaphore signal.
		
		^ actualCount.
		]
]

{ #category : 'accessing' }
ShChannel >> receiveSemaphore: aCollection [ 
	receiveSemaphore := aCollection
]

{ #category : 'as yet unclassified' }
ShChannel >> remainingData [
	
	^ memory uint64AtOffset: REMAINING_DATA_OFFSET
]

{ #category : 'as yet unclassified' }
ShChannel >> remainingData: anInteger [ 
	
	memory uint64AtOffset: REMAINING_DATA_OFFSET put: anInteger
]

{ #category : 'as yet unclassified' }
ShChannel >> remainingSize [
	
	^ self maxSize - self usedSize
]

{ #category : 'accessing' }
ShChannel >> sendSemaphore: aCollection [ 
	sendSemaphore := aCollection
]

{ #category : 'as yet unclassified' }
ShChannel >> status [
	
	^ memory uint64AtOffset: STATUS_OFFSET
]

{ #category : 'as yet unclassified' }
ShChannel >> status: anInteger [ 
	
	memory uint64AtOffset: STATUS_OFFSET put: anInteger
]

{ #category : 'as yet unclassified' }
ShChannel >> usedSize [
	
	^ memory uint64AtOffset: USED_SIZE_OFFSET
]

{ #category : 'as yet unclassified' }
ShChannel >> usedSize: anInteger [ 
	
	memory uint64AtOffset: USED_SIZE_OFFSET put: anInteger
]
