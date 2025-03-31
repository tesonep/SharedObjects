Extension { #name : 'ZnBufferedWriteStream' }

{ #category : '*SharedObjects-IO' }
ZnBufferedWriteStream >> uint64: integer [
	^ self nextIntegerOfSize: 8 signed: false bigEndian: true put: integer
]
