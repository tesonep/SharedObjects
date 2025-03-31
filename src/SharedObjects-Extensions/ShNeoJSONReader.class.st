Class {
	#name : 'ShNeoJSONReader',
	#superclass : 'NeoJSONReader',
	#category : 'SharedObjects-Extensions',
	#package : 'SharedObjects-Extensions'
}

{ #category : 'parsing' }
ShNeoJSONReader >> parseString [ 

	^ ShByteString from: super parseString 
]
