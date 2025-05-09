"
I am an abstract collection of objects that implement hash and equality in a consistent way. This means that whenever two objects are equal, their hashes have to be equal too. If two objects are equal then I can only store one of them. Hashes are expected to be integers (preferably SmallIntegers). I also expect that the objects contained by me do not change their hashes. If that happens, hash invariants have to be re-established, which can be done by #rehash.

Since I'm abstract, no instances of me should exist. My subclasses should implement #scanFor:, #fixCollisionsFrom: and #noCheckNoGrowFillFrom:.

Instance Variables
	array:		<ArrayedCollection> (typically Array or WeakArray)
	tally:		<Integer> (non-negative)

array
	- An array whose size is a prime number, it's non-nil elements are the elements of the collection, and whose nil elements are empty slots. There is always at least one nil. In fact I try to keep my ""load"" at 75% or less so that hashing will work well.

tally
	- The number of elements in the collection. The array size is always greater than this.

Implementation details:
I implement a hash table which uses open addressing with linear probing as the method of collision resolution. Searching for an element or a free slot for an element is done by #scanFor: which should return the index of the slot in array corresponding to it's argument. When an element is removed #fixCollisionsFrom: should rehash all elements in array between the original index of the removed element, wrapping around after the last slot until reaching an empty slot. My maximum load factor (75%) is hardcoded in #atNewIndex:put:, so it can only be changed by overriding that method. When my load factor reaches this limit I replace my array with a larger one (see #grow) ensuring that my load factor will be less than or equal to 50%. The new array is filled by #noCheckNoGrowFillFrom: which should use #scanForEmptySlotFor: instead of #scanFor: for better performance. I do not shrink.

"
Class {
	#name : 'ShHashedCollection',
	#superclass : 'Collection',
	#traits : 'TShObject',
	#classTraits : 'TShObject classTrait',
	#instVars : [
		'#tally => ShSlot',
		'#array => ShSlot'
	],
	#category : 'SharedObjects-BaseClasses',
	#package : 'SharedObjects',
	#tag : 'BaseClasses'
}

