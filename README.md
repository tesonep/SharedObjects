To Install

```
Metacello new
	baseline: 'SharedObjects';
	repository: 'github://tesonep/SharedObjects';
	load
```

```smalltalk
fileBasedObjectSpace := ShFileBasedObjectSpace forFileReference: FileLocator imageDirectory / 'data.dat'. "Use an existing file"
fileBasedObjectSpace := ShFileBasedObjectSpace forFileReference: FileLocator imageDirectory / 'data.dat' withInitialSize: 10*1024*1024*1024 "10GB". "Create a new file (slow)"
```

```bash
dd bs=1048576 seek=1 of=nullbytes count=0
```

## Do Something in the space

```smalltalk
fileBasedObjectSpace onSpaceDo: [fileBasedObjectSpace rootObject: ShOrderedCollection new.].
```

## Read a long collection in the space

```smalltalk
fileBasedObjectSpace onSpaceDo: 
[FileLocator imageDirectory / '1MB-min.json' readStreamDo: [ :stream |
	fileBasedObjectSpace rootObject: ((ShNeoJSONReader on: stream)
		listClass: ShArray;
		mapClass: ShDictionary;
		next) ]].
```

## Access to the space 

```
fileBasedObjectSpace rootObject.
fileBasedObjectSpace allObjects.
fileBasedObjectSpace usedSpace humanReadableSISizeString.
```

## Close the space

```
fileBasedObjectSpace close.
```
