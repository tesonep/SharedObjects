"
I am one of the most common collection. I can grow, and elements can be added sequentially by the user.  
I am more general than Array; my size grows on demand. I store data inside an Array and remember the first and last index. If I need, I can replace this Array by a larger one.

I am usually used to store an unknown amount of objects. When my contents size will not move, one can send me the #asArray message to get better performances, but I cannot grow anymore (add: and remove: are not supported on Array).

### Public API and Key Messages

- #new / #withAll: aCollection / #with: anObject 	are common constructors
- #add: anObject / #at: anIndex put: anObject / #at: anIndex ifAbsentPut: anObject 	allow to add new elements to myself.
- #remove: anObject / #removeIndex: anIndex 	allow to remove an element.
- #do: aBlock / #collect: aBlock / #select: aBlock / #reject: aBlock 	are common iterators.

### Examples	

```	
	""There is many ways to create an OrderedCollection, here are some:""
	ordCol := OrderedCollection new.
	ordCol
		add: 'one';
		add: 'two';
		addFirst: 'zero';
		addLast: 'three'.
	ordCol.		""returns: an OrderedCollection('zero' 'one' 'two' 'three')""

	""or""
	ordCol := OrderedCollection with: 'one' with: 'two' with: 'three'.
	ordCol.		""returns: an OrderedCollection('one' 'two' 'three')""

	""or from an other collection""
	ordCol := OrderedCollection withAll: #('one' 'two' 'three').
	ordCol.		""returns: an OrderedCollection('one' 'two' 'three')""

	""or""
	#('one' 'two' 'three') asOrderedCollection.

	""Some manipulations""
	ordCol := OrderedCollection ofSize: 2.
	ordCol
		at: 1 put: 'one';
		at: 2 put: 'two';
		at: 2 ifAbsentPut: 'three'.
	ordCol.		""returns: an OrderedCollection('one' 'two')""
	ordCol
		remove: 'two';
		removeIndex: 1.
	ordCol.		""returns:  an OrderedCollection()""

	""A last one""
	ordCol := OrderedCollection with: $b with: $c with: $a.
	ordCol sort: [ :first :second | first < second ].		""returns: an OrderedCollection($a $b $c)""
	ordCol collect: [ :element | element asUppercase ].		""returns:  an OrderedCollection($A $B $C)""
	ordCol select: [ :element | element >= $b ].		""returns:  an OrderedCollection($b $c)""
	ordCol do: [ :element | element inspect ].
	ordCol asArray		""returns: #($a $b $c)""
``` 

###Internal Representation and Key Implementation Points.
Instance Variables
- array:			<Array> 		An Array where I store my elements. If I need a bigger one I can remove this one and create a new one.
- firstIndex:		<Integer> 	The index of my first element.
- lastIndex:		<Integer> 	The index of my last element.

I store my elements inside an array. This array is AT LEAST of the size of my elements. If someone adds an element and my array is not large enough, I remove it and I create a new one larger with the same elements (usually, the size double).
"
Class {
	#name : 'ShOrderedCollection',
	#superclass : 'SequenceableCollection',
	#traits : 'TShObject',
	#classTraits : 'TShObject classTrait',
	#instVars : [
		'#array => ShSlot',
		'#firstIndex => ShSlot',
		'#lastIndex => ShSlot'
	],
	#category : 'SharedObjects-BaseClasses',
	#package : 'SharedObjects',
	#tag : 'BaseClasses'
}

