Class {
	#name : 'ShAbstractTest',
	#superclass : 'ParametrizedTestCase',
	#instVars : [
		'useDefault',
		'objectSpace',
		'oldDefault',
		'useExternalMemory'
	],
	#category : 'SharedObjects-Tests',
	#package : 'SharedObjects-Tests'
}

{ #category : 'building suites' }
ShAbstractTest class >> testParameters [ 

	^ ParametrizedTestMatrix new
		forSelector: #useDefault addOptions: { true. false };
		forSelector: #useExternalMemory addOptions: { true. false };
		yourself
]

{ #category : 'instance creation' }
ShAbstractTest >> instantiate: aClass [

	^ useDefault
		  ifTrue: [ aClass new ]
		  ifFalse: [ aClass newIn: objectSpace ]
]

{ #category : 'running' }
ShAbstractTest >> newArray: size [
	
	^ useDefault 
		ifTrue: [ ShArray new: 17 ]
		ifFalse: [ ShArray new: 17 in: objectSpace ]
	
	
	
]

{ #category : 'running' }
ShAbstractTest >> newString: aString [
	
	^ useDefault 
		ifTrue: [ ShByteString from: aString ]
		ifFalse: [ ShByteString from: aString in: objectSpace ]
	
	
	
]

{ #category : 'running' }
ShAbstractTest >> setUp [

	super setUp.

	objectSpace := useExternalMemory
		               ifTrue: [ ShObjectSpace externalNew ]
		               ifFalse: [ ShObjectSpace new ].

	oldDefault := ShDefaultObjectSpace value.

	useDefault ifTrue: [ ShDefaultObjectSpace value: objectSpace ]
]

{ #category : 'running' }
ShAbstractTest >> tearDown [ 

	ShDefaultObjectSpace value: oldDefault.
	objectSpace ifNotNil: #free.
	
	super tearDown
]

{ #category : 'running' }
ShAbstractTest >> useDefault: aValue [

	useDefault := aValue
]

{ #category : 'running' }
ShAbstractTest >> useExternalMemory: aValue [

	useExternalMemory := aValue
]
