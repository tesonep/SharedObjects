Class {
	#name : 'ShUnixTypes',
	#superclass : 'SharedPool',
	#classVars : [
		'key_t',
		'mode_t',
		'off_t'
	],
	#category : 'SharedObjects-IO',
	#package : 'SharedObjects-IO'
}

{ #category : 'class initialization' }
ShUnixTypes class >> initialize [

	mode_t := FFIInt16.
	off_t := FFIInt64.
	key_t := FFIInt32.
]
