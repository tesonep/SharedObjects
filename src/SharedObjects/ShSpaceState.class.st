Class {
	#name : 'ShSpaceState',
	#superclass : 'ShObject',
	#instVars : [
		'#freeStart => ShSlot',
		'#memorySize => ShSlot',
		'#lastBaseClassesIndex => ShSlot',
		'#classTable => ShSlot',
		'#rootObject => ShSlot'
	],
	#category : 'SharedObjects-HiddenObjects',
	#package : 'SharedObjects',
	#tag : 'HiddenObjects'
}

{ #category : 'testing' }
ShSpaceState class >> isHiddenObject [

	^ true
]

{ #category : 'accessing' }
ShSpaceState >> classIndexFor: aClass [

	| theClassTable className |
	
	theClassTable := classTable.

	1 to: theClassTable size do: [ :index |
		(className := theClassTable at: index)
			ifNotNil: [
			aClass name = className ifTrue: [ ^ index + lastBaseClassesIndex ] ]
			ifNil: [
				theClassTable at: index put: (ShHiddenByteString from: aClass name in: reference objectSpace).
				^ index + lastBaseClassesIndex ] ].
	
	self error: 'Class Table is full'
]

{ #category : 'accessing' }
ShSpaceState >> classTable: aCollection [ 
	classTable := aCollection
]

{ #category : 'as yet unclassified' }
ShSpaceState >> fetchClassForIndex: anInteger [ 
	
	| index |
	index := anInteger - lastBaseClassesIndex.
	^ self class environment classNamed: (classTable at: index) asSymbol
]

{ #category : 'accessing' }
ShSpaceState >> freeStart [
	^ freeStart
]

{ #category : 'accessing' }
ShSpaceState >> freeStart: anInteger [ 

	freeStart := anInteger
]

{ #category : 'accessing' }
ShSpaceState >> lastBaseClassesIndex: anInteger [ 
	lastBaseClassesIndex := anInteger
]

{ #category : 'accessing' }
ShSpaceState >> memorySize [
	^ memorySize
]

{ #category : 'accessing' }
ShSpaceState >> memorySize: anInteger [ 
	memorySize := anInteger
]

{ #category : 'accessing' }
ShSpaceState >> rootObject [
	^ rootObject
]

{ #category : 'accessing' }
ShSpaceState >> rootObject: aCollection [ 
	rootObject := aCollection
]