{ #category : 'cleanup' }
ShHashedCollection class >> cleanUp: aggressive [
	"Rehash all instances when cleaning aggressively"

	aggressive ifTrue: [self compactAll]
]

{ #category : 'cleanup' }
ShHashedCollection class >> compactAll [
	"HashedCollection compactAll"

	self allSubclassesDo: #compactAllInstances
]

{ #category : 'cleanup' }
ShHashedCollection class >> compactAllInstances [
	"Do not use #allInstancesDo: because rehash may create new instances."

	self allInstances do: [ :each | each compact ]
]

{ #category : 'instance creation' }
ShHashedCollection class >> empty [
	^ self basicNew
		initialize: 1;
		yourself
]

{ #category : 'testing' }
ShHashedCollection class >> isAbstract [

	^self name = #ShHashedCollection
]

{ #category : 'instance creation' }
ShHashedCollection class >> new [
	
	^ self newIn: ShDefaultObjectSpace value
]

{ #category : 'instance creation' }
ShHashedCollection class >> new: nElements [
	
	^ self new: nElements in: ShDefaultObjectSpace value

]

{ #category : 'instance creation' }
ShHashedCollection class >> new: nElements in: aShObjectSpace [

	^ (aShObjectSpace allocateInstanceOf: self)
		  initialize: (self sizeFor: nElements);
		  yourself
]

{ #category : 'instance creation' }
ShHashedCollection class >> newFrom: aCollection [
	"Answer an instance of me containing the same elements as aCollection."
	^self subclassResponsibility
]

{ #category : 'instance creation' }
ShHashedCollection class >> newIn: aShObjectSpace [

	^ (aShObjectSpace allocateInstanceOf: self)
		  initialize: 5;
		  yourself
]

{ #category : 'cleanup' }
ShHashedCollection class >> rehashAll [
	"HashedCollection rehashAll"

	self allSubclassesDo: #rehashAllInstances
]

{ #category : 'cleanup' }
ShHashedCollection class >> rehashAllInstances [
	"Do not use #allInstancesDo: because rehash may create new instances."

	self allInstances do: [ :each | each rehash ]
]

{ #category : 'instance creation' }
ShHashedCollection class >> sizeFor: nElements [
	"Large enough size to hold nElements with some slop (see fullCheck)"

	nElements < 4 ifTrue: [ ^5 ].
	^ HashTableSizes atLeast: nElements +1 * 4 // 3
]

{ #category : 'adding' }
ShHashedCollection >> add: newObject withOccurrences: anInteger [
	"Add newObject anInteger times to the receiver. Do nothing if anInteger is less than one. Answer newObject."

	anInteger < 1 ifTrue: [ ^newObject ].
	"I can only store an object once."
	^ self add: newObject
]

{ #category : 'private' }
ShHashedCollection >> array [
	^ array
]

{ #category : 'private' }
ShHashedCollection >> atNewIndex: index put: anObject [
	array at: index put: anObject.
	tally := tally + 1.
	self fullCheck
]

{ #category : 'accessing' }
ShHashedCollection >> capacity [
	"Answer the current capacity of the receiver."

	^ array size
]

{ #category : 'private' }
ShHashedCollection >> compact [
	"Reduce the size of array so that the load factor will be ~75%."

	| newCapacity |
	newCapacity := HashTableSizes atLeast: tally * 4 // 3.
	self growTo: newCapacity
]

{ #category : 'private' }
ShHashedCollection >> errorNoFreeSpace [

	self error: 'There is no free space in this collection!'
]

{ #category : 'private' }
ShHashedCollection >> findElementOrNil: anObject [
	"Answer the index of a first slot containing either a nil (indicating an empty slot) or an element that matches the given object. Answer the index of that slot or zero. Fail if neither a match nor an empty slot is found."

	| index |

	index := self scanFor: anObject.
	index > 0 ifTrue: [^index].

	"Bad scene.  Neither have we found a matching element
	nor even an empty slot.  No hashed set is ever supposed to get
	completely full."
	self error: 'There is no free space in this set!'
]

{ #category : 'private' }
ShHashedCollection >> fixCollisionsFrom: start [
	"The element at start has been removed and replaced by nil.
	This method moves forward from there, relocating any entries
	that had been placed below due to collisions with this one."

	self subclassResponsibility
]

{ #category : 'private' }
ShHashedCollection >> fullCheck [
	"Keep array at least 1/4 free for decent hash behavior"
	array size - tally < (array size // 4 max: 1)
		ifTrue: [self grow]
]

{ #category : 'private' }
ShHashedCollection >> grow [
	"Grow the elements array and reinsert the old elements"

	| oldElements |
	oldElements := array.
	array := ShArray
		         new: (HashTableSizes atLeast: oldElements size * 2)
		         in: self reference objectSpace.
		
	tally := 0.
	oldElements do: [ :each | each ifNotNil: [ self noCheckAdd: each ] ]
]

{ #category : 'private' }
ShHashedCollection >> growSize [
	"Answer what my next higher table size should be"

	^HashTableSizes atLeast: self capacity * 3 // 2 + 2
]

{ #category : 'private' }
ShHashedCollection >> growTo: anInteger [
	"Grow the elements array and reinsert the old elements"

	| oldElements |
	oldElements := array.
	array := ShArray new: anInteger in: self reference objectSpace.
	self noCheckNoGrowFillFrom: oldElements
]

{ #category : 'initialization' }
ShHashedCollection >> initialize: n [
	"Initialize array to an array size of n"

	array := ShArray new: n in: self reference objectSpace.
	tally := 0
]

{ #category : 'private' }
ShHashedCollection >> noCheckAdd: anObject [

    self subclassResponsibility
]

{ #category : 'private' }
ShHashedCollection >> noCheckNoGrowFillFrom: anArray [
	"Add the elements of anArray except nils to me assuming that I don't contain any of them, they are unique and I have more free space than they require."

	self subclassResponsibility
]

{ #category : 'private' }
ShHashedCollection >> rehash [
	self growTo: self capacity
]

{ #category : 'removing' }
ShHashedCollection >> removeAll [
	"remove all elements from this collection.
	Preserve the capacity"

	self initialize: self capacity
]

{ #category : 'private' }
ShHashedCollection >> scanFor: anObject [
	"Scan the key array for the first slot containing either a nil (indicating an empty slot) or an element that matches anObject. Answer the index of that slot or raise an error if no slot is found. This method will be overridden in various subclasses that have different interpretations for matching elements."

	self subclassResponsibility
]

{ #category : 'private' }
ShHashedCollection >> scanForEmptySlotFor: aKey [
	"Scan the key array for the first slot containing an empty slot (indicated by a nil). Answer the index of that slot. This method will be overridden in various subclasses that have different interpretations for matching elements."

	| index start |
	index := start := aKey hash \\ array size + 1.
	[
		(array at: index) ifNil: [ ^index ].
		(index := index \\ array size + 1) = start ] whileFalse.
	self errorNoFreeSpace
]

{ #category : 'accessing' }
ShHashedCollection >> size [
	^ tally
]

{ #category : 'enumerating' }
ShHashedCollection >> union: aCollection [
	"Answer the set theoretic union of the receiver and aCollection, using the receiver's notion of equality and not side effecting the receiver at all."

	^ self copy addAll: aCollection; yourself
]

{ #category : 'copying' }
ShHashedCollection >> veryDeepCopyWith: deepCopier [
	| copyOfSelf|
	copyOfSelf := super veryDeepCopyWith: deepCopier.
	"force Sets and Dictionaries to rehash"
	copyOfSelf rehash.
		^ copyOfSelf
]
