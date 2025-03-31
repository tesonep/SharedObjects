Class {
	#name : 'ShSharingSpaceTest',
	#superclass : 'ShAbstractTest',
	#category : 'SharedObjects-Tests',
	#package : 'SharedObjects-Tests'
}

{ #category : 'tests' }
ShSharingSpaceTest >> testSharingSpaceHasObjects [

	| col x otherSpace col2 |
	
	col := self instantiate: ShOrderedCollection.
	col add: (self instantiate: ShObject).
	col add: (self newString: 'Abcde').
	
	x := self instantiate: ShTestObject.
	col add: x.
	
	x x: 23.
	x y: 17.

	objectSpace rootObject: col.
	
	self assert: objectSpace allObjects size equals: 5.
	
	otherSpace := ShObjectSpace openOnExistingMemory: objectSpace memory withSize: objectSpace size.

	col2 := otherSpace rootObject.

	self assert: col2 size equals: col size.
	self assert: (col2 at: 3) x equals: 23.
	self assert: (col2 at: 3) y equals: 17	
]

{ #category : 'tests' }
ShSharingSpaceTest >> testSharingSpaceHasSameNumberOfObjects [

	| col x otherSpace |
	
	col := self instantiate: ShOrderedCollection.
	col add: (self instantiate: ShObject).
	col add: (self newString: 'Abcde').
	
	x := self instantiate: ShTestObject.
	col add: x.
	
	x x: 23.
	x y: 17.

	objectSpace rootObject: col.

	self assert: objectSpace allObjects size equals: 5.
	
	otherSpace := ShObjectSpace openOnExistingMemory: objectSpace memory withSize: objectSpace size.

	self assert: otherSpace allObjects size equals: 5.

]
