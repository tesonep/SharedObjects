Class {
	#name : 'ShObjectTest',
	#superclass : 'ShAbstractTest',
	#category : 'SharedObjects-Tests',
	#package : 'SharedObjects-Tests'
}

{ #category : 'tests' }
ShObjectTest >> testInitializeIsCalled [

	| obj |
	obj := self instantiate: ShTestObject.

	self assert: obj x equals: 23.

]

{ #category : 'tests' }
ShObjectTest >> testInstanciateObject [

	| obj |
	obj := self instantiate: ShObject.

	self assert: obj isNotNil.
	self assert: obj class isSharedObject 
]

{ #category : 'tests' }
ShObjectTest >> testInstanciateTwoObjects [

	| obj1 obj2 |

	obj1 := self instantiate: ShTestObject.
	obj2 := self instantiate: ShObject.

	self assert: objectSpace allObjects size equals: 2.
	self assert: (objectSpace allObjects first) equals: obj1.
	self assert: (objectSpace allObjects second) equals: obj2.
]

{ #category : 'tests' }
ShObjectTest >> testInstantiateObjectWithTwoVariables [

	| obj |
	obj := self instantiate: ShTestObject.

	self assert: (objectSpace sizeOf: obj) equals: 3.

]

{ #category : 'tests' }
ShObjectTest >> testUninitializedVariableIsNil [

	| obj |
	obj := self instantiate: ShTestObject.

	self assert: obj nilValue equals: nil.

]
