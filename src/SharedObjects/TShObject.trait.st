Trait {
	#name : 'TShObject',
	#instVars : [
		'reference'
	],
	#category : 'SharedObjects-Core',
	#package : 'SharedObjects',
	#tag : 'Core'
}

{ #category : 'testing' }
TShObject classSide >> isHiddenObject [	

	^ false
]

{ #category : 'testing' }
TShObject classSide >> isSharedObject [
	
	^ true
]

{ #category : 'instance creation' }
TShObject classSide >> new [

	^ self newIn: ShDefaultObjectSpace value
]

{ #category : 'instance creation' }
TShObject classSide >> newIn: aShObjectSpace [

	^ (aShObjectSpace allocateInstanceOf: self)
		  initialize;
		  yourself
]

{ #category : 'as yet unclassified' }
TShObject classSide >> realNewWithReference: aShReference [ 
	
	^ self basicNew
		reference: aShReference;
		yourself
]

{ #category : 'as yet unclassified' }
TShObject classSide >> sharedSlots [
	
	^ self allSlots select: [ :e | e isKindOf: ShSlot ]
]

{ #category : 'accessing' }
TShObject >> reference [
	
	^ reference
]

{ #category : 'accessing' }
TShObject >> reference: aShReference [ 
	reference := aShReference
]
