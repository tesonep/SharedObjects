Class {
	#name : 'ShObjectSpace',
	#superclass : 'Object',
	#instVars : [
		'memory',
		'knownObjectsTable',
		'nilObject',
		'falseObject',
		'trueObject',
		'identityCache',
		'baseClasses',
		'state'
	],
	#classVars : [
		'HEADER_CLASS_BITS',
		'HEADER_CLASS_MASK',
		'HEADER_CLASS_OFFSET',
		'HEADER_TYPE_BITS',
		'HEADER_TYPE_MASK',
		'HEADER_TYPE_OFFSET',
		'HEADER_USED_SLOTS_BITS',
		'HEADER_USED_SLOTS_MASK',
		'HEADER_USED_SLOTS_OFFSET',
		'HEADER_WORDS_BITS',
		'HEADER_WORDS_MASK',
		'TYPE_BYTES',
		'TYPE_POINTER'
	],
	#category : 'SharedObjects-Core',
	#package : 'SharedObjects',
	#tag : 'Core'
}

{ #category : 'class initialization' }
ShObjectSpace class >> createOnMemory: aMemory andSize: aSize [

	^ self basicNew
		  initializeWith: aMemory andSize: aSize;
		  yourself
]

{ #category : 'class initialization' }
ShObjectSpace class >> defaultSize [
		
	^ 4096 * Smalltalk wordSize
]

{ #category : 'class initialization' }
ShObjectSpace class >> externalNew [

	^ self basicNew
		  initializeWith: (ExternalAddress allocate: self defaultSize)
		  andSize: self defaultSize;
		  yourself
]

{ #category : 'class initialization' }
ShObjectSpace class >> initialize [

	HEADER_WORDS_BITS := 22.
	HEADER_CLASS_BITS := 10.
	HEADER_TYPE_BITS  := 3.
	HEADER_USED_SLOTS_BITS  := 3.
	
	HEADER_CLASS_OFFSET := HEADER_WORDS_BITS.
	HEADER_TYPE_OFFSET  := HEADER_CLASS_OFFSET + HEADER_CLASS_BITS.
	HEADER_USED_SLOTS_OFFSET := HEADER_TYPE_OFFSET + HEADER_TYPE_BITS.
	
	HEADER_CLASS_MASK := 2 ** HEADER_CLASS_BITS - 1.
	HEADER_WORDS_MASK := 2 ** HEADER_WORDS_BITS - 1.
	HEADER_TYPE_MASK  := 2 ** HEADER_TYPE_BITS - 1.
	HEADER_USED_SLOTS_MASK := 2 ** HEADER_USED_SLOTS_BITS - 1.


	TYPE_POINTER := 0.
	TYPE_BYTES   := 1
]

{ #category : 'as yet unclassified' }
ShObjectSpace class >> knowObjectInitialAddress [

	^ 16r100000000
]

{ #category : 'class initialization' }
ShObjectSpace class >> new [

	^ self basicNew
		  initializeWith: (ByteArray new: self defaultSize)
		  andSize: self defaultSize;
		  yourself
]

{ #category : 'class initialization' }
ShObjectSpace class >> openOnExistingMemory: aMemory withSize: aSize [

	^ self basicNew
		  initializeOnExistingMemory: aMemory andSize: aSize;
		  yourself
]

{ #category : 'query' }
ShObjectSpace >> allObjects [
	
	| nextObject obj |
	
	nextObject := 0.
	^ OrderedCollection streamContents: [ :stream |
		[nextObject < state freeStart] 
			whileTrue: [ 
				obj := self readObjectAt: nextObject.
				obj class isHiddenObject ifFalse: [ stream nextPut: obj ].
				nextObject := self objectAfter: nextObject ] ]
]

{ #category : 'allocation' }
ShObjectSpace >> allocateInstanceOf: aClass [

	| words |
	aClass isSharedObject ifFalse: [ self error ].
	words := aClass sharedSlots size.

	^ self allocateInstanceOf: aClass withPointers: words

]

{ #category : 'allocation' }
ShObjectSpace >> allocateInstanceOf: aClass withBytes: byteSize [ 

	| header words address |
	header := self headerFor: aClass type: TYPE_BYTES slots: byteSize.
	words := (byteSize / 8) ceiling. 

	address := self basicAllocateWords: words header: header.

	^ self readObjectAt: address
]

{ #category : 'allocation' }
ShObjectSpace >> allocateInstanceOf: aClass withPointers: words [ 
	
	| header address |
	
	header := self headerFor: aClass type: TYPE_POINTER slots: words.

	address := self basicAllocateWords: words header: header.

	^ self readObjectAt: address
]

{ #category : 'allocation' }
ShObjectSpace >> basicAllocate: requestedBytes [

	| allocatedBytes address |

	allocatedBytes := (requestedBytes % self wordSize = 0)
		                  ifTrue: [ requestedBytes ]
		                  ifFalse: [ self halt ].
	
	address := state freeStart.
	
	address + requestedBytes > state memorySize 
		ifTrue: [ self error: 'Space Full' ].
	
	state freeStart: address + requestedBytes.
	
	^ address
]

{ #category : 'allocation' }
ShObjectSpace >> basicAllocateWords: words header: header [

	| headerSize address |
	
	headerSize := 1.

	address := self basicAllocate: headerSize + words * self wordSize.

	self basicWriteAtAddress: address put: header.

	1 to: words do: [ :anOffset |
		self
			basicWriteAtAddress: address + (self wordSize * anOffset)
			put: self nilObject ].
		
	^ address
]

{ #category : 'reading' }
ShObjectSpace >> basicReadAtAddress: anAddress [

	^ memory int64AtOffset: anAddress
]

{ #category : 'reading' }
ShObjectSpace >> basicReadByteAtAddress: anAddress [

	^ memory uint8AtOffset: anAddress
]

{ #category : 'writing' }
ShObjectSpace >> basicWriteAtAddress: anAddress put: aValue [

	memory int64AtOffset: anAddress put: aValue
]

{ #category : 'writing' }
ShObjectSpace >> basicWriteByteAtAddress: anAddress put: aValue [

	memory uint8AtOffset: anAddress put: aValue
]

{ #category : 'initialization' }
ShObjectSpace >> bootstrapStateWithSize: aSize [

	| stateSlots stateObjectHeader stateAddress |
	stateSlots := ShSpaceState sharedSlots size.
	stateObjectHeader := self headerFor: ShSpaceState type: TYPE_POINTER slots: stateSlots. 
	
	stateAddress := 0.
	
	self basicWriteAtAddress: stateAddress put: stateObjectHeader.
	
	1 to: stateSlots do: [ :i | 
		self basicWriteAtAddress: (stateAddress + (i* self wordSize)) put: self nilObject ].
	
	state := self readObjectAt: stateAddress.

	"Initialize Memory State"	
	state memorySize: aSize.	
	state freeStart: (self objectAfter: stateAddress).
	
	"Initialize Class Table"
	state lastBaseClassesIndex: baseClasses values max.
	state classTable: (ShHiddenArray new: 50 in: self)
]

{ #category : 'accessing' }
ShObjectSpace >> classIndexFor: aClass [

	baseClasses at: aClass ifPresent: [ :anIndex | ^ anIndex ].
	^ state classIndexFor: aClass.

]

{ #category : 'utilities' }
ShObjectSpace >> decodeSmallFloat: value [

	| bits |

	bits := self smallFloatBitsOf: value.

	^ (Float new: 2)
		  at: 1 put: bits >> 32;
		  at: 2 put: (bits bitAnd: 16rFFFFFFFF);
		  * 1.0 "reduce to SmallFloat64 if possible"
]

{ #category : 'utilities' }
ShObjectSpace >> decodeSmallInteger: value [

	^ value < 0
		  ifTrue: [ ^ (value - self smallIntegerTag) abs >> self tagBitSize * -1 ]
		  ifFalse: [ ^ value - self smallIntegerTag >> self tagBitSize ]
]

{ #category : 'utilities' }
ShObjectSpace >> decodeValue: value [

	(self isSmallIntegerValue: value) ifTrue: [ ^ self decodeSmallInteger: value ].
	(self isSmallFloatValue: value) ifTrue: [ ^ self decodeSmallFloat: value ].

	(self isKnownObject: value) ifTrue: [ ^ knownObjectsTable at: value ].

	^ self readObjectAt: value
]

{ #category : 'utilities' }
ShObjectSpace >> encodeSmallFloat: aFloat [

	| rawFloat rotatedLeft |

	rawFloat := (aFloat at: 1) << 32 + (aFloat at: 2).	
	rotatedLeft := (rawFloat >> 63 bitAnd: 1) + ((rawFloat bitAnd: 16r7FFFFFFFFFFFFFFF) << 1).
	
	"a.k.a. ~= +/-0.0"
	rotatedLeft > 1 ifTrue: [
		 rotatedLeft := rotatedLeft - (self smallFloatExponentOffset << (self smallFloatMantissaBits + 1)).
		 self assert: rotatedLeft > 0].
	
	
	^ ((rotatedLeft << self tagBitSize) bitAnd: 16rFFFFFFFFFFFFFFFF) + self smallFloatTag
]

{ #category : 'utilities' }
ShObjectSpace >> encodeSmallInteger: anObject [

	^ anObject << self tagBitSize + self smallIntegerTag
]

{ #category : 'utilities' }
ShObjectSpace >> encodeValue: anObject [

	anObject class = SmallInteger ifTrue: [ ^ self encodeSmallInteger: anObject ].
	anObject class = SmallFloat64 ifTrue: [ ^ self encodeSmallFloat: anObject ].

	knownObjectsTable
		keyAtValue: anObject
		ifPresent: [ :address | ^ address ].

	anObject class isSharedObject ifFalse: [ self halt ].
	^ anObject reference address
]

{ #category : 'utilities' }
ShObjectSpace >> fetchClassOfHeader: anInteger [ 
	
	| classIndex |
	classIndex := (anInteger >> HEADER_CLASS_OFFSET) bitAnd: HEADER_CLASS_MASK.

	^ baseClasses keyAtValue: classIndex ifAbsent: [ state fetchClassForIndex: classIndex ].
]

{ #category : 'utilities' }
ShObjectSpace >> fetchIndexableByteSizeOf: aHeader [

	^ (((self fetchSizeOfHeader: aHeader) - 1) * self wordSize)
	  + (self fetchUsedSlotsInLastWordOfHeader: aHeader)
]

{ #category : 'utilities' }
ShObjectSpace >> fetchSizeOfHeader: anInteger [ 
	
	^ anInteger bitAnd: HEADER_WORDS_MASK 
]

{ #category : 'utilities' }
ShObjectSpace >> fetchUsedSlotsInLastWordOfHeader: aHeader [ 
	
	^ (aHeader >> HEADER_USED_SLOTS_OFFSET) bitAnd: HEADER_USED_SLOTS_MASK 
]

{ #category : 'finalization' }
ShObjectSpace >> free [

	memory isExternalAddress ifTrue: [ memory free ]
]

{ #category : 'utilities' }
ShObjectSpace >> headerFor: aClass type: aType slots: slots [

	| classIndex words usedSlots remainer |

	words := slots.
	usedSlots := 0.
	
	aType = TYPE_BYTES 
		ifTrue: [ 
			words := (slots / self wordSize) ceiling.
			remainer := slots % self wordSize.
			usedSlots := remainer = 0 ifTrue: [ self wordSize ] ifFalse: [ remainer ] ].

	words >= (2 ** HEADER_WORDS_BITS - 1) ifTrue: [ self halt ].

	classIndex := self classIndexFor: aClass.
		
	^	((aType bitAnd: HEADER_TYPE_MASK) << HEADER_TYPE_OFFSET) 
		+ ((usedSlots bitAnd: HEADER_USED_SLOTS_MASK) << HEADER_USED_SLOTS_OFFSET)
		+ ((classIndex bitAnd: HEADER_CLASS_MASK) << HEADER_CLASS_OFFSET) 
		+ (words bitAnd: HEADER_WORDS_MASK)
]

{ #category : 'accessing' }
ShObjectSpace >> headerSize [
	
	^ 1 
]

{ #category : 'query' }
ShObjectSpace >> indexableByteSizeOf: anAddress [ 

	| header |
	
	header := self readHeaderAt: anAddress.
	^ self fetchIndexableByteSizeOf: header
]

{ #category : 'initialization' }
ShObjectSpace >> initializeBaseClasses [

	baseClasses at: ShObject put: 1.

	baseClasses at: ShArray put: 2.
	baseClasses at: ShByteString put: 3.
	baseClasses at: ShDictionary put: 4.
	baseClasses at: ShOrderedCollection put: 5.
	baseClasses at: ShAssociation put: 6.
	baseClasses at: ShSet put: 7.
	
	baseClasses at: ShSpaceState put: 8.
	baseClasses at: ShHiddenArray put: 9.
	baseClasses at: ShHiddenByteString put: 10.
]

{ #category : 'initialization' }
ShObjectSpace >> initializeKnownObjectTable [

	| objAddress |

	knownObjectsTable := Dictionary new.
	objAddress := self class knowObjectInitialAddress.
	
	knownObjectsTable at: (nilObject := objAddress) put: nil.
	knownObjectsTable at: (falseObject := objAddress + 8) put: false.	
	knownObjectsTable at: (trueObject := objAddress + 16 )put: true.		
]

{ #category : 'initialization' }
ShObjectSpace >> initializeOnExistingMemory: aMemory andSize: aSize [

	super initialize.

	memory := aMemory.
	identityCache := WeakValueDictionary new.
	baseClasses := Dictionary new.

	self initializeKnownObjectTable.
	self initializeBaseClasses.
	state := self readObjectAt: 0.

]

{ #category : 'initialization' }
ShObjectSpace >> initializeWith: aMemory andSize: aSize [

	super initialize.

	memory := aMemory.
	identityCache := WeakValueDictionary new.
	baseClasses := Dictionary new.

	self initializeKnownObjectTable.
	self initializeBaseClasses.
	self bootstrapStateWithSize: aSize
]

{ #category : 'utilities' }
ShObjectSpace >> isKnownObject: value [

	^ (value bitAnd: self class knowObjectInitialAddress) ~= 0
]

{ #category : 'utilities' }
ShObjectSpace >> isSmallFloatValue: value [

	^ (value bitAnd: self smallFloatTag) = self smallFloatTag
]

{ #category : 'utilities' }
ShObjectSpace >> isSmallIntegerValue: value [

	^ (value bitAnd: self smallIntegerTag) = self smallIntegerTag
]

{ #category : 'accessing' }
ShObjectSpace >> memory [
	^ memory
]

{ #category : 'accessing' }
ShObjectSpace >> nilObject [
	
	^ nilObject
]

{ #category : 'query' }
ShObjectSpace >> objectAfter: anAddress [ 
	
	| header objSize |

	header := self readHeaderAt: anAddress.
	objSize := self fetchSizeOfHeader: header.
	
	^ anAddress + ( (self headerSize + objSize) * self wordSize).
]

{ #category : 'reading' }
ShObjectSpace >> readAtAddress: anAddress [ 
	
	| value |
	
	value := self basicReadAtAddress: anAddress.
	
	^ self decodeValue: value
]

{ #category : 'writing' }
ShObjectSpace >> readAtAddress: anAddress byte: byteIndex [ 
	
	^ self readByteAtAddress: anAddress + (self headerSize * self wordSize) + byteIndex
]

{ #category : 'reading' }
ShObjectSpace >> readAtAddress: anAddress slot: slotIndex [ 
	
	slotIndex > 0 ifFalse: [ self error: 'SlotIndex should be 1 based' ].

	^ self readAtAddress: anAddress + (slotIndex * self wordSize).
	
]

{ #category : 'reading' }
ShObjectSpace >> readByteAtAddress: anAddress [ 
	
	^ self basicReadByteAtAddress: anAddress.

]

{ #category : 'reading' }
ShObjectSpace >> readHeaderAt: anAddress [ 
	
	^ self basicReadAtAddress: anAddress
]

{ #category : 'reading' }
ShObjectSpace >> readObjectAt: anAddress [ 
	
	| header objClass objSize ref |
	identityCache at: anAddress ifPresent: [ :anObject | ^ anObject ].
	
	header := self readHeaderAt: anAddress.
	objClass := self fetchClassOfHeader: header.
	objSize := self fetchSizeOfHeader: header.

	ref := ShReference new
		objectSpace: self;
		address: anAddress;
		size: objSize;
		yourself.
		
	^ identityCache at: anAddress put: (objClass realNewWithReference: ref)
]

{ #category : 'accessing' }
ShObjectSpace >> rootObject [

	^ state rootObject
]

{ #category : 'accessing' }
ShObjectSpace >> rootObject: anObject [

	state rootObject: anObject
]

{ #category : 'accessing' }
ShObjectSpace >> size [

	^ state memorySize
]

{ #category : 'query' }
ShObjectSpace >> sizeOf: aShObject [ 
	
	| header |
	
	header := self readHeaderAt: aShObject reference address.
	^ self fetchSizeOfHeader: header
]

{ #category : 'utilities' }
ShObjectSpace >> smallFloatBitsOf: aValue [ 

	| rotated |
	self assert: aValue > 0.
	
	rotated := aValue >> self tagBitSize.
	rotated > 1 ifTrue: "a.k.a. ~= +/-0.0"
		[rotated := rotated + (self smallFloatExponentOffset << (self smallFloatMantissaBits + 1))].
	
	rotated := ((rotated bitAnd: 1) << 63) + (rotated >> 1).
	
	^rotated
]

{ #category : 'utilities' }
ShObjectSpace >> smallFloatExponentOffset [
	"896 is 1023 - 127, where 1023 is the mid-point of the 11-bit double precision exponent range,
	 and 127 is the mid-point of the 8-bit SmallDouble exponent range."

	^896
]

{ #category : 'utilities' }
ShObjectSpace >> smallFloatMantissaBits [
	"SmallFloat64's have the same mantissa as IEEE double-precision floating point"

	^52
]

{ #category : 'accessing' }
ShObjectSpace >> smallFloatTag [

	^ 4
]

{ #category : 'accessing' }
ShObjectSpace >> smallIntegerTag [

	^ 1
]

{ #category : 'accessing' }
ShObjectSpace >> tagBitSize [

	^ 3
]

{ #category : 'accessing' }
ShObjectSpace >> wordSize [
	
	^ 8
]

{ #category : 'writing' }
ShObjectSpace >> writeAtAddress: anAddress byteIndex: byteIndex value: aValue [ 
	
	self writeByteAtAddress: anAddress + (self headerSize * self wordSize) + byteIndex value: aValue
]

{ #category : 'writing' }
ShObjectSpace >> writeAtAddress: anAddress slot: slotIndex value: aValue [ 
	
	self writeAtAddress: anAddress + (slotIndex * self wordSize) value: aValue
]

{ #category : 'writing' }
ShObjectSpace >> writeAtAddress: anAddress value: aValue [ 
	
	| encodedValue |
	encodedValue := self encodeValue: aValue.
	self basicWriteAtAddress: anAddress put: encodedValue
]

{ #category : 'writing' }
ShObjectSpace >> writeByteAtAddress: anAddress value: aValue [	
	
	(aValue between: 0 and: 255) ifFalse: [ self error ].

	self basicWriteByteAtAddress: anAddress put: aValue
]
