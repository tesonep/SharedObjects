Class {
	#name : 'ShFileBasedObjectSpace',
	#superclass : 'Object',
	#instVars : [
		'fileReference',
		'mappedFile',
		'objectSpace'
	],
	#category : 'SharedObjects-Core',
	#package : 'SharedObjects',
	#tag : 'Core'
}

{ #category : 'as yet unclassified' }
ShFileBasedObjectSpace class >> forFileReference: aFileReference [

	^ self forFileReference: aFileReference withInitialSize: 256*(1024*1024).
		
]

{ #category : 'as yet unclassified' }
ShFileBasedObjectSpace class >> forFileReference: aFileReference withInitialSize: aSize [

	^ self new
		initializeForFileReference: aFileReference withInitialSize: aSize;
		ensureObjectSpace;
		yourself

		
]

{ #category : 'query' }
ShFileBasedObjectSpace >> allObjects [
	
	self ensureObjectSpace.
	^ objectSpace allObjects 
]

{ #category : 'initialization' }
ShFileBasedObjectSpace >> close [
	
	mappedFile ifNil: [ ^ self ].
	
	mappedFile sync;
		unmap;
		closeFile.
		
	mappedFile := nil.
	objectSpace := nil.
]

{ #category : 'as yet unclassified' }
ShFileBasedObjectSpace >> ensureMappedFile [
	
	mappedFile ifNil: [ mappedFile := self newMappedFile ].
	(mappedFile address isNotNil and: [ mappedFile address isNull not ]) ifTrue: [ ^ self ].
	
	mappedFile filePath: fileReference fullName.
	mappedFile size: fileReference size.
	mappedFile
		openFile;
		mapInMemory.	
]

{ #category : 'as yet unclassified' }
ShFileBasedObjectSpace >> ensureObjectSpace [

	self ensureMappedFile.

	(objectSpace isNotNil and: [ objectSpace isValid ]) ifTrue: [ ^ self ].

	objectSpace := ShObjectSpace
		               openOrCreateOnExistingMemory: mappedFile address
		               withSize: mappedFile size
]

{ #category : 'initialization' }
ShFileBasedObjectSpace >> initializeForFileReference: aFileReference withInitialSize: initialSize [ 
	
	fileReference := aFileReference.
	aFileReference ifExists: [ ^ self ].
	
	"Create empty file"
	aFileReference binaryWriteStreamDo: [ :aStream |
		aStream uint64: 0.
		aStream truncate: initialSize]
]

{ #category : 'as yet unclassified' }
ShFileBasedObjectSpace >> newMappedFile [
		
	^ OSPlatform current isWindows 
		ifTrue: [ ShWinMemoryMappedFile new ]
		ifFalse: [ ShUnixMemoryMappedFile new ]
	
]

{ #category : 'enumerating' }
ShFileBasedObjectSpace >> onSpaceDo: aFullBlockClosure [ 
	
	self ensureObjectSpace.
	ShDefaultObjectSpace value: objectSpace during: aFullBlockClosure
]

{ #category : 'accessing' }
ShFileBasedObjectSpace >> rootObject [
	
	self ensureObjectSpace.
	^ objectSpace rootObject 
]

{ #category : 'accessing' }
ShFileBasedObjectSpace >> rootObject: anObject [ 
	
	self ensureObjectSpace.
	objectSpace rootObject: anObject.
]

{ #category : 'as yet unclassified' }
ShFileBasedObjectSpace >> usedSpace [
	
	self ensureObjectSpace.
	^ objectSpace usedSpace
]
