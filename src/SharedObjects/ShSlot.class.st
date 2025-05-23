Class {
	#name : 'ShSlot',
	#superclass : 'Slot',
	#instVars : [
		'offset'
	],
	#category : 'SharedObjects-Core',
	#package : 'SharedObjects',
	#tag : 'Core'
}

{ #category : 'class building' }
ShSlot >> installingIn: aClass [

	| booleanSlots |
	super installingIn: aClass.

	"my offset in the base slot is defined by the order of all BooleanSlots in the Hierarchy"
	booleanSlots := aClass allSlots select: [ :each | each isKindOf: self class ].
	offset := booleanSlots indexOf: self
]

{ #category : 'accessing' }
ShSlot >> offset [
	
	| shSlots |
	
	offset ifNotNil: [ ^ offset ].
	
	shSlots := owningClass allSlots select: [ :each | each isKindOf: self class ].
	offset := shSlots indexOf: self.
	
	^ offset
]

{ #category : 'meta-object-protocol' }
ShSlot >> read: aShTestObject [ 
	
	^ aShTestObject reference readAt: self offset
]

{ #category : 'meta-object-protocol' }
ShSlot >> write: aValue to: anObject [ 
	
	anObject reference writeAt: self offset value: aValue
]
