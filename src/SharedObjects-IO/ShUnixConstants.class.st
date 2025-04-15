Class {
	#name : 'ShUnixConstants',
	#superclass : 'SharedPool',
	#classVars : [
		'GETALL',
		'GETNCNT',
		'GETPID',
		'GETVAL',
		'GETZCNT',
		'IPC_CREAT',
		'IPC_EXCL',
		'IPC_NOWAIT',
		'IPC_RMID',
		'IPC_SET',
		'IPC_STAT',
		'MAP_FILE',
		'MAP_SHARED',
		'MS_SYNC',
		'O_CREAT',
		'O_RDWR',
		'PROT_READ',
		'PROT_WRITE',
		'SETALL',
		'SETVAL',
		'S_IRUSR',
		'S_IWUSR'
	],
	#category : 'SharedObjects-IO',
	#package : 'SharedObjects-IO'
}

{ #category : 'class initialization' }
ShUnixConstants class >> initialize [

	O_CREAT := 16r00000200.
	O_RDWR := 16r0002.

	S_IRUSR := 8r0400.
	S_IWUSR := 8r0200.

	PROT_READ := 1.
	PROT_WRITE := 2.
	MAP_FILE := 0.
	MAP_SHARED := 1.
	MS_SYNC := 16r0010.
	
	IPC_CREAT := 8r001000.
	IPC_EXCL := 8r002000.
	IPC_NOWAIT := 8r004000.

	IPC_RMID := 0.
	IPC_SET := 1.
	IPC_STAT := 2.
	
	GETNCNT := 3.
	GETPID := 4.
	GETVAL := 5.
	GETALL := 6.
	GETZCNT := 7.
	SETVAL := 8.
	SETALL := 9
]
