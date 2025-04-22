Class {
	#name : 'ShAbstractSysVKeyed',
	#superclass : 'Object',
	#instVars : [
		'projectID',
		'errnoAddress',
		'file',
		'key'
	],
	#pools : [
		'ShUnixConstants',
		'ShUnixTypes'
	],
	#category : 'SharedObjects-IO',
	#package : 'SharedObjects-IO'
}

{ #category : 'accessing' }
ShAbstractSysVKeyed >> errno [

	errnoAddress ifNil: [ errnoAddress := ExternalAddress loadSymbol: #errno ].
		
	^ errnoAddress isNull 
		ifTrue: [ nil ]
		ifFalse: [ errnoAddress platformLongAt: 1 ]
]

{ #category : 'library path' }
ShAbstractSysVKeyed >> ffiLibraryName [ 

	^ LibC
]

{ #category : 'accessing' }
ShAbstractSysVKeyed >> file: aString [ 
	file := aString
]

{ #category : 'accessing' }
ShAbstractSysVKeyed >> ftok: path projectId: id [
	
	^ self ffiCall: #(key_t ftok(char *path, int id))
]

{ #category : 'accessing' }
ShAbstractSysVKeyed >> key [

	key ifNil: [ 
		key := self ftok: file projectId: projectID.
		key = -1 ifTrue: [ 
			key := nil. 
			self error: 'Errno: ' , self errno printString ] ].
	
	^ key
]

{ #category : 'as yet unclassified' }
ShAbstractSysVKeyed >> projectId: anInteger [ 
	
	projectID := anInteger 
]
