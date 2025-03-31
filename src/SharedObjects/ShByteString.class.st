Class {
	#name : 'ShByteString',
	#superclass : 'String',
	#traits : 'TShObject',
	#classTraits : 'TShObject classTrait',
	#category : 'SharedObjects-BaseClasses',
	#package : 'SharedObjects',
	#tag : 'BaseClasses'
}

{ #category : 'instance creation' }
ShByteString class >> from: aString [ 
	
	^ self from: aString in: ShDefaultObjectSpace value
]

{ #category : 'instance creation' }
ShByteString class >> from: aString in: aShObjectSpace [

	| inst |
	
	inst := aShObjectSpace allocateInstanceOf: self withBytes: aString size.
	aString withIndexDo: [ :char :index | inst at: index put: ((char isOctetCharacter) ifTrue:[ char] ifFalse: [ Character space ]) ].
	^ inst

]

{ #category : 'accessing' }
ShByteString >> at: anIndex [

	anIndex isInteger ifFalse: [ self errorNonIntegerIndex ].
	anIndex < 1 ifTrue: [ self errorSubscriptBounds: anIndex ].
	anIndex > reference indexableByteSize ifTrue: [ self errorSubscriptBounds: anIndex ].
	
	^ (reference readByteAt: anIndex) asCharacter 

]

{ #category : 'accessing' }
ShByteString >> at: anIndex put: aCharacter [

	anIndex isInteger ifFalse: [ self errorNonIntegerIndex ].
	anIndex < 1 ifTrue: [ self errorSubscriptBounds: anIndex ].
	anIndex > reference indexableByteSize ifTrue: [ self errorSubscriptBounds: anIndex ].
	
	^ reference writeByteAt: anIndex value: aCharacter codePoint

]

{ #category : 'accessing' }
ShByteString >> basicAt: anIndex [

	anIndex isInteger ifFalse: [ self errorNonIntegerIndex ].
	anIndex < 1 ifTrue: [ self errorSubscriptBounds: anIndex ].
	anIndex > reference indexableByteSize ifTrue: [ self errorSubscriptBounds: anIndex ].
	
	^ reference readByteAt: anIndex

]

{ #category : 'accessing' }
ShByteString >> size [

	^ reference indexableByteSize
]