{ #category : 'private' }
ShOrderedCollection class >> arrayType [
	^ ShArray
]

{ #category : 'cleanup' }
ShOrderedCollection class >> cleanUp: aggressive [
	"Rehash all instances when cleaning aggressively"

	aggressive ifTrue: [self compactAll]
]

{ #category : 'cleanup' }
ShOrderedCollection class >> compactAll [
	"OrderedCollection compactAll"

	self allSubclassesDo: #compactAllInstances
]

{ #category : 'cleanup' }
ShOrderedCollection class >> compactAllInstances [
	self allInstances do: #compact
]

{ #category : 'instance creation' }
ShOrderedCollection class >> new [
	
	^ self new: 10
]

{ #category : 'instance creation' }
ShOrderedCollection class >> new: anInteger [
	^ self new: anInteger in: ShDefaultObjectSpace value
]

{ #category : 'instance creation' }
ShOrderedCollection class >> new: anInteger in: aShObjectSpace [

	^ (aShObjectSpace allocateInstanceOf: self)
		  setCollection: (self arrayType new: anInteger in: aShObjectSpace)
		  yourself

]

{ #category : 'instance creation' }
ShOrderedCollection class >> new: anInteger withAll: anObject [
	
	^ self error 
	
]

{ #category : 'instance creation' }
ShOrderedCollection class >> newFrom: aCollection [
	"Answer an instance of me containing the same elements as aCollection."

	| newCollection |
	newCollection := self new: aCollection size.
	newCollection addAll: aCollection.
	^newCollection

"	OrderedCollection newFrom: {1. 2. 3}
	{1. 2. 3} as: OrderedCollection
	{4. 2. 7} as: SortedCollection
"
]

{ #category : 'instance creation' }
ShOrderedCollection class >> newFromArray: anArray [

	^ self error
]

{ #category : 'instance creation' }
ShOrderedCollection class >> newIn: aShObjectSpace [

	^ self new: 10 in: aShObjectSpace 
]

{ #category : 'instance creation' }
ShOrderedCollection class >> ofSize: n [
	"Create a new collection of size n with nil as its elements.
	This method exists because OrderedCollection new: n creates an
	empty collection,  not one of size n."
	| collection |
	collection := self new: n.
	collection setContents: (collection collector).
	^ collection
]

{ #category : 'accessing' }
ShOrderedCollection class >> streamSpecies [
	^ Array
]

{ #category : 'adding' }
ShOrderedCollection >> add: newObject [
	"Add a new object at the end of the collection, and returns the object itself"
	"((OrderedCollection new add: 42; yourself) add: 43; yourself) asArray >>> #(42 43)"

	"Add returns the object itself"
	"(OrderedCollection new add: 42) >>> 42"

	"You may want to use yourself to return the collection itself"
	"(OrderedCollection new add: 42; yourself) class >>> OrderedCollection"
	"(OrderedCollection new add: 42; yourself) size >>> 1"
	^self addLast: newObject
]

{ #category : 'adding' }
ShOrderedCollection >> add: newObject after: oldObject [
	"Add the argument, newObject, as an element of the receiver. Put it in
	the sequence just succeeding oldObject. Answer newObject.
	Raises an error if oldObject is not found"

	"(OrderedCollection new add: 41; add: 42 after: 41; yourself) asArray >>>  #(41 42)"
	"(OrderedCollection new add: 41; add: 42 after: 41; add: 43 after: 41; yourself) asArray >>>  #(41 43 42)"

	^self insert: newObject before: (self find: oldObject) + 1
]

{ #category : 'adding' }
ShOrderedCollection >> add: newObject afterIndex: index [
	"Add the argument, newObject, as an element of the receiver. Put it in
	the sequence just after index. Answer newObject."
	(index between: 0 and: self size) ifFalse:[^self errorSubscriptBounds: index].
	^self insert: newObject before: firstIndex + index
]

{ #category : 'adding' }
ShOrderedCollection >> add: newObject before: oldObject [
	"Add the argument, newObject, as an element of the receiver. Put it in
	the sequence just preceding oldObject. Answer newObject."

	"(OrderedCollection new add: 42; add: 41 before: 42; yourself) asArray >>> #(41 42)"

	^ self insert: newObject before: (self find: oldObject)
]

{ #category : 'adding' }
ShOrderedCollection >> add: newObject beforeIndex: index [
	"Add the argument, newObject, as an element of the receiver. Put it in
	the sequence just before index. Answer newObject."
	(index between: 1 and: self size+1) ifFalse:[^self errorSubscriptBounds: index].
	^self insert: newObject before: firstIndex + index - 1
]

{ #category : 'adding' }
ShOrderedCollection >> addAll: aCollection [
	"Add each element of aCollection at my end. Answer aCollection."

	"(OrderedCollection new addAll: #(41 42); yourself) asArray >>> #(41 42)"


	^ self addAllLast: aCollection
]

{ #category : 'adding' }
ShOrderedCollection >> addAllFirst: anOrderedCollection [
	"Add each element of anOrderedCollection at the beginning of the
	receiver. Answer anOrderedCollection."

	"((OrderedCollection new add: 40; addAllFirst: #(41 42); yourself) asArray) >>  #(41 42 40)"

	anOrderedCollection reverseDo: [:each | self addFirst: each].
	^anOrderedCollection
]

{ #category : 'adding' }
ShOrderedCollection >> addAllFirstUnlessAlreadyPresent: anOrderedCollection [
	"Add each element of anOrderedCollection at the beginning of the receiver, preserving the order, but do not add any items that are already in the receiver.  Answer anOrderedCollection."

	anOrderedCollection reverseDo:
		[:each | (self includes: each) ifFalse: [self addFirst: each]].
	^ anOrderedCollection
]

{ #category : 'adding' }
ShOrderedCollection >> addAllLast: aCollection [
	"Add each element of aCollection at the end of the receiver.
	Answer aCollection."

	aCollection do: [:each | self addLast: each].
	^aCollection
]

{ #category : 'adding' }
ShOrderedCollection >> addFirst: newObject [
	"Add newObject to the beginning of the receiver. Answer newObject."

	firstIndex = 1 ifTrue: [self makeRoomAtFirst].
	firstIndex := firstIndex - 1.
	^array at: firstIndex put: newObject
]

{ #category : 'adding' }
ShOrderedCollection >> addLast: newObject [
	"Add newObject to the end of the receiver. Answer newObject."

	lastIndex = array size ifTrue: [self makeRoomAtLast].
	lastIndex := lastIndex + 1.
	^array at: lastIndex put: newObject
]

{ #category : 'private' }
ShOrderedCollection >> addNoSort: newObject [
	"Add newObject to the end of the receiver. If the receiver is sorted, assume that this is the correct position--do not check sort order. Answer newObject."

	^ self addLast: newObject
]

{ #category : 'converting' }
ShOrderedCollection >> asArray [
	"Convert an OrderedCollection into an Array."
	"#(a b c) asOrderedCollection asArray >>> #(a b c)"
	"OrderedCollection new class >>> OrderedCollection"
	"OrderedCollection new asArray class >>> Array"
	"(OrderedCollection new add: 42; add: 43; yourself) asArray >>> #(42 43)"

	^ (Array new: self size) replaceFrom: 1 to: self size with: array startingAt: firstIndex
]

{ #category : 'converting' }
ShOrderedCollection >> asOrderedCollection [

	self species == OrderedCollection ifTrue: [ ^self ].
	^super asOrderedCollection
]

{ #category : 'accessing' }
ShOrderedCollection >> at: anInteger [
	"Answer my element at index anInteger. at: is used by a knowledgeable
	client to access an existing element."
	"((OrderedCollection new add: 34; yourself) at: 1) >>> 34"
	"(#(40 41 42) asOrderedCollection at: 1) >>> 40"
	"(#(40 41 42) asOrderedCollection at: 2) >>> 41"
	"(#(40 41 42) asOrderedCollection at: 3) >>> 42"

	| index |
	anInteger < 1
		ifTrue: [ self errorSubscriptBounds: anInteger ].
	(index := anInteger + firstIndex - 1) > lastIndex
		ifTrue: [ self errorSubscriptBounds: anInteger ].
	^ array at: index
]

{ #category : 'adding' }
ShOrderedCollection >> at: index ifAbsentPut: block [
	"Return value at index, however, if value does not exist (nil or out of bounds) then add block's value at index (growing self if necessary)"

	| v |
	index <= self size ifTrue: [
		^ (v := self at: index)
			ifNotNil: [v]
			ifNil: [self at: index put: block value]
	].
	[self size < index] whileTrue: [self add: nil].
	^ self at: index put: block value
]

{ #category : 'accessing' }
ShOrderedCollection >> at: anInteger put: anObject [
	"Put anObject at element index anInteger. at:put: cannot be used to
	append, front or back, to an ordered collection; it is used by a
	knowledgeable client to replace an element."

	| index |
	anInteger < 1
		ifTrue: [ self errorSubscriptBounds: anInteger ].
	(index := anInteger + firstIndex - 1) > lastIndex
		ifTrue: [ self errorSubscriptBounds: anInteger ].
	^ array at: index put: anObject
]

{ #category : 'accessing' }
ShOrderedCollection >> capacity [
	"Answer the current capacity of the receiver."

	"OrderedCollection new capacity >>> 10"
	"(OrderedCollection new addAll: (1 to: 15); yourself) capacity >>> 20"

	^ array size
]

{ #category : 'enumerating' }
ShOrderedCollection >> collect: aBlock [
	"Evaluate aBlock with each of my elements as the argument. Collect the
	resulting values into a collection that is like me. Answer the new
	collection. Override superclass in order to use addLast:, not at:put:."

	"(#(1 2 3) asOrderedCollection collect: [ :v | v * 10 ]) asArray >>> #(10 20 30)"

	"(#(1 2 3) asOrderedCollection collect: [ :v | 10 ]) asArray >>> #(10 10 10)"

	| newCollection |
	newCollection := self speciesForTransform new: self size.
	firstIndex to: lastIndex do: [ :index |
	newCollection addLast: (aBlock value: (array at: index)) ].
	^ newCollection
]

{ #category : 'enumerating' }
ShOrderedCollection >> collect: aBlock from: fromIndex to: toIndex [
	"Override superclass in order to use addLast:, not at:put:."

	| result |
	self ensureBoundsFrom: fromIndex to: toIndex.
	result := self speciesForTransform new: toIndex - fromIndex + 1.
	firstIndex + fromIndex - 1 to: firstIndex + toIndex - 1 do: [ :index |
	result addLast: (aBlock value: (array at: index)) ].
	^ result
]

{ #category : 'enumerating' }
ShOrderedCollection >> collect: collectBlock thenSelect: selectBlock [
	"Optimized version Collection>>#collect:thenSelect:"

	| newCollection newElement |
	newCollection := self speciesForTransform new.
	firstIndex to: lastIndex do: [ :index |
		newElement := collectBlock value: (array at: index).
		(selectBlock value: newElement) ifTrue: [
			newCollection addLast: newElement ] ].
	^ newCollection
]

{ #category : 'private' }
ShOrderedCollection >> collector [  "Private"
	^ array
]

{ #category : 'private' }
ShOrderedCollection >> compact [
	"remove all empty slots to the end of array, while keeping the empty slots at the front."

	| newArray |
	newArray := self class arrayType
		            new: lastIndex
		            in: self reference objectSpace.
	newArray
		replaceFrom: firstIndex
		to: lastIndex
		with: array
		startingAt: firstIndex.
	array := newArray
]

{ #category : 'copying' }
ShOrderedCollection >> copyEmpty [
	"Answer a copy of the receiver that contains no elements."

	^self species new
]

{ #category : 'copying' }
ShOrderedCollection >> copyFrom: startIndex to: endIndex [
	"Answer a copy of the receiver that contains elements from position
	startIndex to endIndex."

	^self shallowCopy postCopyFrom: startIndex to: endIndex
]

{ #category : 'copying' }
ShOrderedCollection >> copyReplaceFrom: start to: stop with: replacementCollection [
	"Answer a copy of the receiver with replacementCollection's elements in
	place of the receiver's start'th to stop'th elements. This does not expect
	a 1-1 map from replacementCollection to the start to stop elements, so it
	will do an insert or append."

	| newOrderedCollection delta startIndex stopIndex |
	"if start is less than 1, ignore stop and assume this is inserting at the front.
	if start greater than self size, ignore stop and assume this is appending.
	otherwise, it is replacing part of me and start and stop have to be within my
	bounds. "
	delta := 0.
	startIndex := start.
	stopIndex := stop.
	start < 1
		ifTrue: [startIndex := stopIndex := 0]
		ifFalse: [startIndex > self size
				ifTrue: [startIndex := stopIndex := self size + 1]
				ifFalse:
					[(stopIndex < (startIndex - 1) or: [stopIndex > self size])
						ifTrue: [self errorOutOfBounds].
					delta := stopIndex - startIndex + 1]].
	newOrderedCollection :=
		self species new: self size + replacementCollection size - delta.
	1 to: startIndex - 1 do: [:index | newOrderedCollection add: (self at: index)].
	1 to: replacementCollection size do:
		[:index | newOrderedCollection add: (replacementCollection at: index)].
	stopIndex + 1 to: self size do: [:index | newOrderedCollection add: (self at: index)].
	^newOrderedCollection
]

{ #category : 'copying' }
ShOrderedCollection >> copyWith: newElement [
	"Answer a copy of the receiver that is 1 bigger than the receiver and
	includes the argument, newElement, at the end."

	| newCollection |
	newCollection := self copy.
	newCollection add: newElement.
	^newCollection
]

{ #category : 'enumerating' }
ShOrderedCollection >> do: aBlock [
	"Override the superclass for performance reasons."

	firstIndex to: lastIndex do: [ :index |
		aBlock value: (array at: index) ]
]

{ #category : 'private' }
ShOrderedCollection >> ensureBoundsFrom: fromIndex to: toIndex [
	(fromIndex < 1)
		ifTrue: [^self errorSubscriptBounds: fromIndex].
	(toIndex + firstIndex - 1 > lastIndex)
		ifTrue: [^self errorSubscriptBounds: toIndex]
]

{ #category : 'private' }
ShOrderedCollection >> find: oldObject [
  "  This method answers an index in the range firstIndex .. lastIndex, which is meant for internal use only.
     Never use this method in your code, the methods for public use are:
        #indexOf:
        #indexOf:ifAbsent: "

	| index |
	index := firstIndex.
	[index <= lastIndex]
		whileTrue:
			[(array at: index) = oldObject ifTrue: [^ index].
			index := index + 1].
	self errorNotFound: oldObject
]

{ #category : 'private' }
ShOrderedCollection >> growAtFirst [
	"Add new empty slots to the front of array, while keeping the empty slots at the end."

	"OrderedCollection new capacity >>> 10"

	"(OrderedCollection new growAtFirst; capacity) >>> 20"

	| newArray newFirstIndex newLastIndex |
	newArray := self class arrayType
		            new: (array size * 2 max: 1)
		            in: self reference objectSpace.
	newFirstIndex := newArray size - array size + firstIndex.
	newLastIndex := newFirstIndex + lastIndex - firstIndex.
	newArray
		replaceFrom: newFirstIndex
		to: newLastIndex
		with: array
		startingAt: firstIndex.
	array := newArray.
	firstIndex := newFirstIndex.
	lastIndex := newLastIndex
]

{ #category : 'private' }
ShOrderedCollection >> growAtLast [
	"Add new empty slots to the end of array, while keeping the empty slots at the front."

	"OrderedCollection new capacity >>> 10"

	"(OrderedCollection new growAtLast; capacity) >>> 20"

	| newArray |
	newArray := self class arrayType
		            new: (array size * 2 max: 1)
		            in: self reference objectSpace.
	newArray
		replaceFrom: firstIndex
		to: lastIndex
		with: array
		startingAt: firstIndex.
	array := newArray
]

{ #category : 'private' }
ShOrderedCollection >> insert: anObject before: spot [

  "  spot is an index in the range firstIndex .. lastIndex, such an index is not known from outside the collection.
     Never use this method in your code, it is meant for private use by OrderedCollection only.
     The methods for use are:
        #add:before:   to insert an object before another object
        #add:beforeIndex:   to insert an object before a given position. "
	| "index" delta spotIndex|
	spotIndex := spot.
	delta := spotIndex - firstIndex.
	firstIndex = 1
		ifTrue:
			[self makeRoomAtFirst.
			spotIndex := firstIndex + delta].
	firstIndex := firstIndex - 1.
	array
		replaceFrom: firstIndex
		to: spotIndex - 2
		with: array
		startingAt: firstIndex + 1.
	array at: spotIndex - 1 put: anObject.
"	index := firstIndex := firstIndex - 1.
	[index < (spotIndex - 1)]
		whileTrue:
			[array at: index put: (array at: index + 1).
			index := index + 1].
	array at: index put: anObject."
	^ anObject
]

{ #category : 'splitjoin' }
ShOrderedCollection >> join: aCollection [
	"Append the elements of the argument, aSequenceableCollection, separating them by the receiver.
	Note that we always return an OrderedCollection, not a SortedCollection--the interleaved order
	of the result is the whole point, here."

	| result |
	"Lower-bound guess at the size of the result, assuming aCollection is 'flat'--
	no nested collections."
	result := self speciesForTransform new:
		          aCollection size + (self size * (aCollection size - 1)).
	aCollection
		do: [ :each | each appendTo: result ]
		separatedBy: [ self appendTo: result ].
	^ result
]

{ #category : 'private' }
ShOrderedCollection >> makeRoomAtFirst [
	"Make some empty slots at the front of the array. If we have more than 50% free space, then just move the elements, so that the first 50% of the slots are free, otherwise add new free slots to the front by growing. Precondition: firstIndex = 1"

	"#(1 2 3) asOrderedCollection capacity >>> 3"
	"#(1 2 3) asOrderedCollection makeRoomAtFirst capacity >>> 6"

	| tally newFirstIndex newLastIndex |
	tally := self size.
	tally * 2 >= array size ifTrue: [ ^self growAtFirst ].
	tally = 0 ifTrue: [ ^self resetTo: array size + 1 ].
	newFirstIndex := array size // 2 + 1.
	newLastIndex := newFirstIndex - firstIndex + lastIndex.
	0 to: tally - 1 do: [ :offset |
		array at: newLastIndex - offset put: (array at: lastIndex - offset) ].
	array from: firstIndex to: newFirstIndex - 1 put: nil.
	firstIndex := newFirstIndex.
	lastIndex := newLastIndex
]

{ #category : 'private' }
ShOrderedCollection >> makeRoomAtLast [
	"Make some empty slots at the end of the array. If we have more than 50% free space, then just move the elements, so that the last 50% of the slots are free, otherwise add new free slots to the end by growing. Precondition: lastIndex = array size"

	| tally newFirstIndex newLastIndex |
	tally := self size.
	tally * 2 >= lastIndex ifTrue: [ ^self growAtLast ].
	tally = 0 ifTrue: [ ^self resetTo: 1 ].
	newLastIndex := lastIndex // 2.
	newFirstIndex := newLastIndex - lastIndex + firstIndex.
	array
		replaceFrom: newFirstIndex
		to: newLastIndex
		with: array
		startingAt: firstIndex.
	array from: newLastIndex + 1 to: lastIndex put: nil.
	firstIndex := newFirstIndex.
	lastIndex := newLastIndex
]

{ #category : 'copying' }
ShOrderedCollection >> postCopy [
	array := array copy
]

{ #category : 'copying' }
ShOrderedCollection >> postCopyFrom: startIndex to: endIndex [
	"finish copying the array in a certain range."

	endIndex < startIndex ifFalse: [
		"Because actual size of the array may be greater than used size,
		postCopyFrom:to: may fail to fail and answer an incorrect result
		if this sanity check were not applied."
		(startIndex between: 1 and: self size) ifFalse: [^SubscriptOutOfBounds signalFor: startIndex lowerBound: (1 min: self size) upperBound: self size in: self].
		(endIndex between: 1 and: self size) ifFalse: [^SubscriptOutOfBounds signalFor: endIndex lowerBound: (1 min: self size) upperBound: self size in: self]].

	"Add a protection that lacks in Array>>postcopy"
	array := array copyFrom: startIndex + firstIndex - 1 to: (endIndex max: startIndex - 1) + firstIndex - 1.
	firstIndex := 1.
	lastIndex := array size
]

{ #category : 'enumerating' }
ShOrderedCollection >> reject: rejectBlock [
	"Optimized version of Collection>>#reject:"

	| newCollection element |

	newCollection := self copyEmpty.

	firstIndex to: lastIndex do: [ :index |
		(rejectBlock value: (element := array at: index))
			ifFalse: [ newCollection addNoSort: element ]].

	^ newCollection
]

{ #category : 'enumerating' }
ShOrderedCollection >> reject: rejectBlock thenCollect: collectBlock [
	" Optimized version of Collection>>#reject:thenCollect: "

	| newCollection |
	newCollection := self speciesForTransform new.

	firstIndex to: lastIndex do: [ :index |
		| element |
		element := array at: index.
		(rejectBlock value: element) ifFalse: [
			newCollection addLast: (collectBlock value: element) ] ].

	^ newCollection
]

{ #category : 'removing' }
ShOrderedCollection >> remove: oldObject ifAbsent: absentBlock [

	| index |
	index := firstIndex.
	[index <= lastIndex]
		whileTrue:
			[oldObject = (array at: index)
				ifTrue:
					[self removeIndex: index.
					^ oldObject]
				ifFalse: [index := index + 1]].
	^ absentBlock value
]

{ #category : 'removing' }
ShOrderedCollection >> removeAll [
	"remove all the elements from this collection.
	Keep same amount of storage"

	self setCollection:
		(self class arrayType new: array size in: self reference objectSpace)
]

{ #category : 'removing' }
ShOrderedCollection >> removeAllSuchThat: aBlock [
	"Remove each element of the receiver for which aBlock evaluates to true.
	The method in Collection is O(N^2), this is O(N)."

	| n |
	n := firstIndex.
	firstIndex to: lastIndex do: [:index |
	    (aBlock value: (array at: index)) ifFalse: [
			array at: n put: (array at: index).
			n := n + 1]].
	array from: n to: lastIndex put: nil.
	lastIndex := n - 1
]

{ #category : 'removing' }
ShOrderedCollection >> removeAt: index [
	| removed |
	removed := self at: index.
	self removeIndex: index + firstIndex - 1.
	^removed
]

{ #category : 'removing' }
ShOrderedCollection >> removeFirst [
	"Remove the first element of the receiver and answer it. If the receiver is
	empty, create an error notification."
	| firstObject |
	self emptyCheck.
	firstObject := array at: firstIndex.
	array at: firstIndex put: nil.
	firstIndex := firstIndex + 1.
	^ firstObject
]

{ #category : 'removing' }
ShOrderedCollection >> removeFirst: n [
	"Remove first n object into an array"

	| list |
	list := self class arrayType new: n in: self reference objectSpace.
	1 to: n do: [ :i | list at: i put: self removeFirst ].
	^ list
]

{ #category : 'private' }
ShOrderedCollection >> removeIndex: removedIndex [
  "  removedIndex is an index in the range firstIndex .. lastIndex, such an index is not known from outside the collection.
    Never use this method in your code, it is meant for private use by OrderedCollection only.
     The method for public use is:
        #removeAt: "

	array
		replaceFrom: removedIndex
		to: lastIndex - 1
		with: array
		startingAt: removedIndex+1.
	array at: lastIndex put: nil.
	lastIndex := lastIndex - 1
]

{ #category : 'removing' }
ShOrderedCollection >> removeLast [
	"Remove the last element of the receiver and answer it. If the receiver is
	empty, create an error notification."
	| lastObject |
	self emptyCheck.
	lastObject := array at: lastIndex.
	array at: lastIndex put: nil.
	lastIndex := lastIndex - 1.
	^ lastObject
]

{ #category : 'removing' }
ShOrderedCollection >> removeLast: n [
	"Remove last n object into an array with last in last position"

	| list |
	list := self class arrayType new: n in: self reference objectSpace.
	n to: 1 by: -1 do: [ :i | list at: i put: self removeLast ].
	^ list
]

{ #category : 'initialization' }
ShOrderedCollection >> reset [
	"Quickly remove all elements. The objects will be still referenced, but will not be 	accessible."

	self resetTo: 1
]

{ #category : 'private' }
ShOrderedCollection >> resetTo: index [
	firstIndex := index.
	lastIndex := firstIndex - 1
]

{ #category : 'enumerating' }
ShOrderedCollection >> reverseDo: aBlock [
	"Override the superclass for performance reasons."

	lastIndex to: firstIndex by: -1 do: [ :index |
		aBlock value: (array at: index) ]
]

{ #category : 'converting' }
ShOrderedCollection >> reversed [
	"Answer a copy of the receiver with element order reversed.  "

	"#(2 3 4 'fred') asOrderedCollection reversed >>> #('fred' 4 3 2) asOrderedCollection"

	| newCol |
	newCol := self speciesForTransform new: self size.
	self reverseDo: [ :elem | newCol addLast: elem ].
	^ newCol
]

{ #category : 'enumerating' }
ShOrderedCollection >> select: selectBlock [
	"Optimized version of Collection>>#select: "

	| newCollection element |

	newCollection := self copyEmpty.

	firstIndex to: lastIndex do: [ :index |
		(selectBlock value: (element := array at: index))
			ifTrue: [ newCollection addNoSort: element ]].

	^ newCollection
]

{ #category : 'enumerating' }
ShOrderedCollection >> select: selectBlock thenCollect: collectBlock [
	" Optimized version Collection>>#select:thenCollect: "

	| newCollection element |
	newCollection := self speciesForTransform new.

	firstIndex to: lastIndex do: [ :index |
		element := array at: index.
		(selectBlock value: element) ifTrue: [
			newCollection addLast: (collectBlock value: element) ] ].

	^ newCollection
]

{ #category : 'private' }
ShOrderedCollection >> setCollection: anArray [
	array := anArray.
	self reset
]

{ #category : 'private' }
ShOrderedCollection >> setContents: anArray [
	array := anArray.
	firstIndex := 1.
	lastIndex := array size
]

{ #category : 'accessing' }
ShOrderedCollection >> size [
	"Answer how many elements the receiver contains."

	^ lastIndex - firstIndex + 1
]

{ #category : 'sorting' }
ShOrderedCollection >> sort: aSortBlock [
	"Sort this array using aSortBlock. The block should take two arguments
	and return true if the first element should preceed the second one."

	self size <= 1 ifTrue: [^ self].  "nothing to do"
	array
		mergeSortFrom: firstIndex
		to: lastIndex
		src: array shallowCopy
		dst: array
		by: aSortBlock
]

{ #category : 'private' }
ShOrderedCollection >> speciesForTransform [
	"Answer the preferred class for a transformation of the receiver (the output of a #collect: or similar). This may differ from the regular #species, as the transformed elements may no longer be compatible with the receiver in some way. For example, when transforming the elements of a SortedCollection, the result may no longer be sorted, or indeed sortable."

	^ self species
]

{ #category : 'truncate' }
ShOrderedCollection >> truncateTo: smallSize [
	"return myself or a copy shortened to smallSize."

	^ self size <= smallSize
		ifTrue: [ self ]
		ifFalse: [ self copyFrom: 1 to: smallSize ]
]

{ #category : 'enumerating' }
ShOrderedCollection >> with: otherCollection collect: twoArgBlock [
	"Collect and return the result of evaluating twoArgBlock with
	corresponding elements from this collection and otherCollection."

	| result |
	otherCollection size = self size ifFalse: [
		self error: 'otherCollection must be the same size' ].
	result := self speciesForTransform new: self size.
	1 to: self size do: [ :index |
		result addLast: (twoArgBlock
				 value: (self at: index)
				 value: (otherCollection at: index)) ].
	^ result
]

{ #category : 'enumerating' }
ShOrderedCollection >> withIndexCollect: elementAndIndexBlock [
	"Just like with:collect: except that the iteration index supplies the second argument to the block. Override superclass in order to use addLast:, not at:put:."

	| newCollection |
	newCollection := self speciesForTransform new: self size.
	firstIndex to: lastIndex do: [ :index |
		newCollection addLast: (elementAndIndexBlock
				 value: (array at: index)
				 value: index - firstIndex + 1) ].
	^ newCollection
]

{ #category : 'enumerating' }
ShOrderedCollection >> withIndexSelect: elementAndIndexBlock [
	"Optimized version of SequenceableCollection>>#withIndexSelect: "

	"(#('We' 'love' 'pharo!') asOrderedCollection withIndexSelect: [:value :index | value size - 1 <= index]) >>> (OrderedCollection with: 'We')"

	| newCollection element |
	newCollection := self copyEmpty.
	firstIndex to: lastIndex do: [ :index |
		(elementAndIndexBlock value: (element := array at: index) value: index)
			ifTrue: [ newCollection addNoSort: element ] ].
	^ newCollection
]
