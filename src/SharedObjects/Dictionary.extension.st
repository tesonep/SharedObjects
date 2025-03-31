Extension { #name : 'Dictionary' }

{ #category : '*SharedObjects' }
Dictionary >> keyAtValue: value ifPresent: foundBlock [

	self associationsDo: [ :association |
		value = association value ifTrue: [ ^ foundBlock value: association key ] ]
]
