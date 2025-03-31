Class {
	#name : 'ShReference',
	#superclass : 'Object',
	#instVars : [
		'objectSpace',
		'address',
		'size'
	],
	#category : 'SharedObjects-Core',
	#package : 'SharedObjects',
	#tag : 'Core'
}

{ #category : 'accessing' }
ShReference >> address [
	^ address
]

{ #category : 'accessing' }
ShReference >> address: anInteger [ 
	address := anInteger
]

{ #category : 'as yet unclassified' }
ShReference >> indexableByteSize [

	^ objectSpace indexableByteSizeOf: address
]

{ #category : 'accessing' }
ShReference >> objectSpace [
	^ objectSpace
]

{ #category : 'accessing' }
ShReference >> objectSpace: aShObjectSpace [ 
	objectSpace := aShObjectSpace
]

{ #category : 'accessing' }
ShReference >> readAt: anInteger [ 
	
	anInteger > size ifTrue: [ Error signal: 'Index out of bounds' ].
	^ objectSpace readAtAddress: address slot: anInteger 
]

{ #category : 'accessing' }
ShReference >> readByteAt: anInteger [ 
	
	anInteger > self indexableByteSize ifTrue: [ Error signal: 'Index out of bounds' ].
	^ objectSpace readAtAddress: address byte: anInteger 
]

{ #category : 'accessing' }
ShReference >> size [

	^ size
]

{ #category : 'accessing' }
ShReference >> size: anInteger [ 
	size := anInteger
]

{ #category : 'accessing' }
ShReference >> writeAt: slotIndex value: aValue [

	objectSpace writeAtAddress: address slot: slotIndex value: aValue
]

{ #category : 'accessing' }
ShReference >> writeByteAt: anIndex value: aValue [

	anIndex > self indexableByteSize ifTrue: [ Error signal: 'Index out of bounds' ].
	objectSpace writeAtAddress: address byteIndex: anIndex value: aValue
]
