Class {
	#name : 'ShDictionaryTest',
	#superclass : 'ShAbstractTest',
	#category : 'SharedObjects-Tests',
	#package : 'SharedObjects-Tests'
}

{ #category : 'tests' }
ShDictionaryTest >> testAddElements [

	| col a b c d |
	
	col := self instantiate: ShDictionary.

	col at: 23 put: (a := self instantiate: ShTestObject).
	col at: 17 put: (b := self instantiate: ShTestObject).	
	col at: (c := self instantiate: ShObject) put: (d := ShByteString from: 'abc' in: objectSpace).
	
	self assert: (col at: 23) equals: a.
	self assert: (col at: 17) equals: b.	
	self assert: (col at: c) equals: d.
	self assert: col size equals: 3.
]

{ #category : 'tests' }
ShDictionaryTest >> testEmpty [

	| col |
	
	col := self instantiate: ShDictionary.

	self assert: col isEmpty.
	self assert: col size equals: 0.

]
