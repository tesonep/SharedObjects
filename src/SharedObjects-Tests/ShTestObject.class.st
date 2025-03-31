Class {
	#name : 'ShTestObject',
	#superclass : 'ShObject',
	#instVars : [
		'#x => ShSlot',
		'#y => ShSlot',
		'#nilValue => ShSlot'
	],
	#category : 'SharedObjects-Tests',
	#package : 'SharedObjects-Tests'
}

{ #category : 'initialization' }
ShTestObject >> initialize [

	super initialize.

	x := 23.
	y := 72
]

{ #category : 'accessing' }
ShTestObject >> nilValue [
	^ nilValue
]

{ #category : 'accessing' }
ShTestObject >> x [

	^ x
]

{ #category : 'accessing' }
ShTestObject >> x: anInteger [ 
	x := anInteger
]

{ #category : 'accessing' }
ShTestObject >> y [

	^ y
]

{ #category : 'accessing' }
ShTestObject >> y: anInteger [ 
	y := anInteger
]
