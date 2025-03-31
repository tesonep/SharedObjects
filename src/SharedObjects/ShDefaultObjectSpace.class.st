Class {
	#name : 'ShDefaultObjectSpace',
	#superclass : 'DynamicVariable',
	#category : 'SharedObjects-Core',
	#package : 'SharedObjects',
	#tag : 'Core'
}

{ #category : 'accessing' }
ShDefaultObjectSpace class >> value: aValue [

	self soleInstance value: aValue
]

{ #category : 'accessing' }
ShDefaultObjectSpace >> value: anObject [ 
	
	| activeProcess oldValue |

	activeProcess := Processor activeProcess.
	activeProcess psValueAt: index put: anObject.

]
