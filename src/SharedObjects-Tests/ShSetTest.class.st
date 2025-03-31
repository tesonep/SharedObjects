Class {
	#name : 'ShSetTest',
	#superclass : 'ShAbstractTest',
	#category : 'SharedObjects-Tests',
	#package : 'SharedObjects-Tests'
}

{ #category : 'tests' }
ShSetTest >> testAdding100Items [

	| col objs |
	
	col := self instantiate: ShOrderedCollection.
	objs := OrderedCollection new: 100.

	1 to: 100 do: [ :index | 
		| o |
		o := self instantiate: ShObject.
		objs add: o.
		col add: o ].

	self assert: col size equals: 100.	

]

{ #category : 'tests' }
ShSetTest >> testAddingDuplicatedElement [

	| col o |
	
	col := self instantiate: ShSet.

	o := self instantiate: ShTestObject.
	col add: o.
	col add: o.
	
	self assert: col size equals: 1.
	self assert: (col includes: o)
]

{ #category : 'tests' }
ShSetTest >> testEmptyCollection [

	| col |
	
	col := self instantiate: ShSet.

	self assert: col isEmpty.
	self assert: col size equals: 0.

]
