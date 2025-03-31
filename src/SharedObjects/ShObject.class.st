Class {
	#name : 'ShObject',
	#superclass : 'Object',
	#traits : 'TShObject',
	#classTraits : 'TShObject classTrait',
	#category : 'SharedObjects-BaseClasses',
	#package : 'SharedObjects',
	#tag : 'BaseClasses'
}

{ #category : 'comparing' }
ShObject >> = anotherObject [

	self class = anotherObject class ifFalse: [ ^ false ].

	^ self reference address = anotherObject reference address and: [
		  self reference objectSpace = anotherObject reference objectSpace ]
]

{ #category : 'comparing' }
ShObject >> hash [

	^ self reference address hash
]
