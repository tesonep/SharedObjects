Class {
	#name : 'ShSysVSemaphoreBuffer',
	#superclass : 'FFIStructure',
	#classVars : [
		'OFFSET_SEM_FLG',
		'OFFSET_SEM_NUM',
		'OFFSET_SEM_OP'
	],
	#pools : [
		'ShUnixConstants',
		'ShUnixTypes'
	],
	#category : 'SharedObjects-IO',
	#package : 'SharedObjects-IO'
}

{ #category : 'field definition' }
ShSysVSemaphoreBuffer class >> fieldsDesc [
	"self rebuildFieldAccessors"

	^ #(      ushort sem_num      
             short   sem_op         
             short   sem_flg         )
]

{ #category : 'accessing - structure variables' }
ShSysVSemaphoreBuffer >> sem_flg [
	"This method was automatically generated"
	^handle signedShortAt: OFFSET_SEM_FLG
]

{ #category : 'accessing - structure variables' }
ShSysVSemaphoreBuffer >> sem_flg: anObject [
	"This method was automatically generated"
	handle signedShortAt: OFFSET_SEM_FLG put: anObject
]

{ #category : 'accessing - structure variables' }
ShSysVSemaphoreBuffer >> sem_num [
	"This method was automatically generated"
	^handle unsignedShortAt: OFFSET_SEM_NUM
]

{ #category : 'accessing - structure variables' }
ShSysVSemaphoreBuffer >> sem_num: anObject [
	"This method was automatically generated"
	handle unsignedShortAt: OFFSET_SEM_NUM put: anObject
]

{ #category : 'accessing - structure variables' }
ShSysVSemaphoreBuffer >> sem_op [
	"This method was automatically generated"
	^handle signedShortAt: OFFSET_SEM_OP
]

{ #category : 'accessing - structure variables' }
ShSysVSemaphoreBuffer >> sem_op: anObject [
	"This method was automatically generated"
	handle signedShortAt: OFFSET_SEM_OP put: anObject
]
