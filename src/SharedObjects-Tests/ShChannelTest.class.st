Class {
	#name : 'ShChannelTest',
	#superclass : 'TestCase',
	#instVars : [
		'channel'
	],
	#category : 'SharedObjects-Tests',
	#package : 'SharedObjects-Tests'
}

{ #category : 'as yet unclassified' }
ShChannelTest >> forkFuelReaderOn: aShChannel onRead: readBlock onFinish: finishBlock [ 

	[
		aShChannel binaryReadStreamDo: [ :bufferedReadStream |
			[bufferedReadStream atEnd] 
				whileFalse: [ readBlock value: (FLMaterializer materializeFrom: bufferedReadStream) ]
		].
	
		finishBlock value.
	] fork.

]

{ #category : 'as yet unclassified' }
ShChannelTest >> forkReaderOn: aShChannel onRead: readBlock onFinish: finishBlock [ 

	[
		| readStream readText |
		aShChannel binaryReadStreamDo: [ :bufferedReadStream |
			readStream := ZnCharacterReadStream on: bufferedReadStream encoding: 'utf8'.
			readText := readStream upToEnd		
		].

		readBlock value: readText.
		finishBlock value.
	] fork.

]

{ #category : 'as yet unclassified' }
ShChannelTest >> forkWriterOn: aShChannel write: sendText [

	[
		| writeStream |
		aShChannel binaryWriteStreamDo: [ :bufferedWriteStream |
			writeStream := ZnCharacterWriteStream
				               on: bufferedWriteStream
				               encoding: 'utf8'.
			writeStream nextPutAll: sendText ] ] fork
]

{ #category : 'tests' }
ShChannelTest >> setUp [

	super setUp.

	channel := ShChannel forSameImage.
]

{ #category : 'tests' }
ShChannelTest >> testSendAndReceiveData [

	| sendText readText stream semaphore |

	sendText := String loremIpsum: 50.
	stream := WriteStream on: (String new: sendText size).
	semaphore := Semaphore new.

	self forkWriterOn: channel write: sendText.
	
	self 
		forkReaderOn: channel 
		onRead: [ :value | stream nextPutAll: value ]
		onFinish: [ semaphore signal ].
	
	semaphore wait.
	readText := stream contents.
		
	self assert: readText equals: sendText
]

{ #category : 'tests' }
ShChannelTest >> testSendAndReceiveLongData [

	| sendText readText stream semaphore |

	sendText := String loremIpsum: 100000.
	stream := WriteStream on: (String new: sendText size).
	semaphore := Semaphore new.

	self forkWriterOn: channel write: sendText.
	
	self 
		forkReaderOn: channel 
		onRead: [ :value | stream nextPutAll: value ]
		onFinish: [ semaphore signal ].
	
	semaphore wait.
	readText := stream contents.
		
	self assert: readText equals: sendText
]

{ #category : 'tests' }
ShChannelTest >> testSendFuelContent [

	| elements stream semaphore |

	stream := WriteStream on: OrderedCollection new.
	semaphore := Semaphore new.

	[	
		channel binaryWriteStreamDo: [: writeStream | 
			FLSerializer serialize: 1.0 on: writeStream.
			FLSerializer serialize: 2.0 on: writeStream.
	] ]fork.
		

	self 
		forkFuelReaderOn: channel 
		onRead: [ :value | stream nextPut: value ]
		onFinish: [ semaphore signal ].

	semaphore wait.
	elements := stream contents.
		
	self assertCollection: elements hasSameElements: { 1.0 . 2.0 }
]

{ #category : 'tests' }
ShChannelTest >> testSharedChannelLargerThanBuffer [

	| sendText readText stream semaphore |

	channel := ShChannel forSameImageWithSize: 1 * (1024 * 1024).

	sendText := String loremIpsum: 100000.
	stream := WriteStream on: (String new: sendText size).
	semaphore := Semaphore new.

	self forkWriterOn: channel write: sendText.
	
	self 
		forkReaderOn: channel 
		onRead: [ :value | stream nextPutAll: value ]
		onFinish: [ semaphore signal ].
	
	semaphore wait.
	readText := stream contents.
		
	self assert: readText equals: sendText
]
