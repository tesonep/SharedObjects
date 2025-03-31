"
I represent a pair of associated objects--a key and a value. My instances can serve as entries in a dictionary.


Implementation notes: 
Note that hash is not redefined even if the = was redefined because Association>>hash may cause extreme slowdowns in compiling Unicode methods. Association>>hash does not need to hash the value; it's slow and useless.


"
Class {
	#name : 'ShAssociation',
	#superclass : 'ShLookupKey',
	#instVars : [
		'#value => ShSlot'
	],
	#category : 'SharedObjects-BaseClasses',
	#package : 'SharedObjects',
	#tag : 'BaseClasses'
}

{ #category : 'instance creation' }
ShAssociation class >> key: newKey value: newValue [
	"Answer an instance of me with the arguments as the key and value of
	the association."

	^self basicNew key: newKey value: newValue
]

{ #category : 'as yet unclassified' }
ShAssociation class >> key: aKey value: aValue in: aShObjectSpace [ 
	
	^ (self newIn: aShObjectSpace)
		key: aKey value: aValue;
		yourself 
]

{ #category : 'comparing' }
ShAssociation >> = anAssociation [

	^ super = anAssociation and: [value = anAssociation value]
]

{ #category : 'testing' }
ShAssociation >> analogousCodeTo: anAssociation [
	^ self = anAssociation
]

{ #category : 'testing' }
ShAssociation >> hasLiteral: aLiteral [
	^false
]

{ #category : 'variables-toclean' }
ShAssociation >> isAssociation [
	^ true
]

{ #category : 'self evaluating' }
ShAssociation >> isSelfEvaluating [
	^ self class == ShAssociation and: [self key isSelfEvaluating and: [self value isSelfEvaluating]]
]

{ #category : 'variables-toclean' }
ShAssociation >> isVariableBinding [
	"Can be removed as soon as all bindings are instances of LiteralVariable"
	^true
]

{ #category : 'accessing' }
ShAssociation >> key: aKey value: anObject [
	"Store the arguments as the variables of the receiver."

	key := aKey.
	value := anObject
]

{ #category : 'comparing' }
ShAssociation >> literalEqual: otherLiteral [
	"Answer true if the receiver and otherLiteral represent the same literal.
	Variable bindings are literally equals only if identical.
	This is how variable sharing works, by preserving identity and changing only the value."
	^self == otherLiteral
]

{ #category : 'printing' }
ShAssociation >> printOn: aStream [

	super printOn: aStream.
	aStream nextPutAll: '->'.
	value printOn: aStream
]

{ #category : 'storing' }
ShAssociation >> storeOn: aStream [
	"Store in the format (key->value)"
	aStream nextPut: $(.
	key storeOn: aStream.
	aStream nextPutAll: '->'.
	value storeOn: aStream.
	aStream nextPut: $)
]

{ #category : 'evaluating' }
ShAssociation >> value [
	"Answer the value of the receiver."

	^value
]

{ #category : 'accessing' }
ShAssociation >> value: anObject [
	"Store the argument, anObject, as the value of the receiver."

	value := anObject
]
