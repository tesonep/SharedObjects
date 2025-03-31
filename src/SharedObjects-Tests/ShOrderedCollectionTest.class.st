Class {
	#name : 'ShOrderedCollectionTest',
	#superclass : 'ShAbstractTest',
	#category : 'SharedObjects-Tests',
	#package : 'SharedObjects-Tests'
}

{ #category : 'tests' }
ShOrderedCollectionTest >> testAdding100Items [

	| col objs |
	
	col := self instantiate: ShOrderedCollection.
	objs := OrderedCollection new: 100.

	1 to: 100 do: [ :index | 
		| o |
		o := self instantiate: ShObject.
		objs add: o.
		col add: o ].

	self assert: col size equals: 100.	

	1 to: 100 do: [ :index |
		self assert: (col at: index) equals: (objs at: index).
	 ].
]

{ #category : 'tests' }
ShOrderedCollectionTest >> testEmptyCollection [

	| col |
	
	col := self instantiate: ShOrderedCollection.

	self assert: col isEmpty.
	self assert: col size equals: 0.

]
