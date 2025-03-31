Class {
	#name : 'ShArrayTest',
	#superclass : 'ShAbstractTest',
	#category : 'SharedObjects-Tests',
	#package : 'SharedObjects-Tests'
}

{ #category : 'running' }
ShArrayTest >> testArrayHasCorrectSize [

	| array |
	
	array := self newArray: 17.
	self assert: array size equals: 17. 
]

{ #category : 'running' }
ShArrayTest >> testArrayIsInitializedInNil [

	| array |
	
	array := self newArray: 17.
	array do: [ :e | self assert: e isNil ]
]

{ #category : 'running' }
ShArrayTest >> testStoringANegativeSmallInteger [

	| array |
	
	array := self newArray: 1.
	array at: 1 put: -42.
	self assert: (array at: 1) equals: -42
	
]

{ #category : 'running' }
ShArrayTest >> testStoringASmallInteger [

	| array |
	
	array := self newArray: 1.
	array at: 1 put: 42.
	self assert: (array at: 1) equals: 42
	
]

{ #category : 'running' }
ShArrayTest >> testStoringAnObjectInside [

	| array anotherArray |
	
	array := self newArray: 1.
	anotherArray := self newArray: 2.
	
	array at: 1 put: anotherArray.

	self assert: array first equals: anotherArray.
	
]

{ #category : 'running' }
ShArrayTest >> testStoringFloat [

	| array |
	
	array := self newArray: 1.
	array at: 1 put: 1.5.

	self assert: array first equals: 1.5.
	
]

{ #category : 'running' }
ShArrayTest >> testStoringMaxSmallInteger [

	| array |
	
	array := self newArray: 1.
	array at: 1 put: SmallInteger maxVal.
	self assert: array first equals: SmallInteger maxVal
	
]

{ #category : 'running' }
ShArrayTest >> testStoringMinSmallInteger [

	| array |
	
	array := self newArray: 1.
	array at: 1 put: SmallInteger minVal.
	self assert: array first equals: SmallInteger minVal.
	
]

{ #category : 'running' }
ShArrayTest >> testStoringObject [

	| array obj |
	
	array := self newArray: 1.
	obj := self instantiate: ShObject.
	array at: 1 put: obj.

	self assert: array first equals: obj.
	self assert: array first == obj.
	
]
