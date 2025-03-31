Class {
	#name : 'ShByteStringTest',
	#superclass : 'ShAbstractTest',
	#category : 'SharedObjects-Tests',
	#package : 'SharedObjects-Tests'
}

{ #category : 'instance creation' }
ShByteStringTest >> newString: aString [ 
	
	^ useDefault 
		ifTrue: [ ShByteString from: aString ]
		ifFalse: [ ShByteString from: aString in: objectSpace ]

]

{ #category : 'tests' }
ShByteStringTest >> testStringGivesCorrectSize [

	| str |

	str := self newString: 'abc'.
	self assert: str size equals: 3.
	self assertCollection: str hasSameElements: 'abc'
]
