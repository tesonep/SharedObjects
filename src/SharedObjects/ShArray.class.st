Class {
	#name : 'ShArray',
	#superclass : 'ArrayedCollection',
	#traits : 'TShObject',
	#classTraits : 'TShObject classTrait',
	#category : 'SharedObjects-BaseClasses',
	#package : 'SharedObjects',
	#tag : 'BaseClasses'
}

{ #category : 'instance creation' }
ShArray class >> new [

	^ self new: 0
]

{ #category : 'instance creation' }
ShArray class >> new: aSize [

	^ self new: aSize in: ShDefaultObjectSpace value
]

{ #category : 'instance creation' }
ShArray class >> new: aSize in: objectSpace [

	^ objectSpace allocateInstanceOf: self withPointers: aSize
]

{ #category : 'instance creation' }
ShArray class >> newIn: objectSpace [

	^ self new: 0 in: objectSpace 
]

{ #category : 'accessing' }
ShArray >> at: anIndex [

	anIndex isInteger ifFalse: [ self errorNonIntegerIndex ].
	anIndex < 1 ifTrue: [ self errorSubscriptBounds: anIndex ].
	anIndex > reference size ifTrue: [ self errorSubscriptBounds: anIndex ].
	
	^ reference readAt: anIndex

]

{ #category : 'accessing' }
ShArray >> at: anIndex put: aValue [

	anIndex isInteger ifFalse: [ self errorNonIntegerIndex ].
	anIndex < 1 ifTrue: [ self errorSubscriptBounds: anIndex ].
	anIndex > reference size ifTrue: [ self errorSubscriptBounds: anIndex ].
	
	^ reference writeAt: anIndex value: aValue

]

{ #category : 'accessing' }
ShArray >> size [

	^ reference size
]
