Class {
	#name : 'ShWinMemoryMappedFile',
	#superclass : 'Object',
	#traits : 'TWinErrorChecker',
	#classTraits : 'TWinErrorChecker classTrait',
	#instVars : [
		'filePath',
		'size',
		'address',
		'fileHandle',
		'mappingName',
		'fileMappingHandle'
	],
	#classVars : [
		'FILE_ATTRIBUTE_NORMAL',
		'FILE_MAP_ALL_ACCESS',
		'FILE_SHARE_DELETE',
		'FILE_SHARE_READ',
		'FILE_SHARE_WRITE',
		'GENERIC_READ',
		'GENERIC_WRITE',
		'OPEN_EXISTING',
		'PAGE_READWRITE'
	],
	#pools : [
		'Win32Types'
	],
	#category : 'SharedObjects-IO',
	#package : 'SharedObjects-IO'
}

{ #category : 'class initialization' }
ShWinMemoryMappedFile class >> initialize [

	OPEN_EXISTING := 3. 

	GENERIC_READ := 16r80000000. 
	GENERIC_WRITE := 16r40000000. 

	FILE_SHARE_DELETE := 4. 
	FILE_SHARE_READ := 1. 
	FILE_SHARE_WRITE := 2.

	FILE_ATTRIBUTE_NORMAL := 128.
	
	PAGE_READWRITE := 4.
	
	FILE_MAP_ALL_ACCESS := 983071.
]

{ #category : 'accessing' }
ShWinMemoryMappedFile >> address [
	
	^ address
]

{ #category : 'public' }
ShWinMemoryMappedFile >> closeFile [
	
	| return |
	return := Kernel32Lib uniqueInstance ffiCloseHandler: fileHandle.
	return ifFalse: [ self reportError: 0 ]. 
	
	fileHandle beNull.
]

{ #category : 'private - ffi' }
ShWinMemoryMappedFile >> createFile: lpFileName desiredAccess: dwDesiredAccess shareMode: dwShareMode securityAttributes: lpSecurityAttributes creationDisposition: dwCreationDisposition flagsAndAttributes: dwFlagsAndAttributes templateFile: hTemplateFile [
	
	^self ffiCall: #(HANDLE CreateFileW(
		LPWSTR                lpFileName,
  		DWORD                 dwDesiredAccess,
 		DWORD                 dwShareMode,
  		"LPSECURITY_ATTRIBUTES" void* lpSecurityAttributes,
  		DWORD                 dwCreationDisposition,
  		DWORD                 dwFlagsAndAttributes,
  		HANDLE                hTemplateFile
	))
]

{ #category : 'private - ffi' }
ShWinMemoryMappedFile >> createFileMappingFor: hFile fileMappingAttributes: lpFileMappingAttributes protect: flProtect maximumSizeHigh: dwMaximumSizeHigh maximumSizeLow: dwMaximumSizeLow lpName: lpName [ 

	self ffiCall: #(HANDLE CreateFileMappingW(
 															HANDLE                hFile,
															"LPSECURITY_ATTRIBUTES" void* lpFileMappingAttributes,
  															DWORD                 flProtect,
 															DWORD                 dwMaximumSizeHigh,
 															DWORD                 dwMaximumSizeLow,
  															LPWSTR                lpName
 													))
]

{ #category : 'accessing' }
ShWinMemoryMappedFile >> ffiLibrary [ 

	^ Kernel32Lib 
]

{ #category : 'accessing' }
ShWinMemoryMappedFile >> filePath: aString [ 
	filePath := aString
]

{ #category : 'public' }
ShWinMemoryMappedFile >> flushViewOfFile: lpBaseAddress numberOfBytesToFlush: dwNumberOfBytesToFlush [

	self ffiCall: #(BOOL FlushViewOfFile(LPVOID lpBaseAddress, size_t dwNumberOfBytesToFlush))	
]

{ #category : 'public' }
ShWinMemoryMappedFile >> mapInMemory [
	
	mappingName := filePath asFileReference basename asWin32WideString.
	
	fileMappingHandle := self 
		createFileMappingFor: fileHandle
		fileMappingAttributes: ExternalAddress null
		protect: PAGE_READWRITE
		maximumSizeHigh: 0
		maximumSizeLow: 0
		lpName: mappingName.

	fileMappingHandle isNull ifTrue: [ self reportError: 0 ].
	
	address := self 
		mapViewOfFile: fileMappingHandle
		desiredAccess: FILE_MAP_ALL_ACCESS
		fileOffsetHigh: 0
		fileOffsetLow: 0
		numberOfBytesToMap: size.
	
	address isNull ifTrue: [ self reportError: 0 ].
]

{ #category : 'private - ffi' }
ShWinMemoryMappedFile >> mapViewOfFile: hFileMappingObject desiredAccess: dwDesiredAccess fileOffsetHigh: dwFileOffsetHigh fileOffsetLow: dwFileOffsetLow numberOfBytesToMap: dwNumberOfBytesToMap [ 

	self ffiCall: #(LPVOID MapViewOfFile(
														HANDLE hFileMappingObject,
														DWORD  dwDesiredAccess,
														DWORD  dwFileOffsetHigh,
														DWORD  dwFileOffsetLow,
														size_t dwNumberOfBytesToMap))
]

{ #category : 'public' }
ShWinMemoryMappedFile >> openFile [
	
	| wideFilePath lastErrorCode |

	wideFilePath := filePath asWin32WideString.

	fileHandle := self 
		createFile: wideFilePath
		desiredAccess: GENERIC_WRITE | GENERIC_READ
		shareMode: FILE_SHARE_DELETE | FILE_SHARE_READ | FILE_SHARE_WRITE
		securityAttributes: ExternalAddress null
		creationDisposition: OPEN_EXISTING
		flagsAndAttributes: FILE_ATTRIBUTE_NORMAL
		templateFile: ExternalAddress null.
	
	fileHandle asInteger = ((1 << (Smalltalk wordSize * 8)) - 1) 
		ifTrue: [ 
			lastErrorCode := Kernel32Lib uniqueInstance lastError.
			Win32Error returnCode: -1 lastErrorCode: lastErrorCode ].
	

]

{ #category : 'accessing' }
ShWinMemoryMappedFile >> size [

	^ size 
]

{ #category : 'accessing' }
ShWinMemoryMappedFile >> size: anInteger [ 
	size := anInteger
]

{ #category : 'public' }
ShWinMemoryMappedFile >> sync [
	
	| return |
	return := self flushViewOfFile: address numberOfBytesToFlush: size.
	return ifFalse: [ self reportError: 0 ].

]

{ #category : 'public' }
ShWinMemoryMappedFile >> unmap [

	| return |
	return := self unmapViewOfFile: address.
	return ifFalse: [ self reportError: 0 ].
	address beNull.

	return := Kernel32Lib uniqueInstance ffiCloseHandler: fileMappingHandle.
	return ifFalse: [ self reportError: 0 ].
	fileMappingHandle beNull.
]

{ #category : 'private - ffi' }
ShWinMemoryMappedFile >> unmapViewOfFile: lpBaseAddress [ 

	self ffiCall: #(BOOL UnmapViewOfFile(LPVOID lpBaseAddress))
]
