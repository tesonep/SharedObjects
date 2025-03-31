"
I represent a key for looking up entries in a data structure. Subclasses of me, such as Association, typically represent dictionary entries.
"
Class {
	#name : 'ShLookupKey',
	#superclass : 'Magnitude',
	#traits : 'TShObject',
	#classTraits : 'TShObject classTrait',
	#instVars : [
		'key'
	],
	#category : 'SharedObjects-BaseClasses',
	#package : 'SharedObjects',
	#tag : 'BaseClasses'
}

{ #category : 'instance creation' }
ShLookupKey class >> key: aKey [
	"Answer an instance of me with the argument as the lookup up."

	^self basicNew key: aKey
]

{ #category : 'testing' }
ShLookupKey >> < aLookupKey [
	"Refer to the comment in Magnitude|<."

	^key < aLookupKey key
]

{ #category : 'comparing' }
ShLookupKey >> = aLookupKey [

	^ self species = aLookupKey species and: [ key = aLookupKey key ]
]

{ #category : 'comparing' }
ShLookupKey >> hash [
	"Hash is reimplemented because = is implemented."

	^key hash
]

{ #category : 'accessing' }
ShLookupKey >> key [
	"Answer the lookup key of the receiver."

	^key
]

{ #category : 'accessing' }
ShLookupKey >> key: anObject [
	"Store the argument, anObject, as the lookup key of the receiver."

	key := anObject
]

{ #category : 'accessing' }
ShLookupKey >> name [

	^ self key isString
		ifTrue: [self key]
		ifFalse: [self key printString]
]

{ #category : 'printing' }
ShLookupKey >> printOn: aStream [

	key printOn: aStream
]
