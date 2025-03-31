Class {
	#name : 'ShFileBasedObjectSpaceTest',
	#superclass : 'TestCase',
	#instVars : [
		'fileReference',
		'fileBasedObjectSpace'
	],
	#category : 'SharedObjects-Tests',
	#package : 'SharedObjects-Tests'
}

{ #category : 'accessing' }
ShFileBasedObjectSpaceTest >> fileReference [

	^ fileReference ifNil: [ fileReference := FileLocator temp / 'testSpace.data' ].
]

{ #category : 'accessing' }
ShFileBasedObjectSpaceTest >> tearDown [

	fileBasedObjectSpace ifNotNil: [ fileBasedObjectSpace close ].
	self fileReference ensureDelete.
	super tearDown.
]

{ #category : 'tests' }
ShFileBasedObjectSpaceTest >> testBootstrappingEmptySpace [

	fileBasedObjectSpace := ShFileBasedObjectSpace
		                        forFileReference: self fileReference
		                        withInitialSize: 1024 * 1024.
		
	fileBasedObjectSpace onSpaceDo: [ ShObject new ].

	self assert: fileBasedObjectSpace allObjects size equals: 1.

]

{ #category : 'tests' }
ShFileBasedObjectSpaceTest >> testOpeningOnAnExistingFile [

	"First create the space"
	fileBasedObjectSpace := ShFileBasedObjectSpace
		                        forFileReference: self fileReference
		                        withInitialSize: 1024 * 1024.
		
	fileBasedObjectSpace onSpaceDo: [ ShObject new ].

	fileBasedObjectSpace close.
	
	"Open it again"
	
	fileBasedObjectSpace := ShFileBasedObjectSpace forFileReference: self fileReference.

	self assert: fileBasedObjectSpace allObjects size equals: 1.

]
